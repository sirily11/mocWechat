import * as MongoClient from "mongodb"
import {ObjectId} from "mongodb"
import * as bcrypt from "bcrypt"
import {User} from './userObj';
import {settings} from "./settings/settings";
import {Feed, Comment} from "./feed/feedObj";

/**
 * Get mongodb client
 * @returns Mongodb client without database selected
 */
export function getClient(): Promise<MongoClient.MongoClient> {
    return new Promise((resolve, rejects) => {
        MongoClient.connect(settings.url, {
            useNewUrlParser: true,
            auth: {user: settings.userName, password: settings.password}
        }, (err, db) => {
            if (err) rejects(err);
            else {
                resolve(db)
            }
        })
    })
}

/**
 * Initialize collection and unique index
 */
export async function init(debug = false) {
    return new Promise(async (resolve, reject) => {
        let databaseName = settings.databaseName;
        let userCollectionName = settings.userCollectionName;
        if (debug) {
            databaseName = settings.databaseName + "-debug";
            userCollectionName = settings.userCollectionName + "-debug";
        }

        let db = await getClient();
        let dbo = db.db(databaseName);
        dbo.createCollection(userCollectionName, (err, res) => {
            if (err) console.log(err);
            else {
                res.createIndex({userName: "text"}, {unique: true}, (err, result) => {
                    if (err) reject(err);
                    else {
                        resolve()
                    }
                })
            }
            db.close()
        });

        dbo.createCollection(settings.feedCollectionName, (err, res) => {
            if (err) console.log(err);
            else {
                resolve();
            }
            db.close()
        });


    })
}


export async function destroy(debug = false) {
    let databaseName = settings.databaseName;
    if (debug) {
        databaseName = settings.databaseName + "-debug"
    }
    let db = await getClient();
    let dbo = db.db(databaseName);
    await dbo.dropDatabase();
    db.close()
}

/**
 * Create A new user
 * @param user User Object
 * @returns User ID
 */
export async function addUser(user: User, debug = false): Promise<string> {
    return new Promise(async (resolve, rejects) => {
        let databaseName = settings.databaseName;
        let userCollectionName = settings.userCollectionName;
        if (debug) {
            databaseName = settings.databaseName + "-debug";
            userCollectionName = settings.userCollectionName + "-debug"
        }

        let db = await getClient();
        let dbo = db.db(databaseName);
        try {
            let hashPassword = await bcrypt.hash(user.password, 10);
            user.password = hashPassword
        } catch (err) {
            console.log(err)
        }

        dbo.collection(userCollectionName).insertOne(user, (err, res) => {
            if (err) {
                if (err.errmsg && err.errmsg.includes("duplicate key error collection")) {
                    rejects("Username already exists")
                } else {
                    rejects(err)
                }
            } else {
                console.log("document inserted");
                resolve(res.insertedId.toHexString())
            }
            db.close()
        })
    })

}

/**
 * Delete a user
 * @param user User Object
 */
export async function deleteUser(userID: string, debug = false) {
    let databaseName = settings.databaseName;
    let userCollectionName = settings.userCollectionName;
    if (debug) {
        databaseName = settings.databaseName + "-debug";
        userCollectionName = settings.userCollectionName + "-debug";
    }

    let db = await getClient();
    let dbo = db.db(databaseName);

    dbo.collection(userCollectionName).deleteOne({_id: new MongoClient.ObjectID(userID)}, (err, res) => {
        if (err) console.log(err);
        else {
            console.log("document deleted")
        }
        db.close()
    })
}

/**
 * Login the user
 * @param userName Username to login
 * @param password password
 * @returns user id if login success
 */
export async function login(userName: string, password: string, debug = false): Promise<User> {
    return new Promise(async (resolve, reject) => {
        let databaseName = settings.databaseName;
        let userCollectionName = settings.userCollectionName;
        if (debug) {
            databaseName = settings.databaseName + "-debug";
            userCollectionName = settings.userCollectionName + "-debug";
        }

        let db = await getClient();
        let dbo = db.db(databaseName);
        try {
            let docs = await dbo.collection<User>(userCollectionName)
                .aggregate([
                    {
                        '$lookup': {
                            'from': 'user',
                            'localField': 'friends',
                            'foreignField': '_id',
                            'as': 'friends'
                        }
                    }, {
                        '$match': {
                            'userName': userName
                        }
                    }, {
                        '$project': {
                            'avatar': 1,
                            'userName': 1,
                            'password': 1,
                            'sex': 1,
                            'dateOfBirth': 1,
                            'friends': {
                                'userName': 1,
                                '_id': 1,
                                'sex': 1,
                                'dateOfBirth': 1,
                                'avatar': 1
                            }
                        }
                    }
                ]).toArray();

            if (docs[0].password) {
                let match = await bcrypt.compare(password, docs[0].password);
                if (match) {
                    resolve(docs[0])
                } else {
                    reject("Wrong password")
                }
            } else {
                reject("Wrong password")
            }
        } catch (e) {
            console.log(e);
        }

        await db.close()

    })
}

/**
 * Add friend to one's friend list
 * @param user User who want to add friend
 * @param friend friend to be added
 * @returns true if added
 */
export async function addFriend(user: User, friend: User, debug = false): Promise<boolean> {
    return new Promise(async (resolve, reject) => {
        let databaseName = settings.databaseName;
        let userCollectionName = settings.userCollectionName;
        if (debug) {
            databaseName = settings.databaseName + "-debug";
            userCollectionName = settings.userCollectionName + "-debug";
        }
        let db = await getClient();
        let dbo = db.db(databaseName);
        if (user._id && friend._id) {
            if (user._id == friend._id) reject(false);

            dbo.collection(userCollectionName).updateOne({_id: new MongoClient.ObjectID(user._id)}, {$addToSet: {friends: new MongoClient.ObjectID(friend._id)}}, (err, res) => {
                if (err) {
                    console.log(err);
                    reject(false)
                } else {
                    dbo.collection(settings.userCollectionName).updateOne({_id: new MongoClient.ObjectID(friend._id)}, {$addToSet: {friends: new MongoClient.ObjectID(user._id)}}, (err, res) => {
                        if (err) {
                            console.log(err);
                            reject(false);
                        } else {
                            console.log("friend added");
                            resolve(true);
                        }
                        db.close();
                    })
                }

            })
        } else {
            db.close();
            console.log("No user id field");
            reject(false);
        }
    })

}

/**
 * Get user's friends
 * @param user user with id
 */
export async function getFriendList(user: User, debug = false): Promise<User[]> {
    return new Promise(async (resolve, reject) => {
        let databaseName = settings.databaseName;
        let userCollectionName = settings.userCollectionName;
        if (debug) {
            databaseName = settings.databaseName + "-debug";
            userCollectionName = settings.userCollectionName + "-debug";
        }
        let db = await getClient();
        let dbo = db.db(databaseName);
        if (user._id) {
            try {
                let u = await dbo.collection(userCollectionName).findOne({_id: new MongoClient.ObjectID(user._id)});
                if (u !== null) {
                    let friendsID: string[] = u.friends;
                    let friends: User[] = await dbo.collection(userCollectionName).find({_id: {$in: friendsID}}, {projection: {password: 0}}).toArray();
                    resolve(friends);
                } else {
                    reject("getFriendList: No such user");
                }

            } catch (err) {
                reject(err);
            }

        } else {
            reject("User doesn't have id");
        }
        await db.close();
    })
}

/**
 *  Search user by it user name.
 *  This will return a list of user which have the similar user name
 * @param userName User's user name
 * @param debug
 */
export async function searchPeople(userName: string, debug = false): Promise<User[]> {
    return new Promise(async (resolve, reject) => {
        let databaseName = settings.databaseName;
        let userCollectionName = settings.userCollectionName;
        if (debug) {
            databaseName = settings.databaseName + "-debug";
            userCollectionName = settings.userCollectionName + "-debug";
        }
        let db = await getClient();
        let dbo = db.db(databaseName);
        try {


            let userList: User[] = await dbo.collection(userCollectionName).aggregate([
                {
                    '$lookup': {
                        'from': 'user',
                        'localField': 'friends',
                        'foreignField': '_id',
                        'as': 'friends'
                    }
                }, {
                    '$match': {
                        'userName': {
                            '$regex': 'siri'
                        }
                    }
                }, {
                    '$project': {
                        'avatar': 1,
                        'userName': 1,
                        'password': 1,
                        'sex': 1,
                        'dateOfBirth': 1,
                        'friends': {
                            'userName': 1,
                            '_id': 1,
                            'sex': 1,
                            'dateOfBirth': 1,
                            'avatar': 1
                        }
                    }
                }
            ]).limit(10).toArray();
            resolve(userList)
        } catch (err) {
            reject(err)
        }

    })
}

/**
 * Get all feed by user. This should list feed belongs to user and user's friend
 * @param user
 * @param begin begins at index
 */
export async function getAllFeed(user: User, begin: number): Promise<Feed[]> {
    let db = await getClient();
    let dbo = db.db(settings.databaseName);
    try {
        let u = await dbo.collection(settings.userCollectionName).findOne({_id: new ObjectId(user._id)});
        let friends: [] = u?.friends ?? [];
        let friendsObjs = friends.map((f) => new ObjectId(f));
        console.log("People", [new ObjectId(user._id), ...friendsObjs]);
        return await dbo.collection<Feed>(settings.feedCollectionName)
            .aggregate([
                {
                    '$match': {
                        'user': {$in: [new ObjectId(user._id), ...friendsObjs]}
                    }
                }, {
                    '$lookup': {
                        'from': 'user',
                        'localField': 'user',
                        'foreignField': '_id',
                        'as': 'user'
                    }
                },
                {
                    '$lookup': {
                        'from': 'user',
                        'localField': 'comments.user',
                        'foreignField': '_id',
                        'as': 'users'
                    }
                }, {
                    '$lookup': {
                        'from': 'user',
                        'localField': 'comments.reply_to',
                        'foreignField': '_id',
                        'as': 'reply_tos'
                    }
                }, {
                    '$addFields': {
                        'comments': {
                            '$map': {
                                'input': '$comments',
                                'as': 'c',
                                'in': {
                                    '_id': '$$c._id',
                                    'content': '$$c.content',
                                    'is_reply': '$$c.is_reply',
                                    'posted_time': '$$c.posted_time',
                                    'user': {
                                        '_id': '$$c.user',
                                        'userName': {
                                            '$arrayElemAt': [
                                                '$users.userName', {
                                                    '$indexOfArray': [
                                                        '$users._id', '$$c.user'
                                                    ]
                                                }
                                            ]
                                        }
                                    },
                                    'reply_to': {
                                        '_id': '$$c.user',
                                        'userName': {
                                            '$arrayElemAt': [
                                                '$reply_tos.userName', {
                                                    '$indexOfArray': [
                                                        '$reply_tos._id', '$$c.reply_to'
                                                    ]
                                                }
                                            ]
                                        }
                                    }
                                }
                            }
                        }
                    }
                }, {
                    '$project': {
                        'reply_tos': 0,
                        'users': 0
                    }
                }
                ,
                {
                    '$project': {
                        'content': 1,
                        'images': 1,
                        'likes': 1,
                        'comments': 1,
                        'publish_date': 1,
                        'user': {
                            '$arrayElemAt': [
                                '$user', 0
                            ]
                        }
                    }
                }, {
                    '$project': {
                        'user': {
                            'password': 0,
                            'friends': 0
                        },
                        // 'comments': {
                        //     'content': 1,
                        //     'password': 0,
                        //     'friends': 0,
                        //     'dateOfBirth': 0,
                        //     'sex': 0
                        // }
                    }
                }
            ])
            .skip(begin)
            .limit(30)
            .toArray();
    } catch (e) {
        console.log(e);
    }
    return []
}

export async function writeFeed(feed: Feed): Promise<Feed | undefined> {
    let db = await getClient();
    let dbo = db.db(settings.databaseName);
    try {
        let result = await dbo.collection<Feed>(settings.feedCollectionName).insertOne(feed);
        return {...feed, _id: result.insertedId.toHexString()}
    } catch (e) {
        console.log(e);
    }
    return
}

export async function deleteFeed(feed: Feed): Promise<void> {
    let db = await getClient();
    let dbo = db.db(settings.databaseName);
    try {
        await dbo.collection(settings.feedCollectionName).deleteOne({_id: new ObjectId(feed._id)});
    } catch (e) {
        console.log(e);
    }
}

/**
 * add like
 * @param feed User's feed
 * @param user user who press like
 */
export async function addFeedLike(feed: Feed, user: User): Promise<void> {
    let db = await getClient();
    let dbo = db.db(settings.databaseName);
    try {
        await dbo.collection(settings.feedCollectionName).updateOne({_id: new ObjectId(feed._id)}, {$addToSet: {likes: user._id}});
    } catch (e) {
        console.log(e);
    }
}

/**
 * remove like
 * @param feed User's feed
 * @param user user who press like
 */
export async function deleteFeedLike(feed: Feed, user: User): Promise<void> {
    let db = await getClient();
    let dbo = db.db(settings.databaseName);
    try {
        await dbo.collection(settings.feedCollectionName).updateOne({_id: new ObjectId(feed._id)}, {$pull: {likes: user._id}});
    } catch (e) {
        console.log(e);
    }
}

export async function writeComment(comment: Comment, feedID: string): Promise<String | undefined> {
    let db = await getClient();
    let dbo = db.db(settings.databaseName);
    let objectID = new ObjectId();
    try {
        let result = await dbo
            .collection<Feed>(settings.feedCollectionName)
            .findOneAndUpdate({_id: new ObjectId(feedID)}, {$push: {comments: {_id: objectID, ...comment}}});
        return objectID.toHexString()
    } catch (e) {
        console.log(e);
    }
    return
}

export async function deleteComment(comment: Comment, feedID: string): Promise<void> {
    let db = await getClient();
    let dbo = db.db(settings.databaseName);
    try {
        await dbo.collection(settings.feedCollectionName).updateOne({_id: new ObjectId(feedID)}, {$pull: {comments: {_id: new ObjectId(comment._id)}}});
    } catch (e) {
        console.log(e);
    }
}

export async function uploadAvatar(imagePath: string, user: User): Promise<void> {
    let db = await getClient();
    let dbo = db.db(settings.databaseName);
    try {
        await dbo.collection(settings.userCollectionName).updateOne({_id: new ObjectId(user._id)}, {$set: {'avatar': imagePath}});
    } catch (e) {
        console.log(e);
    }
}
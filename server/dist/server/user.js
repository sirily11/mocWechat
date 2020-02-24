"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const MongoClient = require("mongodb");
const mongodb_1 = require("mongodb");
const bcrypt = require("bcrypt");
const settings_1 = require("./settings/settings");
const fs = require("fs");
const path = require("path");
/**
 * Get mongodb client
 * @returns Mongodb client without database selected
 */
function getClient() {
    return new Promise((resolve, rejects) => {
        MongoClient.connect(settings_1.settings.url, {
            useNewUrlParser: true,
            auth: { user: settings_1.settings.userName, password: settings_1.settings.password }
        }, (err, db) => {
            if (err)
                rejects(err);
            else {
                resolve(db);
            }
        });
    });
}
exports.getClient = getClient;
/**
 * Initialize collection and unique index
 */
function init(debug = false) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
            let databaseName = settings_1.settings.databaseName;
            let userCollectionName = settings_1.settings.userCollectionName;
            if (debug) {
                databaseName = settings_1.settings.databaseName + "-debug";
                userCollectionName = settings_1.settings.userCollectionName + "-debug";
            }
            let db = yield getClient();
            let dbo = db.db(databaseName);
            dbo.createCollection(userCollectionName, (err, res) => {
                if (err)
                    console.log(err);
                else {
                    res.createIndex({ userName: "text" }, { unique: true }, (err, result) => {
                        if (err)
                            reject(err);
                        else {
                            resolve();
                        }
                    });
                }
                db.close();
            });
            dbo.createCollection(settings_1.settings.feedCollectionName, (err, res) => {
                if (err)
                    console.log(err);
                else {
                    resolve();
                }
                db.close();
            });
        }));
    });
}
exports.init = init;
function destroy(debug = false) {
    return __awaiter(this, void 0, void 0, function* () {
        let databaseName = settings_1.settings.databaseName;
        if (debug) {
            databaseName = settings_1.settings.databaseName + "-debug";
        }
        let db = yield getClient();
        let dbo = db.db(databaseName);
        yield dbo.dropDatabase();
        db.close();
    });
}
exports.destroy = destroy;
/**
 * Create A new user
 * @param user User Object
 * @returns User ID
 */
function addUser(user, debug = false) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, rejects) => __awaiter(this, void 0, void 0, function* () {
            let databaseName = settings_1.settings.databaseName;
            let userCollectionName = settings_1.settings.userCollectionName;
            if (debug) {
                databaseName = settings_1.settings.databaseName + "-debug";
                userCollectionName = settings_1.settings.userCollectionName + "-debug";
            }
            let db = yield getClient();
            let dbo = db.db(databaseName);
            try {
                let hashPassword = yield bcrypt.hash(user.password, 10);
                user.password = hashPassword;
            }
            catch (err) {
                console.log(err);
            }
            dbo.collection(userCollectionName).insertOne(user, (err, res) => {
                if (err) {
                    if (err.errmsg && err.errmsg.includes("duplicate key error collection")) {
                        rejects("Username already exists");
                    }
                    else {
                        rejects(err);
                    }
                }
                else {
                    console.log("document inserted");
                    // @ts-ignore
                    resolve(res.insertedId);
                }
                db.close();
            });
        }));
    });
}
exports.addUser = addUser;
/**
 * Delete a user
 * @param user User Object
 */
function deleteUser(userID, debug = false) {
    return __awaiter(this, void 0, void 0, function* () {
        let databaseName = settings_1.settings.databaseName;
        let userCollectionName = settings_1.settings.userCollectionName;
        if (debug) {
            databaseName = settings_1.settings.databaseName + "-debug";
            userCollectionName = settings_1.settings.userCollectionName + "-debug";
        }
        let db = yield getClient();
        let dbo = db.db(databaseName);
        dbo.collection(userCollectionName).deleteOne({ _id: new MongoClient.ObjectID(userID) }, (err, res) => {
            if (err)
                console.log(err);
            else {
                console.log("document deleted");
            }
            db.close();
        });
    });
}
exports.deleteUser = deleteUser;
/**
 * Login the user
 * @param userName Username to login
 * @param password password
 * @returns user id if login success
 */
function login(userName, password, debug = false) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
            let databaseName = settings_1.settings.databaseName;
            let userCollectionName = settings_1.settings.userCollectionName;
            if (debug) {
                databaseName = settings_1.settings.databaseName + "-debug";
                userCollectionName = settings_1.settings.userCollectionName + "-debug";
            }
            let db = yield getClient();
            let dbo = db.db(databaseName);
            try {
                let docs = yield dbo.collection(userCollectionName)
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
                    let match = yield bcrypt.compare(password, docs[0].password);
                    if (match) {
                        resolve(docs[0]);
                    }
                    else {
                        reject("Wrong password");
                    }
                }
                else {
                    reject("Wrong password");
                }
            }
            catch (e) {
                console.log(e);
            }
            yield db.close();
        }));
    });
}
exports.login = login;
/**
 * Add friend to one's friend list
 * @param user User who want to add friend
 * @param friend friend to be added
 * @returns true if added
 */
function addFriend(user, friend, debug = false) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
            let databaseName = settings_1.settings.databaseName;
            let userCollectionName = settings_1.settings.userCollectionName;
            if (debug) {
                databaseName = settings_1.settings.databaseName + "-debug";
                userCollectionName = settings_1.settings.userCollectionName + "-debug";
            }
            let db = yield getClient();
            let dbo = db.db(databaseName);
            if (user._id && friend._id) {
                if (user._id == friend._id)
                    reject(false);
                dbo.collection(userCollectionName).updateOne({ _id: new MongoClient.ObjectID(user._id) }, { $addToSet: { friends: new MongoClient.ObjectID(friend._id) } }, (err, res) => {
                    if (err) {
                        console.log(err);
                        reject(false);
                    }
                    else {
                        dbo.collection(settings_1.settings.userCollectionName).updateOne({ _id: new MongoClient.ObjectID(friend._id) }, { $addToSet: { friends: new MongoClient.ObjectID(user._id) } }, (err, res) => {
                            if (err) {
                                console.log(err);
                                reject(false);
                            }
                            else {
                                console.log("friend added");
                                resolve(true);
                            }
                            db.close();
                        });
                    }
                });
            }
            else {
                db.close();
                console.log("No user id field");
                reject(false);
            }
        }));
    });
}
exports.addFriend = addFriend;
/**
 * Get user's friends
 * @param user user with id
 */
function getFriendList(user, debug = false) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
            let databaseName = settings_1.settings.databaseName;
            let userCollectionName = settings_1.settings.userCollectionName;
            if (debug) {
                databaseName = settings_1.settings.databaseName + "-debug";
                userCollectionName = settings_1.settings.userCollectionName + "-debug";
            }
            let db = yield getClient();
            let dbo = db.db(databaseName);
            if (user._id) {
                try {
                    let u = yield dbo.collection(userCollectionName).findOne({ _id: new MongoClient.ObjectID(user._id) });
                    if (u !== null) {
                        let friendsID = u.friends;
                        let friends = yield dbo.collection(userCollectionName).find({ _id: { $in: friendsID } }, { projection: { password: 0 } }).toArray();
                        resolve(friends);
                    }
                    else {
                        reject("getFriendList: No such user");
                    }
                }
                catch (err) {
                    reject(err);
                }
            }
            else {
                reject("User doesn't have id");
            }
            yield db.close();
        }));
    });
}
exports.getFriendList = getFriendList;
/**
 *  Search user by it user name.
 *  This will return a list of user which have the similar user name
 * @param userName User's user name
 * @param debug
 */
function searchPeople(userName, debug = false) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
            let databaseName = settings_1.settings.databaseName;
            let userCollectionName = settings_1.settings.userCollectionName;
            if (debug) {
                databaseName = settings_1.settings.databaseName + "-debug";
                userCollectionName = settings_1.settings.userCollectionName + "-debug";
            }
            let db = yield getClient();
            let dbo = db.db(databaseName);
            try {
                let userList = yield dbo.collection(userCollectionName).aggregate([
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
                resolve(userList);
            }
            catch (err) {
                reject(err);
            }
        }));
    });
}
exports.searchPeople = searchPeople;
/**
 * Get all feed by user. This should list feed belongs to user and user's friend
 * @param user
 * @param begin begins at index
 */
function getAllFeed(user, begin) {
    return __awaiter(this, void 0, void 0, function* () {
        let db = yield getClient();
        let dbo = db.db(settings_1.settings.databaseName);
        try {
            let u = yield dbo.collection(settings_1.settings.userCollectionName).findOne({ _id: new mongodb_1.ObjectId(user._id) });
            let friends = u.friends ? u.friends : [];
            let friendsObjs = friends.map((f) => new mongodb_1.ObjectId(f));
            return yield dbo.collection(settings_1.settings.feedCollectionName)
                .aggregate([
                {
                    '$match': {
                        'user': { $in: [new mongodb_1.ObjectId(user._id), ...friendsObjs] }
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
                },
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
                    }
                }
            ])
                .skip(begin)
                .limit(30)
                .toArray();
        }
        catch (e) {
            console.log(e);
        }
        return [];
    });
}
exports.getAllFeed = getAllFeed;
function writeFeed(feed) {
    return __awaiter(this, void 0, void 0, function* () {
        let db = yield getClient();
        let dbo = db.db(settings_1.settings.databaseName);
        try {
            let result = yield dbo.collection(settings_1.settings.feedCollectionName).insertOne(feed);
            return Object.assign(Object.assign({}, feed), { _id: result.insertedId.toHexString() });
        }
        catch (e) {
            console.log(e);
        }
        return;
    });
}
exports.writeFeed = writeFeed;
function deleteFeed(feed) {
    return __awaiter(this, void 0, void 0, function* () {
        let db = yield getClient();
        let dbo = db.db(settings_1.settings.databaseName);
        try {
            yield dbo.collection(settings_1.settings.feedCollectionName).deleteOne({ _id: new mongodb_1.ObjectId(feed._id) });
        }
        catch (e) {
            console.log(e);
        }
    });
}
exports.deleteFeed = deleteFeed;
/**
 * add like
 * @param feed User's feed
 * @param user user who press like
 */
function addFeedLike(feed, user) {
    return __awaiter(this, void 0, void 0, function* () {
        let db = yield getClient();
        let dbo = db.db(settings_1.settings.databaseName);
        try {
            yield dbo.collection(settings_1.settings.feedCollectionName).updateOne({ _id: new mongodb_1.ObjectId(feed._id) }, { $addToSet: { likes: user._id } });
        }
        catch (e) {
            console.log(e);
        }
    });
}
exports.addFeedLike = addFeedLike;
/**
 * remove like
 * @param feed User's feed
 * @param user user who press like
 */
function deleteFeedLike(feed, user) {
    return __awaiter(this, void 0, void 0, function* () {
        let db = yield getClient();
        let dbo = db.db(settings_1.settings.databaseName);
        try {
            yield dbo.collection(settings_1.settings.feedCollectionName).updateOne({ _id: new mongodb_1.ObjectId(feed._id) }, { $pull: { likes: user._id } });
        }
        catch (e) {
            console.log(e);
        }
    });
}
exports.deleteFeedLike = deleteFeedLike;
function writeComment(comment, feedID) {
    return __awaiter(this, void 0, void 0, function* () {
        let db = yield getClient();
        let dbo = db.db(settings_1.settings.databaseName);
        let objectID = new mongodb_1.ObjectId();
        try {
            let result = yield dbo
                .collection(settings_1.settings.feedCollectionName)
                .findOneAndUpdate({ _id: new mongodb_1.ObjectId(feedID) }, { $push: { comments: Object.assign({ _id: objectID }, comment) } });
            return objectID.toHexString();
        }
        catch (e) {
            console.log(e);
        }
        return;
    });
}
exports.writeComment = writeComment;
function deleteComment(comment, feedID) {
    return __awaiter(this, void 0, void 0, function* () {
        let db = yield getClient();
        let dbo = db.db(settings_1.settings.databaseName);
        try {
            yield dbo.collection(settings_1.settings.feedCollectionName).updateOne({ _id: new mongodb_1.ObjectId(feedID) }, { $pull: { comments: { _id: new mongodb_1.ObjectId(comment._id) } } });
        }
        catch (e) {
            console.log(e);
        }
    });
}
exports.deleteComment = deleteComment;
function uploadAvatar(imagePath, user) {
    return __awaiter(this, void 0, void 0, function* () {
        let db = yield getClient();
        let dbo = db.db(settings_1.settings.databaseName);
        try {
            let prevFile = yield dbo.collection(settings_1.settings.userCollectionName).findOne({ _id: new mongodb_1.ObjectId(user._id) });
            if (prevFile) {
                if (prevFile.avatar) {
                    let oldPath = path.join(__dirname, 'routes/uploads', path.basename(prevFile.avatar));
                    console.log("Remove path", oldPath);
                    fs.unlink(oldPath, (err) => console.log("delete error", err));
                }
            }
            yield dbo.collection(settings_1.settings.userCollectionName).updateOne({ _id: new mongodb_1.ObjectId(user._id) }, { $set: { 'avatar': imagePath } });
            console.log("Done updated", imagePath);
        }
        catch (e) {
            console.log(e);
        }
    });
}
exports.uploadAvatar = uploadAvatar;
//# sourceMappingURL=user.js.map
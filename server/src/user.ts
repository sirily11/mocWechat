import * as MongoClient from "mongodb"
import * as bcrypt from "bcrypt"
import { User } from './userObj';
import { settings } from "./settings/settings";

/**
 * Get mongodb client
 * @returns Mongodb client without database selected
 */
export function getClient(): Promise<MongoClient.MongoClient> {
    return new Promise((resolve, rejects) => {
        MongoClient.connect(settings.url, {
            useNewUrlParser: true,
            auth: { user: settings.userName, password: settings.password }
        }, (err, db) => {
            if (err) rejects(err)
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
        let databaseName = settings.databaseName
        let userCollectionName = settings.userCollectionName
        if (debug) {
            databaseName = settings.databaseName + "-debug"
            userCollectionName = settings.userCollectionName + "-debug"
        }

        let db = await getClient()
        let dbo = db.db(databaseName)
        dbo.createCollection(userCollectionName, (err, res) => {
            if (err) console.log(err)
            else {
                res.createIndex({ userName: "text" }, { unique: true }, (err, result) => {
                    if (err) reject(err)
                    else {
                        resolve()
                    }
                })
            }
            db.close()
        })
    })
}


export async function destroy(debug = false) {
    let databaseName = settings.databaseName
    if (debug) {
        databaseName = settings.databaseName + "-debug"
    }
    let db = await getClient()
    let dbo = db.db(databaseName)
    await dbo.dropDatabase()
    db.close()
}

/**
 * Create A new user
 * @param user User Object
 * @returns User ID
 */
export async function addUser(user: User, debug = false): Promise<string> {
    return new Promise(async (resolve, rejects) => {
        let databaseName = settings.databaseName
        let userCollectionName = settings.userCollectionName
        if (debug) {
            databaseName = settings.databaseName + "-debug"
            userCollectionName = settings.userCollectionName + "-debug"
        }

        let db = await getClient()
        let dbo = db.db(databaseName)

        let hashPassword = await bcrypt.hash(user.password, 10)
        user.password = hashPassword

        dbo.collection(userCollectionName).insertOne(user, (err, res) => {
            if (err) {
                if (err.errmsg && err.errmsg.includes("duplicate key error collection")) {
                    rejects("Username already exists")
                } else {
                    rejects(err)
                }
            }
            else {
                console.log("document inserted")
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
    let databaseName = settings.databaseName
    let userCollectionName = settings.userCollectionName
    if (debug) {
        databaseName = settings.databaseName + "-debug"
        userCollectionName = settings.userCollectionName + "-debug"
    }

    let db = await getClient()
    let dbo = db.db(databaseName)

    dbo.collection(userCollectionName).deleteOne({ _id: new MongoClient.ObjectID(userID) }, (err, res) => {
        if (err) console.log(err)
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
export async function login(userName: string, password: string, debug = false): Promise<string> {
    return new Promise(async (resolve, reject) => {
        let databaseName = settings.databaseName
        let userCollectionName = settings.userCollectionName
        if (debug) {
            databaseName = settings.databaseName + "-debug"
            userCollectionName = settings.userCollectionName + "-debug"
        }

        let db = await getClient()
        let dbo = db.db(databaseName)
        dbo.collection(userCollectionName).findOne({ userName: userName }, async (err, res: null | User) => {
            if (err) reject(err)
            else if (res === null) {
                reject("No such user")
            } else {
                if (res.password) {
                    let match = await bcrypt.compare(password, res.password)
                    if (match) {
                        resolve(res._id)
                    } else {
                        reject("Wrong password")
                    }
                }
            }
            db.close()
        })
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
        let databaseName = settings.databaseName
        let userCollectionName = settings.userCollectionName
        if (debug) {
            databaseName = settings.databaseName + "-debug"
            userCollectionName = settings.userCollectionName + "-debug"
        }
        let db = await getClient()
        let dbo = db.db(databaseName)
        if (user._id && friend._id) {
            if (user._id == friend._id) reject(false)

            dbo.collection(userCollectionName).updateOne({ _id: new MongoClient.ObjectID(user._id) }, { $addToSet: { friends: new MongoClient.ObjectID(friend._id) } }, (err, res) => {
                if (err) {
                    console.log(err)
                    reject(false)
                } else {
                    dbo.collection(settings.userCollectionName).updateOne({ _id: new MongoClient.ObjectID(friend._id) }, { $addToSet: { friends: new MongoClient.ObjectID(user._id) } }, (err, res) => {
                        if (err) {
                            console.log(err)
                            reject(false)
                        } else {
                            console.log("friend added")
                            resolve(true)
                        }
                        db.close()
                    })
                }

            })
        } else {
            db.close()
            console.log("No user id field")
            reject(false)
        }
    })

}

/**
 * Get user's friends
 * @param user user with id
 */
export async function getFriendList(user: User, debug = false): Promise<User[]> {
    return new Promise(async (resolve, reject) => {
        let databaseName = settings.databaseName
        let userCollectionName = settings.userCollectionName
        if (debug) {
            databaseName = settings.databaseName + "-debug"
            userCollectionName = settings.userCollectionName + "-debug"
        }
        let db = await getClient()
        let dbo = db.db(databaseName)
        if (user._id) {
            try {
                let u = await dbo.collection(userCollectionName).findOne({ _id: new MongoClient.ObjectID(user._id) })
                if (u !== null) {
                    let friendsID: string[] = u.friends
                    let friends: User[] = await dbo.collection(userCollectionName).find({ _id: { $in: friendsID } }, { projection: { password: 0 } }).toArray()
                    resolve(friends)
                } else {
                    reject("getFriendList: No such user")
                }

            } catch (err) {
                reject(err)
            }

        } else {
            reject("User doesn't have id")
        }
        db.close()
    })
}

/**
 *  Search user by it user name.
 *  This will return a list of user which have the similar user name
 * @param userName User's user name
 * @param debug 
 */
export async function searchPeople(userName: string, debug=false): Promise<User[]>{
    return new Promise(async (resolve, reject)=>{
        let databaseName = settings.databaseName
        let userCollectionName = settings.userCollectionName
        if (debug) {
            databaseName = settings.databaseName + "-debug"
            userCollectionName = settings.userCollectionName + "-debug"
        }
        let db = await getClient()
        let dbo = db.db(databaseName)
        try{
            console.log(userName)
            let userList : User[] = await dbo.collection(userCollectionName).find({userName: {$regex: userName}}, {projection: {password:0}}).limit(10).toArray()
            resolve(userList)
        } catch(err){
            reject(err)
        }
       
    })
}


// init().then(async () => {
//     let user: User = { _id: "5cfd13f2058e103c1a3160a2", userName: "h", password: "q", dateOfBirth: "1990", sex: "male" }
//     let user2: User = { _id: "5cfd224976f6e84a14dde3f6", userName: "ha", password: "q", dateOfBirth: "1990", sex: "male" }
//     let user3: User = { _id: "5cfd22568785e54a3459e334", userName: "haa", password: "q", dateOfBirth: "1990", sex: "male" }

//     // addUser(user3).then((id)=>{

//     // }).catch((err)=>{
//     //     console.log(err)
//     // })


//     // deleteUser("5cfc01b7d3bd2917fe38934b")
//     // login("h", "q").then((info)=>{
//     //     console.log(info)
//     // }).catch((err)=>{
//     //     console.log(err)
//     // })
//     // addFriend(user2, user3)
//     let list = await getFriendList(user2)
//     console.log(list)
// })

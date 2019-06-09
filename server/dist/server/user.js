"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const MongoClient = require("mongodb");
const bcrypt = require("bcrypt");
const settings_1 = require("./settings/settings");
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
function init() {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
            let db = yield getClient();
            let dbo = db.db(settings_1.settings.databaseName);
            dbo.createCollection(settings_1.settings.userCollectionName, (err, res) => {
                if (err)
                    console.log(err);
                else {
                    res.createIndex({ userName: 1 }, { unique: true }, (err, result) => {
                        if (err)
                            reject(err);
                        else {
                            resolve();
                        }
                    });
                }
                db.close();
            });
        }));
    });
}
exports.init = init;
function destroy() {
    return __awaiter(this, void 0, void 0, function* () {
        let db = yield getClient();
        let dbo = db.db(settings_1.settings.databaseName);
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
function addUser(user) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, rejects) => __awaiter(this, void 0, void 0, function* () {
            let db = yield getClient();
            let dbo = db.db(settings_1.settings.databaseName);
            let hashPassword = yield bcrypt.hash(user.password, 10);
            user.password = hashPassword;
            dbo.collection(settings_1.settings.userCollectionName).insertOne(user, (err, res) => {
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
                    resolve(res.insertedId.toHexString());
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
function deleteUser(userID) {
    return __awaiter(this, void 0, void 0, function* () {
        let db = yield getClient();
        let dbo = db.db(settings_1.settings.databaseName);
        dbo.collection(settings_1.settings.userCollectionName).deleteOne({ _id: new MongoClient.ObjectID(userID) }, (err, res) => {
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
 *
 * @param userName Username to login
 * @param password password
 * @returns user id if login success
 */
function login(userName, password) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
            let db = yield getClient();
            let dbo = db.db(settings_1.settings.databaseName);
            dbo.collection(settings_1.settings.userCollectionName).findOne({ userName: userName }, (err, res) => __awaiter(this, void 0, void 0, function* () {
                if (err)
                    reject(err);
                else if (res === null) {
                    reject("No such user");
                }
                else {
                    let match = yield bcrypt.compare(password, res.password);
                    if (match) {
                        resolve(res._id);
                    }
                    else {
                        reject("Wrong password");
                    }
                }
                db.close();
            }));
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
function addFriend(user, friend) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
            let db = yield getClient();
            let dbo = db.db(settings_1.settings.databaseName);
            if (user._id && friend._id) {
                if (user._id == friend._id)
                    reject(false);
                dbo.collection(settings_1.settings.userCollectionName).updateOne({ _id: new MongoClient.ObjectID(user._id) }, { $addToSet: { friends: new MongoClient.ObjectID(friend._id) } }, (err, res) => {
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
function getFriendList(user) {
    return __awaiter(this, void 0, void 0, function* () {
        return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
            let db = yield getClient();
            let dbo = db.db(settings_1.settings.databaseName);
            if (user._id) {
                try {
                    let u = yield dbo.collection(settings_1.settings.userCollectionName).findOne({ _id: new MongoClient.ObjectID(user._id) });
                    if (u !== null) {
                        resolve(u.friends);
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
            db.close();
        }));
    });
}
exports.getFriendList = getFriendList;
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
//# sourceMappingURL=user.js.map
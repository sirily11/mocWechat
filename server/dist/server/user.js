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
            });
        }));
    });
}
/**
 * Create A new user
 * @param user User Object
 * @returns string
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
            });
        }));
    });
}
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
        });
    });
}
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
                        resolve("login");
                    }
                    else {
                        reject("Wrong password");
                    }
                }
            }));
        }));
    });
}
init().then(() => {
    let user = { userName: "h", password: "q", dateOfBirth: "1990", sex: "male" };
    // addUser(user).then((id)=>{
    //     console.log(id)
    // }).catch((err)=>{
    //     console.log(err)
    // })
    // deleteUser("5cfc01b7d3bd2917fe38934b")
    login("h", "q").then((info) => {
        console.log(info);
    }).catch((err) => {
        console.log(err);
    });
});
//# sourceMappingURL=user.js.map
import * as MongoClient from "mongodb"
import * as bcrypt from "bcrypt"
import { User } from './userObj';
import { resolve } from "path";
import { rejects } from "assert";
import { settings } from "./settings/settings";

function getClient(): Promise<MongoClient.MongoClient> {
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

async function init(){
    return new Promise(async (resolve, reject)=>{
        let db = await getClient()
        let dbo = db.db(settings.databaseName)
        dbo.createCollection(settings.userCollectionName, (err, res)=>{
            if(err) console.log(err)
            else{
                res.createIndex({ userName: 1}, {unique: true}, (err, result)=>{
                    if(err) reject(err)
                    else{
                        resolve()
                    }
                })
            }
        })
    })
    
}

/**
 * Create A new user
 * @param user User Object
 * @returns string
 */
async function addUser(user: User) : Promise<string> {
    return new Promise(async (resolve, rejects) => {
        let db = await getClient()
        let dbo = db.db(settings.databaseName)

        let hashPassword = await bcrypt.hash(user.password, 10)
        user.password = hashPassword

        dbo.collection(settings.userCollectionName).insertOne(user, (err, res) => {
            if (err) {
                if(err.errmsg && err.errmsg.includes("duplicate key error collection")){
                    rejects("Username already exists")
                } else{
                    rejects(err)
                }
            }
            else {
                console.log("document inserted")
                resolve(res.insertedId.toHexString())
            }
        })
    })

}

/**
 * Delete a user
 * @param user User Object
 */
async function deleteUser(userID: string) {
    let db = await getClient()
    let dbo = db.db(settings.databaseName)

    dbo.collection(settings.userCollectionName).deleteOne({ _id: new MongoClient.ObjectID(userID) }, (err, res) => {
        if (err) console.log(err)
        else {
            console.log("document deleted")
        }
    })
}

async function login(userName: string, password: string){
    return new Promise(async (resolve, reject)=>{
        let db = await getClient()
        let dbo = db.db(settings.databaseName)
        dbo.collection(settings.userCollectionName).findOne({userName: userName}, async (err, res: null | User)=>{
            if(err) reject(err)
            else if(res === null){
                reject("No such user")
            } else{
                let match = await bcrypt.compare(password, res.password)
                if(match){
                    resolve("login")
                } else{
                    reject("Wrong password")
                }
            }
        })
    })
    

}

init().then(()=>{
    let user : User = { userName: "h", password: "q", dateOfBirth: "1990", sex: "male" }
    // addUser(user).then((id)=>{
    //     console.log(id)
    // }).catch((err)=>{
    //     console.log(err)
    // })
    // deleteUser("5cfc01b7d3bd2917fe38934b")
    login("h", "q").then((info)=>{
        console.log(info)
    }).catch((err)=>{
        console.log(err)
    })
})

import * as MongoClient from "mongodb"
import { settings } from "../settings/settings";
import { IMessage, Message } from '../models/message';
import * as admin from "firebase-admin";
import { User, IUser } from '../models/user';

const serviceAccount = require("./secrets/open-message-35cef-firebase-adminsdk-153vx-933e9b6c74.json");


export class Member {
    userId: string;
    websocket?: WebSocket;

    constructor(userId: string) {
        this.userId = userId;
        try {
            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount),
            });
        } catch (err) {
            console.log(err)
        }

    }

    /**
     * Websocket client
     * @param client Websocket client
     */
    addClient(client: WebSocket | any) {
        this.websocket = client
    }

    /**
     * Remove websocket client
     */
    removeClient() {
        this.websocket = undefined
    }

    /**
     * Send message to the current client
     * @param message Message
     */
    send(message: IMessage): Promise<any> {
        return new Promise((resolve, reject) => {
            if (this.websocket) {
                this.websocket.send(JSON.stringify(message))
                resolve()
            } else {
                reject()
            }
        })
    }

}


export class MessageQueue {
    queues: Map<string, Array<IMessage>>

    constructor() {
        this.queues = new Map()
        console.log("Waiting for mongodb container set up")

    }


    /**
     * Get if there is message in memory
     * @param receiver Receiver id
     */
    async hasMessageInMemory(receiver: string): Promise<boolean> {
        return new Promise(async (resolve, reject) => {
            let messages = this.queues.get(receiver)
            if (messages) {
                if (messages.length > 0) {
                    resolve(true)
                } else {
                    resolve(false)
                }
            }
            resolve(false)
        })
    }

    /**
     *  Get if there is message in database
     * @param receiver receiver id
     */
    async hasMessage(receiver: string): Promise<boolean> {
        return new Promise(async (resolve, reject) => {
            let message = await Message.findOne({ receiver: receiver }).exec()
            if (message) {
                resolve(true)
            } else {
                resolve(false)
            }
        })
    }

    /**
     * Add message to memory's queue
     * @param newMessage new message
     */
    async addMessageInMemory(newMessage: IMessage): Promise<boolean> {
        return new Promise((resolve, reject) => {
            let messages = this.queues.get(newMessage.receiver)
            if (messages) {
                messages.push(newMessage)
            } else {
                messages = [newMessage]
            }
            this.queues.set(newMessage.receiver, messages)
            resolve()
        })
    }

    /**
     * Add message to database. Also push notification
     * @param newMessage new message
     */
    async addMessage(newMessage: IMessage): Promise<boolean> {
        return new Promise(async (resolve, reject) => {
            let m = new Message({ ...newMessage })
            m = await m.save()

            let user = await User.findById(newMessage.receiver).exec()
            let userData: IUser = user?.toObject();
            if (userData.pushToken) {
                await admin.messaging().sendToDevice(userData.pushToken,
                    {
                        notification: {
                            title: `${userData.userName}`,
                            body: `${newMessage.messageBody}`
                        }
                    })
            }
            resolve()
        })
    }

    /**
     * Get message from memory and delete it
     * @param receiver receiver's id
     */
    async getMessageInMemory(receiver: string): Promise<IMessage> {
        return new Promise(async (resolve, reject) => {
            let messages = this.queues.get(receiver)
            if (messages) {
                let message = messages.shift()
                if (message) {
                    resolve(message)
                } else {
                    reject()
                }
            } else {
                reject()
            }
        })
    }

    /**
     * Get message from database and remove it from the list
     */
    async getMessage(receiver: string): Promise<IMessage> {
        return new Promise(async (resolve, reject) => {
            let message = await Message.findOneAndRemove({ receiver: receiver }).exec()
            if (message) {
                resolve(message);
            }
        })
    }
}

export function createNewMember(userID: string, members: Member[]): Member {
    for (let member of members) {
        if (member.userId == userID) {
            return member
        }
    }
    let member = new Member(userID)
    return member
}
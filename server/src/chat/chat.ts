import * as MongoClient from "mongodb"
import { settings } from "../settings/settings";

/**
 * Message object
 */
export interface Message {
    sender: string,
    receiver: string,
    messageBody: string,
    time: string
}



export class Member {
    userId: string;
    websocket?: WebSocket;

    constructor(userId: string) {
        this.userId = userId;
    }

    addClient(client: WebSocket | any) {
        this.websocket = client
    }

    removeClient() {
        this.websocket = undefined
    }

    send(message: Message): Promise<any> {
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
    queues: Map<string, Array<Message>>
    db: MongoClient.Db | undefined

    constructor() {
        this.queues = new Map()
        MongoClient.connect(settings.url, {
            useNewUrlParser: true,
            auth: { user: settings.userName, password: settings.password }
        }).then((db)=>{
            this.db = db.db(settings.databaseName)
        }).catch((err)=>{
            console.log(err)
        })
    }

    async deleteAll(){
        if(this.db){
           await this.db.dropDatabase()
        }
    }

    /**
     * Get if there is message in memory
     * @param receiver Receiver id
     */
    async hasMessageInMemory(receiver: string): Promise<boolean>{
        return new Promise(async (resolve, reject)=>{
            let messages = this.queues.get(receiver)
            if(messages){
                if(messages.length > 0){
                    resolve(true)
                } else{
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
    async hasMessage(receiver: string): Promise<boolean>{
        return new Promise(async (resolve, reject)=>{
            if(this.db){
                let a  = await this.db.collection(settings.messageCollectionName).find({receiver: receiver}).toArray()
                if(a.length > 0){
                    resolve(true)
                } else{
                    resolve(false)
                }
            }
        })
    }

    /**
     * Add message to memory's queue
     * @param newMessage new message
     */
    async addMessageInMemory(newMessage: Message): Promise<boolean> {
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
     * Add message to database
     * @param newMessage new message
     */
    async addMessage(newMessage: Message): Promise<boolean> {
        return new Promise((resolve, reject) => {
            if(this.db){
                this.db.collection(settings.messageCollectionName).insertOne(newMessage)
                resolve()
            } else{
                reject("No database")
            }
        })
    }

    /**
     * Get message from memory and delete it
     * @param receiver receiver's id
     */
    async getMessageInMemory(receiver: string): Promise<Message> {
        return new Promise(async (resolve, reject) => {
            let messages = this.queues.get(receiver)
            if(messages){
                let message = messages.shift()
                if(message){
                    resolve(message)
                } else{
                    reject()
                }
            } else{
                reject()
            }
        })
    }

    /**
     * Get message from database and remove it from the list
     */
    async getMessage(receiver: string): Promise<Message> {
        return new Promise(async (resolve, reject) => {
            if(this.db){
                let message  = await this.db.collection(settings.messageCollectionName).findOneAndDelete({receiver: receiver})
                resolve(message.value)
            } else{
                reject("No database")
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
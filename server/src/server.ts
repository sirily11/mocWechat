import * as express from 'express';
import * as http from 'http';
import * as WebSocket from 'ws';
import * as url from "url"
import * as cors from "cors"

import {User} from './userObj';
import {addUser, init, login, addFriend, getFriendList, searchPeople} from './user';
import {MessageQueue, Member, Message, createNewMember} from './chat/chat';
import {router} from "./routes/routes";



const app = express();
app.use(express.json());
app.use(cors());
app.use(router);
app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Headers', 'Content-type,Authorization');
    next();
});
app.use((err: any, req: any, res: any, next: any) => {
    if (err.name === 'UnauthorizedError') {
        res.status(401).send({err: "Invalid token"});
    }
});

//initialize a simple http server
const server = http.createServer(app);
//initialize the WebSocket server instance
const wss = new WebSocket.Server({server: server, path: ""});
// Message queue
const messageQueue = new MessageQueue();
// Members
let members: Member[] = [];


wss.on('connection', async (ws: WebSocket, req) => {
    let userID = "";
    if (req.url) {
        try {
            userID = url.parse(req.url, true).query.userID.toString();
            let member = createNewMember(userID, members);
            member.addClient(ws);
            if (!members.includes(member)) {
                console.log("Connecting user", userID);
                members.push(member);
                console.log("Number of online user", members.length)
            }
            /// send all messages in the message queue
            while (await messageQueue.hasMessage(member.userId)) {
                let message = await messageQueue.getMessage(member.userId);
                member.send(message)
            }
        } catch (err) {
            console.error(err);
        }
    }

    ws.on("close", () => {
        console.log("Connection close");
        for (let [i, member] of members.entries()) {
            if (member.userId === userID) {
                members.splice(i, 1);
                break
            }
        }
    });

    ws.on('message', async (msg: string) => {
        let message: Message = JSON.parse(msg);
        let sent = false;
        for (let member of members) {
            if (member.userId === message.receiver) {
                if (member.websocket) {
                    member.websocket.send(JSON.stringify(message));
                    console.log("Sent message");
                    sent = true;
                    break
                }
            }
        }
        if (!sent) {
            await messageQueue.addMessage(message);
            console.log("Receiver not online")
        }
        // let ret: Message = {
        //     receiver: message.sender,
        //     receiverName: message.receiver,
        //     sender: message.receiver,
        //     messageBody: message.messageBody + " ok",
        //     time: message.time
        // }

        // ws.send(JSON.stringify(ret))
    });
});


//start our server
server.listen(80, () => {
    console.log(`server start, waiting for database`);
});

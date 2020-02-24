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
const express = require("express");
const http = require("http");
const WebSocket = require("ws");
const url = require("url");
const cors = require("cors");
const chat_1 = require("./chat/chat");
const feed_routers_1 = require("./routers/feed_routers");
const user_routers_1 = require("./routers/user_routers");
const comment_routers_1 = require("./routers/comment_routers");
const mongoose = require("mongoose");
const settings_1 = require("./settings/settings");
const app = express();
app.use(express.json());
app.use(cors());
// app.use(fileUpload({ limits: { fileSize: 50 * 1024 * 1024 } }));
app.use(feed_routers_1.feedRouter);
app.use(comment_routers_1.router);
app.use(user_routers_1.router);
app.use('/message-uploads', express.static("message-uploads"));
app.use('/feed-uploads', express.static("feed-uploads"));
app.use('/avatar-uploads', express.static("avatar-uploads"));
app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Headers', 'Content-type,Authorization');
    next();
});
app.use((err, req, res, next) => {
    if (err.name === 'UnauthorizedError') {
        res.status(401).send({ err: "Invalid token" });
    }
});
/// Database connection
const connectWithRetry = () => {
    return mongoose.connect(settings_1.settings.url, { useNewUrlParser: true, dbName: "chatting" }, (err) => {
        if (err) {
            console.error('Failed to connect to mongo on startup - retrying in 5 sec', err);
            setTimeout(connectWithRetry, 5000);
        }
    });
};
setTimeout(connectWithRetry, 5000);
//initialize a simple http server
const server = http.createServer(app);
//initialize the WebSocket server instance
const wss = new WebSocket.Server({ server: server, path: "" });
// Message queue
const messageQueue = new chat_1.MessageQueue();
// Members
let members = [];
wss.on('connection', (ws, req) => __awaiter(void 0, void 0, void 0, function* () {
    let userID = "";
    if (req.url) {
        try {
            userID = url.parse(req.url, true).query.userID.toString();
            let member = chat_1.createNewMember(userID, members);
            member.addClient(ws);
            if (!members.includes(member)) {
                console.log("Connecting user", userID);
                members.push(member);
                console.log("Number of online user", members.length);
            }
            /// send all messages in the message queue
            while (yield messageQueue.hasMessage(member.userId)) {
                let message = yield messageQueue.getMessage(member.userId);
                member.send(message);
            }
        }
        catch (err) {
            console.error(err);
        }
    }
    ws.on("close", () => {
        console.log("Connection close");
        for (let [i, member] of members.entries()) {
            if (member.userId === userID) {
                members.splice(i, 1);
                break;
            }
        }
    });
    ws.on('message', (msg) => __awaiter(void 0, void 0, void 0, function* () {
        let message = JSON.parse(msg);
        console.log(message);
        let sent = false;
        for (let member of members) {
            if (member.userId === message.receiver) {
                if (member.websocket) {
                    member.websocket.send(JSON.stringify(message));
                    console.log("Sent message");
                    sent = true;
                    break;
                }
            }
        }
        if (!sent) {
            yield messageQueue.addMessage(message);
            console.log("Receiver not online");
        }
        // let ret: Message = {
        //     receiver: message.sender,
        //     receiverName: message.receiver,
        //     sender: message.receiver,
        //     messageBody: message.messageBody + " ok",
        //     time: message.time
        // }
        // ws.send(JSON.stringify(ret))
    }));
}));
//start our server
server.listen(80, () => {
    console.log(`server start, waiting for database`);
});
//# sourceMappingURL=server.js.map
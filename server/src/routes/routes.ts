import * as express from 'express';
import {User} from "../userObj";
import {
    addFeedLike,
    addFriend,
    addUser, deleteComment,
    deleteFeed, deleteFeedLike, getAllFeed,
    getFriendList,
    init,
    login,
    searchPeople, uploadAvatar, writeComment,
    writeFeed
} from "../user";
import * as cors from "cors";
import * as exjwt from "express-jwt";
import * as jwt from "jsonwebtoken";
import {settings} from "../settings/settings";
import set = Reflect.set;
import {Comment, Feed} from "../feed/feedObj";
import {ObjectId} from 'mongodb';
import {UploadedFile} from "express-fileupload";
import * as path from "path";

export const router = express.Router();
router.use(express.json());
router.use(cors());
const jwtMW = exjwt({
    secret: settings.secret
});


router.get("/", (req, res) => {
    res.send("Hello world a")
});

router.post("/add/user", async (req, res) => {
    let user: User = req.body;
    try {
        if (user.userName && user.password) {
            await init();
            let uid = await addUser({friends: [], ...user});
            let token = jwt.sign({_id: user._id, password: user.password}, settings.secret, {expiresIn: 3600 * 24 * 7});
            res.send({...user, userID: uid, friends: [], token: token});
        } else {
            res.send({err: "Invalid data"})
        }

    } catch (err) {
        res.status(400).send({err: err})
    }

});

router.post("/login", async (req, res) => {
    let userName: string = req.body.userName;
    let password: string = req.body.password;
    try {
        let user = await login(userName, password);
        let token = jwt.sign({_id: user._id, password: password}, settings.secret, {expiresIn: 3600 * 24 * 7});
        res.send({...user, userID: user._id, token: token})
    } catch (err) {
        console.log(err);
        res.status(400).send({err: err})
    }
});

router.post("/add/friend", jwtMW, async (req, res) => {
    // @ts-ignore
    let user: User = req.user;
    let friend: User = req.body.friend;
    try {
        let status = await addFriend(user, friend);
        res.send({status: status});
    } catch (err) {
        res.status(400).send({err: err})
    }
});

router.all("/feed", jwtMW, async (req, res) => {
    // @ts-ignore
    let user: User = req.user;
    let feed: Feed = {...req.body, user: new ObjectId(user._id)};

    try {
        if (req.method == "POST") {
            let result = await writeFeed(feed);
            res.send(result);
        } else if (req.method == "DELETE") {
            await deleteFeed(feed);
            res.send({status: "ok"})
        } else if (req.method == "GET") {
            let begin: string = req.query.begin;
            let feeds = await getAllFeed(user, begin ? parseInt(begin) : 0);
            res.send(feeds);
        }

    } catch (e) {
        res.status(400).send({err: e})

    }
});

router.all("/feed-like", jwtMW, async (req, res) => {
    // @ts-ignore
    let user: User = req.user;
    let feed: Feed = {...req.body, user: new ObjectId(user._id)};

    try {
        if (req.method == "POST") {
            await addFeedLike(feed, user);
        } else if (req.method == "DELETE") {
            await deleteFeedLike(feed, user);
        }
        res.send({status: "OK"})
    } catch (e) {
        res.status(400).send({err: e})

    }
});

router.all("/comment", jwtMW, async (req, res) => {
    // @ts-ignore
    let user: User = req.user;
    let comment: Comment = {...req.body, user: new ObjectId(user._id)};
    if (req.body.reply_to) {
        // @ts-ignore
        comment.reply_to = new ObjectId(req.body.reply_to);
    }
    let feedID: string = req.query.feedID;

    try {
        if (req.method == "POST") {
            let objectID = await writeComment(comment, feedID);
            res.send({...comment, _id: objectID})
        } else if (req.method == "DELETE") {
            await deleteComment(comment, feedID);
            res.send({status: "OK"})
        }

    } catch (e) {
        res.status(400).send({err: e})

    }
});


router.get("/get/friends", async (req, res) => {
    let userID: string = req.query.userID;
    try {
        // @ts-ignore
        let list: User[] = await getFriendList({_id: userID});
        list.forEach((u) => {
            u.userID = u._id
        });
        console.log(list);
        res.send(list)
    } catch (err) {
        res.send([])
    }
});

router.post("/upload/feed-image", jwtMW, async (req, res) => {
    try {
        if (!req.files) {
            res.send({
                status: false,
                message: 'No file uploaded'
            });
        } else {
            //Use the name of the input field (i.e. "avatar") to retrieve the uploaded file
            // @ts-ignore
            let files: UploadedFile[] = req.files;

            for (const f of files) {
                let p = path.join(__dirname, 'uploads', f.name);
                await f.mv(p);
            }


            //send response
            res.send({
                status: true,
                message: 'File is uploaded',
                data: files.map((f) => {
                    return {
                        size: f.size,
                        name: f.name,
                        path: path.join("static", f.name)
                    }
                })
            });
        }
    } catch (err) {
        res.status(500).send(err.toString());
    }
});

router.post("/upload/avatar", jwtMW, async (req, res) => {
    try {
        if (!req.files) {
            res.send({
                status: false,
                message: 'No file uploaded'
            });
        } else {
            //Use the name of the input field (i.e. "avatar") to retrieve the uploaded file
            // @ts-ignore
            let file: UploadedFile = req.files.avatar;
            let p = path.join(__dirname, 'uploads', file.name);
            let dbPath = path.join('static', file.name);
            // @ts-ignore
            await uploadAvatar(dbPath, req.user);
            await file.mv(p);

            //send response
            res.send({
                    status: true,
                    message: 'File is uploaded',
                    data: {

                        size: file.size,
                        name: file.name,
                        path: dbPath


                    }
                }
            );
        }
    } catch
        (err) {
        res.status(500).send(err.toString());
    }
})
;

router.patch("/update/info", jwtMW, (req, res) => {

});

router.get("/search/user", async (req, res) => {
    let userName: string = req.query.userName;
    try {
        let userList = await searchPeople(userName);
        userList.forEach((u) => {
            u.userID = u._id
        });
        res.send(userList)
    } catch (err) {
        res.send({err: err})
    }
});

router.get("/test", async (req, res) => {
    res.send("ok")
});

import * as express from 'express';
import {User} from "../userObj";
import {
    addFeedLike,
    addFriend,
    addUser,
    deleteFeed, deleteFeedLike,
    getFriendList,
    init,
    login,
    searchPeople,
    writeFeed
} from "../user";
import * as cors from "cors";
import * as exjwt from "express-jwt";
import * as jwt from "jsonwebtoken";
import {settings} from "../settings/settings";
import set = Reflect.set;
import {Feed} from "../feed/feedObj";

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
    let feed: Feed = {...req.body, user: user._id};

    try {
        if (req.method == "POST") {
            let result = await writeFeed(feed);
            res.send(result);
        } else if (req.method == "DELETE") {
            await deleteFeed(feed);
            res.send({status: "ok"})
        }

    } catch (e) {
        res.status(400).send({err: e})

    }
});

router.all("/feed-like", jwtMW, async (req, res) => {
    // @ts-ignore
    let user: User = req.user;
    let feed: Feed = {...req.body, user: user._id};

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

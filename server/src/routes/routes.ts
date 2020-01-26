import * as express from 'express';
import {User} from "../userObj";
import {addFriend, addUser, getFriendList, init, login, searchPeople} from "../user";
import * as cors from "cors";

export const router = express.Router();
router.use(express.json());
router.use(cors());

router.get("/", (req, res) => {
    res.send("Hello world a")
});

router.post("/add/user", async (req, res) => {
    let user: User = req.body;
    try {
        if (user.userName && user.password) {
            await init();
            let uid = await addUser({friends: [], ...user});
            res.send({...user, userID: uid, friends: []});
        } else {
            res.send({err: "Data not vaild"})
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
        console.log("Login");
        res.send({...user, userID: user._id})
    } catch (err) {
        console.log(err);
        res.status(400).send({err: err})
    }
});

router.post("/add/friend", async (req, res) => {
    console.log(req.body);
    let user: User = req.body.user;
    let friend: User = req.body.friend;
    try {
        let status = await addFriend(user, friend);
        res.send({status: status})
    } catch (err) {
        res.status(400).send({err: err})
    }
});

router.get("/get/friends", async (req, res) => {
    let userID: string = req.query.userID;
    try {
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

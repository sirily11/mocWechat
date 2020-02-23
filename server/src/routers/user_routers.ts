import * as express from 'express';
import * as cors from "cors";
import * as exjwt from "express-jwt";
import * as jwt from "jsonwebtoken";
import { settings } from "../settings/settings";
import * as  mongoose from "mongoose";
import * as bcrypt from "bcrypt"
import { IUser, User } from '../models/user';

export const router = express.Router();
router.use(express.json());
router.use(cors());
const jwtMW = exjwt({
    secret: settings.secret
});


router.get("/", async (req, res) => {
    res.send({ "status": "ok" })
})


router.post("/login", async (req, res) => {
    try {
        let data: IUser = req.body
        let user = await User.findOne({ userName: data.userName }).populate(
            {
                path: "friends", select: "userName dateOfBirth friends sex avatar", populate: {
                    path: "friends",
                    select: "userName"
                }
            }).exec()

        if (user) {
            let match = await bcrypt.compare(data.password, user.password);
            if (match) {
                let token = jwt.sign({ _id: user._id }, settings.secret, { expiresIn: 3600 * 24 * 7 });
                res.send({ ...user.toObject(), token: token })
            }
            res.status(403).send({ errmsg: "Wrong password" })
        }
        res.status(403).send({ errmsg: "User doesn't exist" })

    } catch (err) {
        console.error(err)
        res.status(500).send(err)
    }

})

router.post("/add/user", async (req, res) => {
    try {
        let data: IUser = req.body
        data.password = await bcrypt.hash(data.password, 10)
        let newUser = await new User({ ...data }).save()
        let token = jwt.sign({ _id: newUser._id }, settings.secret, { expiresIn: 3600 * 24 * 7 });
        res.send({ ...newUser.toObject(), token: token })
    } catch (err) {
        res.send(err)
    }

})

router.post("/add/friend", jwtMW, async (req, res) => {
    try {
        // @ts-ignore
        let u: IUser = req.user
        let friend = await User.findByIdAndUpdate(u._id, { $addToSet: { friends: req.body.friend } }, { new: true }).exec()
        await User.findOneAndUpdate(req.body.friend, { $addToSet: { friends: u._id } }, { new: true }).exec()

        if (friend) {
            res.send(friend.toObject())
        }
        res.status(500)
    } catch (err) {
        res.status(500).send(err)
    }
})

// router.get("/get/friends", jwtMW, async (req, res) => {
//     try {
//         // @ts-ignore
//         let user = await User.findById(req.user._id).select("friends").exec()
//         res.send(user?.toObject().friends)
//     } catch (err) {
//         res.status(500).send(err)
//     }
// })

router.post("/upload/avatar", jwtMW, async (req, res) => {

})

router.patch("/update/info", jwtMW, (req, res) => {

});

router.get("/search/user", async (req, res) => {
    try {
        let userName: string = req.query.userName;
        let users = await User.find({
            userName: {
                '$regex': userName
            }
        }).select("friends sex dateOfBirth userName avatar").populate("friends", "userName").exec()
        res.send(users.map((u) => u.toObject()))
    } catch (err) {
        res.status(500).send(err)
    }

});



import * as express from 'express';
import * as cors from "cors";
import * as exjwt from "express-jwt";
import * as jwt from "jsonwebtoken";
import { settings } from "../settings/settings";
import * as  mongoose from "mongoose";
import * as multer from "multer"
import * as fs from "fs"
import * as bcrypt from "bcrypt"
import { IUser, User } from '../models/user';

export const router = express.Router();
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, "./message-uploads/")
    },
    filename: (req, file, cb) => {
        //@ts-ignore
        let user: IUser = req.user;
        cb(null, new Date().toISOString() + "-message-" + user._id + file.originalname)
    }
})

const avatarStorage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, "./avatar-uploads/")
    },
    filename: (req, file, cb) => {
        //@ts-ignore
        let user: IUser = req.user;
        cb(null, new Date().toISOString() + "-avatar-" + user._id + file.originalname)
    }
})

const upload = multer({ storage: storage })
const avatarUpload = multer({ storage: avatarStorage })

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
                    select: "userName avatar"
                }
            }).exec()

        if (user) {
            let match = await bcrypt.compare(data.password, user.password);
            if (match) {
                let token = jwt.sign({ _id: user._id }, settings.secret, { expiresIn: 3600 * 24 * 265 });
                await User.findByIdAndUpdate(user._id, { pushToken: data.pushToken }).exec()
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
        let token = jwt.sign({ _id: newUser._id }, settings.secret, { expiresIn: 3600 * 24 * 365 });
        await User.findByIdAndUpdate(newUser._id, { pushToken: data.pushToken }).exec()
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

router.post("/upload/avatar", jwtMW, avatarUpload.single('avatar'), async (req, res) => {
    // @ts-ignore
    let u: IUser = req.user
    let oldUser = await User.findById(u._id).exec()
    if (oldUser && oldUser.toObject().avatar) {
        try{
            fs.unlinkSync(oldUser.toObject().avatar)
        } catch(err){
            
        }
      
    }
    let user = await User.findOneAndUpdate({ _id: u._id }, { avatar: req.file.path }).exec()
    res.send({ "path": req.file.path })
})



router.post("/upload/messageImage", jwtMW, upload.single('messageImage'),
    async (req, res) => {
        // @ts-ignore
        let u: IUser = req.user
        console.log(req.file)
        res.send({ "path": req.file.path })
    })

router.patch("/update/info", jwtMW, async (req, res) => {
    try {
        // @ts-ignore
        let u: IUser = req.user
        let userData: IUser = req.body

        let user = await User.findOneAndUpdate(
            { _id: u._id },
            { userName: userData.userName, sex: userData.sex, dateOfBirth: userData.dateOfBirth },
            { new: true }
        ).populate(
            {
                path: "friends", select: "userName dateOfBirth friends sex avatar", populate: {
                    path: "friends",
                    select: "userName"
                }
            }).exec()
        res.send(user?.toObject())
    } catch (err) {
        res.status(500).send(err)
    }
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



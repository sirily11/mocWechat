import * as express from 'express';
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
import {UploadedFile} from "express-fileupload";
import * as path from "path";
import * as fs from "fs";

export const router = express.Router();
router.use(express.json());
router.use(cors());
const jwtMW = exjwt({
    secret: settings.secret
});



router.all("/feed", jwtMW, async(res, req)=>{

})

router.all("/feed-like", jwtMW, async(res, req)=>{

})

router.all("/comment", jwtMW, async(res, req)=>{

})

router.post("/upload/feed-image", jwtMW, async(res, req)=>{
    
})
import * as express from 'express';
import * as cors from "cors";
import * as exjwt from "express-jwt";
import * as jwt from "jsonwebtoken";
import { settings } from "../settings/settings";
import { UploadedFile } from "express-fileupload";
import * as path from "path";
import * as fs from "fs";
import * as  mongoose from "mongoose";
import { IUser } from '../models/user';
import { Feed, IFeed } from '../models/feed';
import { IComment, Comment } from '../models/comment';

export const feedRouter = express.Router();
feedRouter.use(express.json());
feedRouter.use(cors());
const jwtMW = exjwt({
    secret: settings.secret
});



feedRouter.all("/feed", jwtMW, async (req, res) => {
    try {
        let feedData: IFeed = req.body
        //@ts-ignore
        let user: IUser = req.user
        if (req.method == "POST") {
            delete feedData._id;
            let feed = new Feed({ user: user._id, ...feedData })
            await feed.save()
            res.send(feed.toObject())
        } else if (req.method == "DELETE") {
            let feed = await Feed.findOneAndRemove({ _id: feedData._id, user: user._id }).exec()

            feed?.comments.forEach(async (c) => {
                console.log(c)
                await Comment.findByIdAndDelete(c._id).exec()
            })

            if (feed) {
                res.send({ status: "OK" })
            } else {
                res.send({ status: "not ok" })
            }

        } else if (req.method === "GET") {
            let feeds = await Feed.find({ user: user._id }, {}, { skip: parseInt(req.query.begin), limit: 20 }).sort({ "_id": -1 }).populate(
                {
                    path: "comments user", select: "userName content posted_time is_reply",
                    populate: { path: "user reply_to", select: "userName" }
                })


            res.send(feeds.map((f) => f.toObject()))
        }

    } catch (err) {
        res.send(err)
    }

})

feedRouter.all("/feed-like", jwtMW, async (req, res) => {
    try {
        let feedData: IFeed = req.body
        //@ts-ignore
        let user: IUser = req.user

        if (req.method === "POST") {
            let feed = await Feed.findByIdAndUpdate(feedData._id, { $addToSet: { likes: user._id } }, { new: true }).exec()
            if (feed) {
                res.send(feed.toObject())
            } else {
                res.status(404).send({ errmsg: "feed not found" })
            }
        } else if (req.method === "DELETE") {
            let feed = await Feed.findByIdAndUpdate(feedData._id, { $pull: { likes: user._id } }, { new: true }).exec()
            if (feed) {
                res.send(feed.toObject())
            } else {
                res.status(404).send({ errmsg: "feed not found" })
            }
        }
    } catch (err) {
        res.status(500).send(err)
    }
})

feedRouter.post("/comment", jwtMW, async (req, res) => {
    //@ts-ignore
    let user: IUser = req.user
    let commentData: IComment = req.body
    delete commentData._id;
    let feedID = req.query.feedID

    let comment = await new Comment({ ...commentData, user: user._id }).save()
    let feed = await Feed.findByIdAndUpdate(feedID, { $addToSet: { comments: comment._id } }, { new: true }).populate("user", "userName").exec()
    if (feed) {
        res.send(feed.toObject())
    } else {
        res.status(404)
    }

})

feedRouter.delete("/comment", jwtMW, async (req, res) => {
    //@ts-ignore
    let user: IUser = req.user
    let commentID = req.query.commentID
    let feedID = req.query.feedID

    let comment = Comment.findByIdAndDelete(commentID)
    let feed = await Feed.findByIdAndUpdate(feedID, { $pull: { comments: commentID } }, { new: true }).populate("user", "userName").exec()
    if (feed) {
        res.send(feed?.toObject())
    } else {
        res.status(404)
    }

})


feedRouter.post("/upload/feed-image", jwtMW, async (req, res) => {

})
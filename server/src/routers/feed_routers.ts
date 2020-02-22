import * as express from 'express';
import * as cors from "cors";
import * as exjwt from "express-jwt";
import * as jwt from "jsonwebtoken";
import { settings } from "../settings/settings";
import { UploadedFile } from "express-fileupload";
import * as path from "path";
import * as fs from "fs";
import * as  mongoose from "mongoose";

export const router = express.Router();
router.use(express.json());
router.use(cors());
const jwtMW = exjwt({
    secret: settings.secret
});



router.all("/feed", jwtMW, async (req, res) => {
    try {
        if (req.method == "POST") {

        } else if (req.method == "DELETE") {

        }
        res.send({ status: "OK" })
    } catch (err) {

    }

})

router.all("/feed-like", jwtMW, async (req, res) => {

})

router.all("/comment", jwtMW, async (req, res) => {

})

router.post("/upload/feed-image", jwtMW, async (req, res) => {

})
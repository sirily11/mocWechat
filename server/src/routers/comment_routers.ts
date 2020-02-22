import * as express from 'express';
import * as cors from "cors";
import * as exjwt from "express-jwt";
import * as jwt from "jsonwebtoken";
import { settings } from "../settings/settings";
import { UploadedFile } from "express-fileupload";
import * as path from "path";
import * as fs from "fs";

export const router = express.Router();
router.use(express.json());
router.use(cors());
const jwtMW = exjwt({
    secret: settings.secret
});



router.all("/comment", jwtMW, async (res, req) => {

})

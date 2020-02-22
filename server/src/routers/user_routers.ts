import * as express from 'express';
import * as cors from "cors";
import * as exjwt from "express-jwt";
import * as jwt from "jsonwebtoken";
import { settings } from "../settings/settings";
import * as  mongoose from "mongoose";

export const router = express.Router();
router.use(express.json());
router.use(cors());
const jwtMW = exjwt({
    secret: settings.secret
});



router.post("/login", async (res, req, next) => {

})

router.post("/add/user", async (res, req, next) => {


})

router.post("/add/friend", jwtMW, async (res, req, next) => {

})

router.get("/get/friends", jwtMW, async (res, req) => {

})

router.post("/upload/avatar", jwtMW, async (res, req) => {

})

router.patch("/update/info", jwtMW, (req, res) => {

});

router.get("/search/user", async (req, res) => {


});



import { IUser } from "./user";
import * as  mongoose from "mongoose";
import { Schema, Document } from "mongoose"


export interface Comment extends Document {
    content: string,
    user: IUser,
    posted_time: Date,
    is_reply: boolean,
    replay_to?: IUser
}

const commentSchema: Schema = new Schema({
    content: { type: String, default: "" },
    user: { type: mongoose.Types.ObjectId, ref: "User" },
    posted_time: { type: Date, required: true },
    is_reply: { type: Boolean, required: true },
    replay_to: { type: mongoose.Types.ObjectId, ref: "User" }
});

export default mongoose.model<IUser>('Comment', commentSchema);
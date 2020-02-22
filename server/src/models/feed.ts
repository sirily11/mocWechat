import { IUser } from "./user"
import { Comment, IComment } from './comment';
import * as  mongoose from "mongoose";
import { Schema, Document } from "mongoose"

export interface IFeed extends Document {
    user: IUser,
    content: string,
    likes: string[],
    images: string[],
    comments: IComment[],
    publish_date: Date
}


const feedSchema: Schema = new Schema({
    user: { type: mongoose.Types.ObjectId, required: true, ref: "User" },
    content: { type: String, required: true },
    likes: [{ type: mongoose.Types.ObjectId }],
    images: [{ type: String }],
    comments: [{ type: mongoose.Types.ObjectId, ref: "Comment" }],
    publish_date: { type: Date }
});

export const Feed = mongoose.model<IFeed>('Feed', feedSchema);



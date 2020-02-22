import { IUser } from "./user"
import { Comment } from "./comment"
import * as  mongoose from "mongoose";
import { Schema, Document } from "mongoose"

export interface Feed extends Document {
    user: IUser,
    content: string,
    likes: string[],
    images: string[],
    comments: Comment[],
    publish_date: Date
}


const feedSchema: Schema = new Schema({
    user: { type: mongoose.Types.ObjectId, required: true },
    content: { type: String, required: true },
    likes: [{ type: mongoose.Types.ObjectId }],
    images: [{ type: String }],
    comment: [{ type: mongoose.Types.ObjectId, ref: "Comment" }],
    publish_date: { type: Date, required: true }
});

export default mongoose.model<IUser>('Feed', feedSchema);



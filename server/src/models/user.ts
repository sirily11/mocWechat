import * as  mongoose from "mongoose";
import { Schema, Document } from "mongoose"

export interface IUser extends Document {
    userName: string
    password: string
    dateOfBirth: Date
    sex: string
    friends: IUser[]
}

const userSchema: Schema = new Schema({
    userName: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    dateOfBirth: { type: String, required: true },
    sex: { type: String, required: true },
    friends: [{ type: mongoose.Types.ObjectId, ref: "User" }]
});

export default mongoose.model<IUser>('User', userSchema);
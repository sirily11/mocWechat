import * as  mongoose from "mongoose";
import { Schema, Document } from "mongoose"

export interface IMessage extends Document {
    sender: string,
    receiver: string,
    receiverName: string,
    messageBody: string,
    time: string,
    messageType: "text" | "image" | "audio" | "video" | "url",

}

const messageSchema: Schema = new Schema({
    sender: { type: mongoose.Types.ObjectId, ref: "User", required: true },
    receiver: { type: mongoose.Types.ObjectId, ref: "User", required: true },
    receiverName: { type: String },
    messageBody: { type: String },
    time: { type: Date },
    messageType: { type: String, required: true },

});

export const Message = mongoose.model<IMessage>('Message', messageSchema);
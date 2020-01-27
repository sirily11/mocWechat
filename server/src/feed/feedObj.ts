import { User } from "../userObj";

export interface Feed{
    _id: string,
    id: string,
    user: User,
    content: string,
    likes: string[],
    images: string[],
    comments: Comment[],
    publish_date: Date
}

export interface Comment{
    _id: string,
    content: string,
    user: User,
    posted_time: Date,
    is_reply: boolean,
    reply_to?: User
}
export interface User {
    userName?: string;
    password?: string;
    userID?: string;
    dateOfBirth?: string;
    sex?: string;
}

export interface AddFriendRequest {
    user: {
        _id: string
    }
    friend: {
        _id: string
    }
}

export interface Message {
    sender: string,
    receiver: string,
    receiverName?: string,
    messageBody: string,
    time: string
}
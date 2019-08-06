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
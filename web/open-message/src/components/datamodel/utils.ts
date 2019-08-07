import axios from "axios"

export function getURL(path: string): string {
    let base = "http://localhost:7000/"
    return `${base}${path}`
}

export function getWebSocketURL(userID: string): string {
    let base = "ws://localhost:7000/"

    return `${base}?userID=${userID}`
}

export class NetworkManeger<T>{
    path: string;

    constructor(path: string) {
        this.path = path
    }

    async fetch(object?: T): Promise<T> {
        return new Promise(async (resolve, reject) => {
            try {
                let result = await axios.get(getURL(this.path), object)
                if (result.status === 200) {
                    let data: T = result.data
                    resolve(data)
                } else {
                    reject(result.data)
                }

            } catch (err) {
                reject(err)
            }

        })
    }

    async post(object: T): Promise<T> {
        return new Promise(async (resolve, reject) => {
            try {
                let result = await axios.post(getURL(this.path), object)
                if (result.status === 200) {
                    let data: T = result.data
                    resolve(data)
                } else {
                    reject(result.data)
                }
            } catch (err) {
                reject(err.response.data.err)
            }

        })
    }

}
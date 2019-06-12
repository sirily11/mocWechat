import { MessageQueue, Message } from '../chat/chat';

describe("test message queue", () => {

    let messageQueue: MessageQueue | undefined = undefined;
    beforeEach(() => {
        messageQueue = new MessageQueue()
    }, 1000)

    afterEach(async () => {
        if (messageQueue) {
            await messageQueue.deleteAll()
        }
    }, 1000)

    let messages: Message[] = [{
        sender: "sirily11",
        receiver: "liqiwei1111",
        messageBody: "Hello",
        time: "2019"
    }, {
        sender: "sirily11",
        receiver: "liqiwei1111",
        messageBody: "Hello2",
        time: "2019"
    }, {
        sender: "sirily11",
        receiver: "liqiwei1111",
        messageBody: "Hello3",
        time: "2019"
    }]

    test("Add message", async () => {
        if (messageQueue) {
            try {
                let l = 0
                for (let message of messages) {
                    await messageQueue.addMessage(message)
                    let m = messageQueue.queues.get(message.receiver)
                    l += 1
                    if (m) {
                        expect(m.length).toBe(l)
                    }
                }
            } catch (err) {
                console.log(err)
            }


        }
    })

    test("Get message", async () => {
        if (messageQueue) {
            try {
                for (let message of messages) {
                    await messageQueue.addMessage(message)
                }
                let length = messages.length
                for (let message of messages) {
                    let has = messageQueue.hasMessage(message.receiver)
                    let result = await messageQueue.getMessage(message.receiver)
                    length -= 1
                    expect(has).toBeTruthy()
                    expect(result).toBe(message)
                    let m = messageQueue.queues.get(message.receiver)
                    if (m) {
                        expect(m.length).toBe(length)
                    }
                }
                expect(await messageQueue.hasMessage(messages[0].receiver)).toBeFalsy()
            } catch (err) {
                console.log(err)
            }
        }

    })

})
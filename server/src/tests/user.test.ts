import { init, getClient, addUser, destroy, addFriend, getFriendList, login } from "../user";
import { User } from "../userObj";

describe("User test", () => {
    let user: User = { userName: "h", password: "q", dateOfBirth: "1990", sex: "male" }
    let user2: User = { userName: "ha", password: "q", dateOfBirth: "1990", sex: "male" }
    let user3: User = { userName: "haa", password: "q", dateOfBirth: "1990", sex: "male" }


    beforeEach(async () => {
        init(true)
    })

    afterEach(async ()=>{
        destroy(true)
    })

    test("Insert user", async () => {
        try {
            let uid1 = await addUser(user, true)
            let uid2 = await addUser(user2, true)
            expect(uid1).toBeDefined()
            expect(uid2).toBeDefined()
        } catch (err) {
            console.log(err)
        }
    })

    test("Insert duplicated user with same username", async ()=>{
        try{
            await addUser(user, true)
            await addUser(user, true)
        } catch(err){
            expect(err).toBe("Username already exists")
        }
    })

    test("Login", async ()=>{
        try{
            await addUser(user2, true)
            // let uid = await login(user.userName, user.password)
            // expect(uid).toBeDefined()
        } catch(err){
            expect(err).toBeNull()
        }
    })

    test("Insert duplicated user with same username", async ()=>{
        try{
            await addUser(user, true)
            await addUser(user, true)
        } catch(err){
            expect(err).toBe("Username already exists")
        }
    })

    test("Add friend", async()=>{
        try{
            let uid1 = await addUser(user, true)
            let uid2 = await addUser(user2, true)
            let uid3 = await addUser(user3, true)

            user._id = uid1
            user2._id = uid2
            user3._id = uid3

            await addFriend(user, user2, true)
            await addFriend(user, user3, true)

            let fl = await getFriendList(user, true)
            expect(fl.length).toBe(2)

            // let fl2 = await getFriendList(user2, true)
            // expect(fl2).toBeDefined()
            // expect(fl2.length).toBe(1)

        } catch(err){
            console.log(err)
        }
    })
})
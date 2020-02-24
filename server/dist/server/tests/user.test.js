"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const user_1 = require("../user");
describe("User test", () => {
    let user = { userName: "h", password: "q", dateOfBirth: "1990", sex: "male" };
    let user2 = { userName: "ha", password: "q", dateOfBirth: "1990", sex: "male" };
    let user3 = { userName: "haa", password: "q", dateOfBirth: "1990", sex: "male" };
    beforeEach(() => __awaiter(void 0, void 0, void 0, function* () {
        user_1.init(true);
    }));
    afterEach(() => __awaiter(void 0, void 0, void 0, function* () {
        user_1.destroy(true);
    }));
    test("Insert user", () => __awaiter(void 0, void 0, void 0, function* () {
        try {
            let uid1 = yield user_1.addUser(user, true);
            let uid2 = yield user_1.addUser(user2, true);
            expect(uid1).toBeDefined();
            expect(uid2).toBeDefined();
        }
        catch (err) {
            console.log(err);
        }
    }));
    test("Insert duplicated user with same username", () => __awaiter(void 0, void 0, void 0, function* () {
        try {
            yield user_1.addUser(user, true);
            yield user_1.addUser(user, true);
        }
        catch (err) {
            expect(err).toBe("Username already exists");
        }
    }));
    test("Login", () => __awaiter(void 0, void 0, void 0, function* () {
        try {
            yield user_1.addUser(user2, true);
            // let uid = await login(user.userName, user.password)
            // expect(uid).toBeDefined()
        }
        catch (err) {
            expect(err).toBeNull();
        }
    }));
    test("Insert duplicated user with same username", () => __awaiter(void 0, void 0, void 0, function* () {
        try {
            yield user_1.addUser(user, true);
            yield user_1.addUser(user, true);
        }
        catch (err) {
            expect(err).toBe("Username already exists");
        }
    }));
    test("Add friend", () => __awaiter(void 0, void 0, void 0, function* () {
        try {
            let uid1 = yield user_1.addUser(user, true);
            let uid2 = yield user_1.addUser(user2, true);
            let uid3 = yield user_1.addUser(user3, true);
            user._id = uid1;
            user2._id = uid2;
            user3._id = uid3;
            yield user_1.addFriend(user, user2, true);
            yield user_1.addFriend(user, user3, true);
            let fl = yield user_1.getFriendList(user, true);
            expect(fl.length).toBe(2);
            // let fl2 = await getFriendList(user2, true)
            // expect(fl2).toBeDefined()
            // expect(fl2.length).toBe(1)
        }
        catch (err) {
            console.log(err);
        }
    }));
});
//# sourceMappingURL=user.test.js.map
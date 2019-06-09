"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const user_1 = require("../user");
describe("User test", () => {
    let user = { userName: "h", password: "q", dateOfBirth: "1990", sex: "male" };
    let user2 = { userName: "ha", password: "q", dateOfBirth: "1990", sex: "male" };
    let user3 = { userName: "haa", password: "q", dateOfBirth: "1990", sex: "male" };
    beforeEach(() => __awaiter(this, void 0, void 0, function* () {
        user_1.init();
    }));
    afterEach(() => __awaiter(this, void 0, void 0, function* () {
        user_1.destroy();
    }));
    test("Insert user", () => __awaiter(this, void 0, void 0, function* () {
        try {
            let uid1 = yield user_1.addUser(user);
            let uid2 = yield user_1.addUser(user2);
            expect(uid1).toBeDefined();
            expect(uid2).toBeDefined();
        }
        catch (err) {
            console.log(err);
        }
    }));
    test("Insert duplicated user with same username", () => __awaiter(this, void 0, void 0, function* () {
        try {
            yield user_1.addUser(user);
            yield user_1.addUser(user);
        }
        catch (err) {
            expect(err).toBe("Username already exists");
        }
    }));
    test("Insert duplicated user with same username", () => __awaiter(this, void 0, void 0, function* () {
        try {
            yield user_1.addUser(user);
            yield user_1.addUser(user);
        }
        catch (err) {
            expect(err).toBe("Username already exists");
        }
    }));
    test("Add friend", () => __awaiter(this, void 0, void 0, function* () {
        try {
            let uid1 = yield user_1.addUser(user);
            let uid2 = yield user_1.addUser(user2);
            let uid3 = yield user_1.addUser(user3);
            user._id = uid1;
            user2._id = uid2;
            user3._id = uid3;
            yield user_1.addFriend(user, user2);
            yield user_1.addFriend(user, user3);
            let fl = yield user_1.getFriendList(user);
            expect(fl.length).toBe(2);
            let fl2 = yield user_1.getFriendList(user2);
            expect(fl2.length).toBe(1);
        }
        catch (err) {
            console.log(err);
        }
    }));
});
//# sourceMappingURL=user.test.js.map
import React, { Component } from "react";
import { User } from "../../../../../server/src/userObj";
import { NetworkManeger } from "./utils";
import { AddFriendRequest } from "./userObjects";

interface State {
  friends: User[];
  addFriend(friend: User): void;
}

interface Props {}

export default class FriendProvider extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      friends: [],
      addFriend: this.addFriend
    };
  }

  async componentDidMount() {
    setTimeout(async () => {
      try {
        let userID = localStorage.getItem("userID");
        let networkManager = new NetworkManeger<User[]>(
          "get/friends?userID=" + userID
        );
        let friends = await networkManager.fetch();
        this.setState({ friends });
      } catch (err) {
        console.log(err);
      }
    }, 100);
  }

  async addFriend(friend: User) {
    let networkManager = new NetworkManeger<AddFriendRequest>("add/friend");
    let userID = localStorage.getItem("userID");
    if (friend.userID && userID) {
      let f = await networkManager.post({
        user: { _id: userID },
        friend: { _id: friend.userID }
      });
    }
  }

  render() {
    return (
      <FriendContext.Provider value={this.state}>
        {this.props.children}
      </FriendContext.Provider>
    );
  }
}

const context: State = {
  friends: [],
  addFriend: (friend: User) => {}
};

export const FriendContext = React.createContext(context);

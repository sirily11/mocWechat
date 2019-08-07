import React, { Component } from "react";
import { User } from "../../../../../server/src/userObj";
import { NetworkManeger, getWebSocketURL } from "./utils";
import { AddFriendRequest, Message } from "./userObjects";

interface State {
  messages: Message[];
  addMessage(message: Message): void;
}

interface Props {}

export default class MessageProvider extends Component<Props, State> {
  ws?: WebSocket;
  constructor(props: Props) {
    super(props);
    this.state = {
      messages: [],
      addMessage: this.addMessage
    };
  }

  componentDidMount() {
    const userID = localStorage.getItem("userID");
    if (userID) {
      this.ws = new WebSocket(getWebSocketURL(userID));
      this.ws.onmessage = e => {
        let messages = this.state.messages;
        messages.push(JSON.parse(e.data));
        this.setState({ messages });
      };
    }
  }

  addMessage = async (message: Message) => {
    if (this.ws) {
      let messages = this.state.messages;
      messages.push(message);
      this.setState({ messages });
      this.ws.send(JSON.stringify(message));
    }
  };

  render() {
    return (
      <MessageContext.Provider value={this.state}>
        {this.props.children}
      </MessageContext.Provider>
    );
  }
}

const context: State = {
  messages: [],
  addMessage: (friend: Message) => {}
};

export const MessageContext = React.createContext(context);

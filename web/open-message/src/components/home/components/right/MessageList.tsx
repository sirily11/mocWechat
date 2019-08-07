import React, { useContext } from "react";
import { ListItem, ListItemText, List } from "@material-ui/core";
import { MessageContext } from "../../../datamodel/ChatModel";

import { UserContext } from "../../../datamodel/UserModel";
import AutoSizer from "react-virtualized-auto-sizer";
import { Message } from "../../../datamodel/userObjects";
import { Virtuoso } from "react-virtuoso";

import "./bubble.css";
import { FriendContext } from "../../../datamodel/FriendModel";

interface Props {
  virtuoso: any;
}

function MessageCeil(messages: Message[], index: number, style?: any) {
  const userContext = useContext(UserContext);
  const m = messages[index];
  return (
    <ListItem style={style} className="list-item">
      <p className={m.sender === userContext.userID ? `from-me` : "from-them"}>
        {m.messageBody}
      </p>
    </ListItem>
  );
}

export default function MessageList(props: Props) {
  const messageContext = useContext(MessageContext);
  //   const userContext = useContext(UserContext);
  const frinedContext = useContext(FriendContext);
  const messages = messageContext.messages.filter(
    m =>
      frinedContext.chattingUser &&
      (m.sender === frinedContext.chattingUser.userID ||
        m.receiver === frinedContext.chattingUser.userID)
  );
  return (
    <AutoSizer style={{ position: "absolute" }}>
      {({ height, width }) => (
        <Virtuoso
          style={{
            width: width,
            height: height - 140,
            overflowY: "auto",
            overflowX: "hidden"
          }}
          ref={props.virtuoso}
          totalCount={messages.length}
          item={index => MessageCeil(messages, index)}
        />
      )}
    </AutoSizer>
  );
}

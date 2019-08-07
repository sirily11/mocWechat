import React, { useContext, useRef } from "react";
import { FriendContext } from "../../../datamodel/FriendModel";
import { Paper, makeStyles } from "@material-ui/core";
import InputBox from "./Inputbox";
import MessageList from "./MessageList";
import { MessageContext } from "../../../datamodel/ChatModel";

export default function Chat() {
  const friendContext = useContext(FriendContext);
  const messageContext = useContext(MessageContext);
  const virtuoso = useRef(null);
  if (!friendContext.chattingUser) {
    return <div />;
  }
  return (
    <div id="right" className="w-100 h-100">
      <MessageList virtuoso={virtuoso} />
      <InputBox
        onSend={m => {
          messageContext.addMessage(m);
          setTimeout(() => {
            if (virtuoso) {
              (virtuoso as any).current.scrollToIndex(
                {
                  index: messageContext.messages.length + 1,
                  align: "start"
                },
                100
              );
            }
          });
        }}
      />
    </div>
  );
}

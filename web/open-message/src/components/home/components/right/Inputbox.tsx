import React, { useState, useContext } from "react";
import { makeStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import InputBase from "@material-ui/core/InputBase";
import Divider from "@material-ui/core/Divider";
import IconButton from "@material-ui/core/IconButton";
import MenuIcon from "@material-ui/icons/Menu";
import SendIcon from "@material-ui/icons/Send";
import DirectionsIcon from "@material-ui/icons/Directions";
import { Message } from "../../../datamodel/userObjects";
import { FriendContext } from "../../../datamodel/FriendModel";
import { UserContext } from "../../../datamodel/UserModel";

const useStyles = makeStyles({
  root: {
    display: "flex",
    position: "absolute",
    bottom: 80,
    alignItems: "center",
    width: "100%"
  },
  input: {
    marginLeft: 8,
    flex: 1
  },
  iconButton: {
    padding: 10
  },
  divider: {
    width: 1,
    height: 28,
    margin: 4
  }
});

interface Props {
  onSend?(message: Message): void;
}

export default function InputBox(props: Props) {
  const classes = useStyles();
  const friendContext = useContext(FriendContext);
  const userContext = useContext(UserContext);
  const [value, changeValue] = useState("");

  return (
    <Paper className={classes.root}>
      <InputBase
        className={classes.input}
        placeholder="Message……"
        value={value}
        onChange={e => {
          changeValue(e.target.value);
        }}
        inputProps={{ "aria-label": "search google maps" }}
      />
      <Divider className={classes.divider} />
      <IconButton
        color="primary"
        disabled={value === ""}
        className={classes.iconButton}
        aria-label="directions"
        onClick={async () => {
          if (
            props.onSend &&
            userContext.userID &&
            friendContext.chattingUser &&
            friendContext.chattingUser.userID
          ) {
            let d = new Date();
            let message: Message = {
              sender: userContext.userID,
              receiver: friendContext.chattingUser.userID,
              messageBody: value,
              receiverName: friendContext.chattingUser.userName,
              time: d.toUTCString()
            };
            await props.onSend(message);
          }
          changeValue("");
        }}
      >
        <SendIcon />
      </IconButton>
    </Paper>
  );
}

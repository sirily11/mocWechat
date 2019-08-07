import React, { useContext, useState } from "react";
import { FriendContext } from "../../../datamodel/FriendModel";
import { FixedSizeList as List } from "react-window";
import PeopleIcon from "@material-ui/icons/People";
import AutoSizer from "react-virtualized-auto-sizer";
import {
  ListItem,
  ListItemAvatar,
  ListItemText,
  Avatar,
  ListItemSecondaryAction
} from "@material-ui/core";


export default function FriendList() {
  const friendContext = useContext(FriendContext);
  const { friends, startChatting } = friendContext;

  return (
    <AutoSizer>
      {({ height, width }) => (
        <List
          height={height}
          itemCount={friends.length}
          itemSize={70}
          width={width}
        >
          {({ index, style }) => (
            <ListItem
              className="ml-2"
              style={style}
              button
              selected={
                friendContext.chattingUser &&
                friendContext.chattingUser.userID === friends[index].userID
              }
              onClick={() => {
                startChatting(friends[index]);
              }}
            >
              <ListItemAvatar>
                <Avatar>
                  <PeopleIcon />
                </Avatar>
              </ListItemAvatar>
              <ListItemText primary={friends[index].userName} />
            </ListItem>
          )}
        </List>
      )}
    </AutoSizer>
  );
}

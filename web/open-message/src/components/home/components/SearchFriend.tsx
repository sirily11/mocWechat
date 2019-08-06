import React, { useState, useContext } from "react";
import {
  Dialog,
  DialogTitle,
  TextField,
  DialogContent,
  List,
  ListItem,
  Avatar,
  ListItemText,
  ListItemAvatar,
  ListItemSecondaryAction
} from "@material-ui/core";
import { User } from "../../datamodel/userObjects";
import { NetworkManeger } from "../../datamodel/utils";
import PeopleIcon from "@material-ui/icons/People";
import { Button, Popup } from "semantic-ui-react";
import { FriendContext } from "../../datamodel/FriendModel";
import { UserContext } from "../../datamodel/UserModel";

interface Props {
  open: boolean;
  setOpen(open: boolean): void;
  onAdd?(friend: User): void;
}

async function SearchFriendUtil(userName: string, setFriends: any) {
  let network = new NetworkManeger<User[]>(`search/user?userName=${userName}`);
  let friends = await network.fetch();
  setFriends(friends);
}

export default function SearchFriend(props: Props) {
  const f: User[] = [];
  const [userName, setUserName] = useState("");
  const [friends, setFriends] = useState(f);
  const context = useContext(FriendContext);
  const userContext = useContext(UserContext);
  return (
    <Dialog
      open={props.open}
      onClose={() => {
        props.setOpen(false);
      }}
      fullWidth
    >
      <DialogTitle>Search Friend</DialogTitle>
      <DialogContent>
        <TextField
          fullWidth
          label="Friend Name"
          value={userName}
          onChange={e => {
            setUserName(e.target.value);
            if (e.target.value === "") {
              setFriends([]);
            } else {
              SearchFriendUtil(e.target.value, setFriends);
            }
          }}
        />
        <List>
          {friends
            .filter(f => f.userID !== userContext.userID)
            .map(f => {
              return (
                <ListItem key={f.userID}>
                  <ListItemAvatar>
                    <Avatar color="primary">
                      <PeopleIcon />
                    </Avatar>
                  </ListItemAvatar>
                  <ListItemText primary={f.userName} />
                  <ListItemSecondaryAction>
                    <Popup
                      trigger={<Button circular icon="info" color="twitter" />}
                    >
                      <Popup.Header>{f.userName}</Popup.Header>
                      <Popup.Content>
                        <div>{f.sex}</div>
                        <div>{f.dateOfBirth}</div>
                      </Popup.Content>
                    </Popup>
                    {!context.friends.includes(f) && (
                      <Button
                        circular
                        icon="add"
                        onClick={async () => {
                          await context.addFriend(f);
                          props.setOpen(false);
                        }}
                      />
                    )}
                  </ListItemSecondaryAction>
                </ListItem>
              );
            })}
        </List>
      </DialogContent>
    </Dialog>
  );
}

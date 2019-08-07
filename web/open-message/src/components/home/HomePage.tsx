import React, { useContext, useState } from "react";
import FriendProvider from "../datamodel/FriendModel";
import FriendList from "./components/left/FriendList";
import Chat from "./components/right/Chat";
import LeftPage from "./components/left/Left";
import {
  AppBar,
  makeStyles,
  Theme,
  createStyles,
  Toolbar,
  IconButton,
  Typography,
  Button
} from "@material-ui/core";
import { Grid, Divider, Icon } from "semantic-ui-react";
import AddIcon from "@material-ui/icons/Add";
import SearchFriend from "./components/SearchFriend";
import { UserContext } from "../datamodel/UserModel";
import { Redirect } from "react-router";
import MessageProvider from "../datamodel/ChatModel";

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    root: {
      flexGrow: 1,
      height: "100%",
      overflowY: "hidden"
    },
    menuButton: {
      marginRight: theme.spacing(2)
    },
    title: {
      flexGrow: 1,
      color: "white"
    }
  })
);

export default function HomePage() {
  const classes = useStyles();
  const [open, setOpen] = useState(false);
  let userContext = useContext(UserContext);
  if (!userContext.isLogin) {
    return <Redirect to="/" />;
  }
  return (
    <FriendProvider>
      <MessageProvider>
        <div className={classes.root}>
          <AppBar position="static">
            <Toolbar>
              <Typography variant="h6" className={classes.title}>
                Home
              </Typography>
              <Button
                style={{ color: "white" }}
                onClick={() => {
                  setOpen(true);
                }}
              >
                <Icon name="add" size="large" />
              </Button>
              <Button
                style={{ color: "white" }}
                onClick={() => {
                  userContext.signOut();
                }}
              >
                <Icon name="sign out" size="large" />
              </Button>
            </Toolbar>
          </AppBar>
          <Grid className="h-100 w-100 mt-1" divided>
            <Grid.Column mobile={16} tablet={6} computer={6} className="h-100">
              <LeftPage />
            </Grid.Column>
            <Grid.Column tablet={10} computer={10} className="h-100">
              <Chat />
            </Grid.Column>
          </Grid>
        </div>
        <SearchFriend open={open} setOpen={setOpen} />
      </MessageProvider>
    </FriendProvider>
  );
}

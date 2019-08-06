import React from "react";
import {
  Paper,
  BottomNavigation,
  BottomNavigationAction,
  makeStyles
} from "@material-ui/core";
import RestoreIcon from "@material-ui/icons/Restore";
import FavoriteIcon from "@material-ui/icons/Favorite";
import PeopleIcon from "@material-ui/icons/People";
import Chatroom from "./Chatroom";
import FriendList from "./FriendList";

const useStyles = makeStyles({
  root: {
    width: "100%",
    position: "absolute",
    bottom: "70px",
    left: 0
  }
});

function renderPage(index: number) {
  switch (index) {
    case 0:
      return <Chatroom />;
    case 1:
      return <FriendList />;
  }
}

export default function LeftPage() {
  const classes = useStyles();
  const [value, setValue] = React.useState(0);
  return (
    <div className="h-100 w-100">
      {renderPage(value)}
      <BottomNavigation
        className={classes.root}
        showLabels
        value={value}
        onChange={(event, newValue) => {
          setValue(newValue);
        }}
      >
        <BottomNavigationAction label="Message" icon={<RestoreIcon />} />
        <BottomNavigationAction label="Friends" icon={<PeopleIcon />} />
      </BottomNavigation>
    </div>
  );
}

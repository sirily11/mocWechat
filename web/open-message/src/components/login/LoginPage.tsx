import React, { useContext } from "react";
import CssBaseline from "@material-ui/core/CssBaseline";
import "semantic-ui-css/semantic.min.css";
import Grid from "@material-ui/core/Grid";
import { makeStyles } from "@material-ui/core/styles";
import { Login } from "./components/login";
import { SignUp } from "./components/signUp";
import "bootstrap/dist/css/bootstrap.css";
import { UserContext } from "../datamodel/UserModel";
import { Redirect } from "react-router";
const useStyles = makeStyles(theme => ({
  root: {
    height: "100vh"
  },
  image: {
    backgroundImage: "url(https://source.unsplash.com/random)",
    backgroundRepeat: "no-repeat",
    backgroundSize: "cover",
    backgroundPosition: "center"
  },
  paper: {
    margin: theme.spacing(8, 4),
    display: "flex",
    flexDirection: "column",
    alignItems: "center"
  },
  avatar: {
    margin: theme.spacing(1),
    backgroundColor: theme.palette.secondary.main
  },
  form: {
    width: "100%", // Fix IE 11 issue.
    marginTop: theme.spacing(1)
  },
  submit: {
    margin: theme.spacing(3, 0, 2)
  }
}));

export default function LoginPage() {
  const classes = useStyles();
  const context = useContext(UserContext);
  if (context.isLogin) {
    return <Redirect to="/home" />;
  }
  return (
    <Grid container component="main" className={classes.root}>
      <CssBaseline />
      <Grid item xs={false} sm={6} md={7} className={classes.image} />
      {context.status === "Sign Up" ? <SignUp /> : <Login />}
    </Grid>
  );
}

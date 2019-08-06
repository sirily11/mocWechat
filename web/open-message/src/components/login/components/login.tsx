import React, { useContext } from "react";
import Avatar from "@material-ui/core/Avatar";
import TextField from "@material-ui/core/TextField";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Checkbox from "@material-ui/core/Checkbox";
import Link from "@material-ui/core/Link";
import Paper from "@material-ui/core/Paper";
import "semantic-ui-css/semantic.min.css";
import Grid from "@material-ui/core/Grid";
import LockOutlinedIcon from "@material-ui/icons/LockOutlined";
import Typography from "@material-ui/core/Typography";
import { makeStyles } from "@material-ui/core/styles";
import { UserContext } from "../../datamodel/UserModel";
import { Button, Message } from "semantic-ui-react";
import { Collapse } from "@material-ui/core";

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

export function Login() {
  const classes = useStyles();
  const context = useContext(UserContext);
  return (
    <Grid item xs={12} sm={6} md={5} component={Paper} elevation={6} square>
      <div className={classes.paper}>
        <Avatar className={classes.avatar}>
          <LockOutlinedIcon />
        </Avatar>
        <Typography component="h1" variant="h5">
          Sign in
        </Typography>
        <div className={classes.form}>
          <TextField
            variant="outlined"
            margin="normal"
            required
            fullWidth
            label="User Name"
            name="email"
            autoFocus
            value={context.userName}
            onChange={e => {
              context.setUserName(e.target.value);
            }}
          />
          <TextField
            variant="outlined"
            margin="normal"
            required
            fullWidth
            name="password"
            label="Password"
            type="password"
            id="password"
            autoComplete="current-password"
            value={context.password}
            onChange={e => {
              context.setpassword(e.target.value);
            }}
          />
          <FormControlLabel
            control={<Checkbox value="remember" color="primary" />}
            label="Remember me"
          />
        </div>
        <Grid container>
          <Grid item>
            <Link
              href="#"
              variant="body2"
              onClick={() => {
                context.setStatus("Sign Up");
              }}
            >
              {"Don't have account? Sign Up"}
            </Link>
          </Grid>
        </Grid>
        <Button
          className="mt-3"
          color="red"
          onClick={() => {
            context.login();
          }}
        >
          Sign In
        </Button>
        <Collapse in={context.message !== undefined}>
          <Message className="mt-3" error content={context.message} />
        </Collapse>
      </div>
    </Grid>
  );
}

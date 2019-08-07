import React, { useContext, useState } from "react";
import Avatar from "@material-ui/core/Avatar";
import TextField from "@material-ui/core/TextField";
import Paper from "@material-ui/core/Paper";
import "semantic-ui-css/semantic.min.css";
import Grid from "@material-ui/core/Grid";
import LockOutlinedIcon from "@material-ui/icons/LockOutlined";
import Typography from "@material-ui/core/Typography";
import { makeStyles } from "@material-ui/core/styles";
import { Dropdown, Message } from "semantic-ui-react";
import {
  MuiPickersUtilsProvider,
  KeyboardDatePicker
} from "@material-ui/pickers";
import { UserContext } from "../../datamodel/UserModel";
import DateFnsUtils from "@date-io/date-fns";
import { Link, Collapse } from "@material-ui/core";
import { Button } from "semantic-ui-react";

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

const options = [
  { text: "Male", value: "male" },
  { text: "Female", value: "Female" }
];

export function SignUp() {
  const classes = useStyles();
  const context = useContext(UserContext);
  const [selectedDate, handleDateChange] = useState(new Date());

  return (
    <MuiPickersUtilsProvider utils={DateFnsUtils}>
      <Grid item xs={12} sm={6} md={5} component={Paper} elevation={6} square>
        <div className={classes.paper}>
          <Avatar className={classes.avatar}>
            <LockOutlinedIcon />
          </Avatar>
          <Typography component="h1" variant="h5">
            Sign Up
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
            <div className="row">
              <div className="col-6 d-flex">
                <Dropdown
                  className="my-auto"
                  placeholder="Select Sex"
                  fluid
                  selection
                  value={context.getState().sex}
                  options={options}
                  onChange={(e, { value }) => {
                    context.setSex(value as string);
                  }}
                />
              </div>
              <div className="col-6">
                <KeyboardDatePicker
                  margin="normal"
                  id="mui-pickers-date"
                  label="Date picker"
                  value={selectedDate}
                  format="yyyy-MM-dd"
                  onChange={(date, value) => {
                    if (date) {
                      handleDateChange(date);
                      context.setDateOfBirth(date.toUTCString());
                    }
                  }}
                  KeyboardButtonProps={{
                    "aria-label": "change date"
                  }}
                />
              </div>
            </div>
          </div>
          <Grid container>
            <Grid item>
              <Link
                href="#"
                variant="body2"
                onClick={() => {
                  context.setStatus("Login");
                }}
              >
                {"Sign In"}
              </Link>
            </Grid>
          </Grid>
          <Button
            className="mt-3"
            color="red"
            onClick={() => {
              context.signUp();
            }}
          >
            Sign Up
          </Button>
          <Collapse in={context.message !== undefined}>
            <Message className="mt-3" error content={context.message} />
          </Collapse>
        </div>
      </Grid>
    </MuiPickersUtilsProvider>
  );
}

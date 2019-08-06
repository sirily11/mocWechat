import React from "react";
import { HashRouter as Router, Route, Switch } from "react-router-dom";
import "./App.css";
import LoginPage from "./components/login/LoginPage";
import { ThemeProvider } from "@material-ui/styles";
import { createMuiTheme } from "@material-ui/core";
import { orange } from "@material-ui/core/colors";
import UserProvider from "./components/datamodel/UserModel";
import HomePage from "./components/home/HomePage";

const outerTheme = createMuiTheme({
  palette: {
    primary: {
      main: orange[500]
    }
  }
});

function App() {
  return (
    <ThemeProvider theme={outerTheme}>
      <UserProvider>
        <Router>
          <Switch>
            <Route exact path="/" component={LoginPage} />
          
            <Route path="/home" component={HomePage} />
          </Switch>
        </Router>
      </UserProvider>
    </ThemeProvider>
  );
}

export default App;

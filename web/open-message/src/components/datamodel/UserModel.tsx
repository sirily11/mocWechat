import React, { Component } from "react";
import { User } from "../../../../../server/src/userObj";
import { NetworkManeger } from "./utils";
import { da } from "date-fns/esm/locale";

interface State {
  status: "Sign Up" | "Login";
  isLogin: boolean;
  userName: string;
  password: string;
  userID?: string;
  sex?: string;
  dateOfBirth?: string;
  message?: string;
  login(): void;
  signUp(): void;
  signOut(): void;
  getState(): State;
  setUserName(userName: string): void;
  setpassword(password: string): void;
  setDateOfBirth(dateOfBirth: string): void;
  setSex(sex: string): void;
  setStatus(status: "Sign Up" | "Login"): void;
}

interface Props {}

export default class UserProvider extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      isLogin: false,
      status: "Login",
      userName: "",
      password: "",
      login: this.login,
      signUp: this.signUp,
      setDateOfBirth: this.setDateOfBirth,
      setSex: this.setSex,
      setpassword: this.setPassword,
      setUserName: this.setUserName,
      getState: this.getState,
      setStatus: this.setStatus,
      dateOfBirth: new Date().toUTCString(),
      signOut: this.signOut
    };
  }

  componentDidMount() {
    let userID = localStorage.getItem("userID");
    if (userID) {
      this.setState({ userID: userID, isLogin: true });
    }
  }

  getState = () => {
    return this.state;
  };

  setStatus = (status: "Sign Up" | "Login") => {
    this.setState({ status });
  };

  setUserName = (userName: string) => {
    this.setState({ userName: userName, message: undefined });
  };

  setPassword = (password: string) => {
    this.setState({ password, message: undefined });
  };

  login = async () => {
    const { userName, password } = this.state;
    if (userName === "" || password === "") {
      this.setState({ message: "password or username should not be null" });
      return;
    }
    try {
      let networkManager = new NetworkManeger<User>("login");
      let user = await networkManager.post({
        userName: userName,
        password: password
      });
      this.setState({ userID: user.userID, isLogin: true });
      localStorage.setItem("userID", user.userID ? user.userID : "");
    } catch (err) {
      console.log(err);
      this.setState({
        message: err
      });
    }
  };

  signOut = () => {
    localStorage.removeItem("userID");
    this.setState({ isLogin: false });
  };

  signUp = async () => {
    const { userName, password, sex, dateOfBirth } = this.state;
    console.log(this.state);
    if (
      userName === "" ||
      password === "" ||
      dateOfBirth === undefined ||
      sex === undefined
    ) {
      this.setState({ message: "password or username should not be null" });
      return;
    }
    try {
      let networkManager = new NetworkManeger<User>("add/user");
      let user = await networkManager.post({
        userName,
        password,
        dateOfBirth,
        sex
      });
      this.setState({ userID: user.userID, isLogin: true });
      console.log(user);
      localStorage.setItem("userID", user.userID ? user.userID : "");
    } catch (err) {
      this.setState({
        message: err
      });
    }
  };

  setDateOfBirth = (dateOfBirth: string) => {
    console.log(dateOfBirth);
    this.setState({ dateOfBirth: dateOfBirth });
  };

  setSex = (sex: string) => {
    this.setState({ sex: sex });
  };

  render() {
    return (
      <UserContext.Provider value={this.state}>
        {this.props.children}
      </UserContext.Provider>
    );
  }
}

const context: State = {
  isLogin: false,
  status: "Login",
  userName: "",
  password: "",
  login: () => {},
  signUp: () => {},
  setDateOfBirth: () => {},
  setSex: () => {},
  setpassword: () => {},
  setUserName: () => {},
  getState: () => context,
  setStatus: () => {},
  signOut: () => {}
};

export const UserContext = React.createContext(context);

//LandingPage.js

import React from "react";
import { Link } from "react-router-dom";

const LandingPage = () => {
  return (
    <div style={styles.container}>
      <h1>Welcome to Electrical Switch Simulation</h1>
      <p>Please login or register to continue.</p>
      <div style={styles.links}>
        <Link to="/login" style={styles.link}>
          Login
        </Link>
        <Link to="/register" style={styles.link}>
          Register
        </Link>
      </div>
    </div>
  );
};

const styles = {
  container: {
    textAlign: "center",
    padding: "50px",
  },
  links: {
    marginTop: "20px",
  },
  link: {
    margin: "0 10px",
    textDecoration: "none",
    color: "#007bff",
    fontSize: "18px",
  },
};

export default LandingPage;

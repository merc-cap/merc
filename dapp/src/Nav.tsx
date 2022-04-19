import { Box, Card, Link } from "@mui/material";
import { Link as RouterLink } from "react-router-dom";
import Mint from "./Mint";

const Nav = () => {
  return (
    <Box>
      <Link component={RouterLink} to="/">
        Home
      </Link>{" "}
      |{" "}
      <Link component={RouterLink} to="/docs">
        Docs
      </Link>{" "}
      |{" "}
      <Link component={RouterLink} to="/gauges">
        Gauges
      </Link>
    </Box>
  );
};

export default Nav;

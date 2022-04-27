import "./App.css";
import { ThemeProvider } from "@mui/material/styles";
import { theme } from "./theme";

import { Box, Container, CssBaseline, Link, Stack } from "@mui/material";
import Docs from "./Docs";
import Mint from "./Mint";
import {
  BrowserRouter,
  Outlet,
  Route,
  Routes,
  Link as RouterLink,
} from "react-router-dom";
import Home from "./Home";
import NoMatch from "./NoMatch";
import GaugeList from "./GaugeList";
import Gauge from "./Gauge";
import Nav from "./Nav";
import Header from "./Header";
import Web3App from "./Web3App";

function App() {
  return (
    <Web3App>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route index element={<Home />} />
            <Route path="docs" element={<Docs />} />
            <Route path="gauges" element={<GaugeList />} />
            <Route path="gauges/:id" element={<Gauge />} />
            <Route path="*" element={<NoMatch />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </Web3App>
  );
}

function Layout() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Container maxWidth="md">
        <Stack spacing={3} sx={{ my: 6 }}>
          <Header />
          <Nav />
          <Outlet />
        </Stack>
      </Container>
    </ThemeProvider>
  );
}

export default App;

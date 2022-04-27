import { createTheme } from "@mui/material";

const fontSize = 15;
const lineHeight = 2;

export const theme = createTheme({
  palette: {
    mode: "dark",
    primary: {
      main: "#F9DC5C",
    },
    secondary: {
      main: "#ED254E",
    },
    text: {
      primary: "#F4FFFD",
    },
    background: {
      default: "#111111",
      paper: "#191919",
    },
  },
  typography: {
    fontSize,
    // fontFamily: ['"Open Sans"', "sans-serif"].join(","),
    fontFamily: ['"Space Grotesk"', "sans-serif"].join(","),
    //
    h1: {
      fontSize: fontSize * 2,
      fontWeight: 700,
      lineHeight,
    },
    h2: {
      fontSize: fontSize * 1.5,
      fontWeight: 900,
      lineHeight,
    },
    h3: {
      fontSize: fontSize * 1.2,
      fontWeight: 700,
      lineHeight,
    },
    h4: {
      fontSize,
      lineHeight,
    },
    h5: {
      fontSize,
      lineHeight,
    },
    h6: {
      fontSize,
      lineHeight,
    },
    subtitle1: {
      fontSize,
      lineHeight,
    },
    subtitle2: {
      fontSize,
      lineHeight,
    },
  },
  components: {
    MuiCssBaseline: {
      styleOverrides: {
        body: {
          fontSize,
        },
        code: {
          fontFamily: "'Space Mono', monospace",
        },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: {
          textTransform: "unset",
        },
      },
    },
    MuiTab: {
      styleOverrides: {
        root: {
          textTransform: "unset",
        },
      },
    },
  },
});

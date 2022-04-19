import {
  Box,
  Button,
  Card,
  Grid,
  Stack,
  TextField,
  Typography,
} from "@mui/material";

const Mint = () => (
  <Card sx={{ p: 3 }}>
    <Stack spacing={2}>
      <Typography variant="h2">Mint a Gauge</Typography>

      <p>Current price: 2 MERC</p>

      <TextField
        id="tokenAddress"
        placeholder="0x..."
        label="Token Address"
        variant="outlined"
      />
      <Button variant="contained">Approve MERC</Button>

      {/* <FormControl>
      <InputLabel htmlFor="my-input">Token Address</InputLabel>
      <Input id="my-input" aria-describedby="my-helper-text" />
      <FormHelperText id="my-helper-text">
        We'll never share your email.
      </FormHelperText>
    </FormControl>{" "} */}
    </Stack>
  </Card>
);

export default Mint;

import { Box, Button, Card, Grid, Link, Typography } from "@mui/material";
import { useState } from "react";
import { Link as RouterLink } from "react-router-dom";
import { useAccount } from "wagmi";
import { WalletModal } from "./WalletModal";

const Header = () => {
  const [modalOpen, setModalOpen] = useState(false);

  const [{ data, error, loading }, disconnect] = useAccount({
    fetchEns: true,
  });
  return (
    <>
      <Box>
        <Grid container alignItems="baseline" justifyContent="space-between">
          <Grid item>
            <Typography variant="h1">MERC</Typography>
          </Grid>
          <Grid item>
            {data ? (
              <Button size="small" variant="outlined" onClick={disconnect}>
                Disconnect
              </Button>
            ) : (
              <Button
                size="small"
                color="secondary"
                variant="contained"
                onClick={() => setModalOpen(true)}
              >
                Connect Wallet
              </Button>
            )}
          </Grid>
        </Grid>
      </Box>
      <WalletModal
        open={modalOpen}
        handleClose={() => {
          setModalOpen(false);
        }}
      />
    </>
  );
};

export default Header;

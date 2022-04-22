import { Button, Card, Stack, TextField, Typography } from "@mui/material";
import { ethers } from "ethers";
import debounce from "lodash.debounce";
import { useState } from "react";
import ContractInfo from "./ContractInfo";

const Mint = () => {
  const [tokenAddress, setTokenAddress] = useState<string>();

  const debouncedSetTokenAddress = debounce(async (address: string) => {
    setTokenAddress(address);
  }, 500);

  const handleAddressChange = (
    ev: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    try {
      const address = ethers.utils.getAddress(ev.target.value.trim());
      debouncedSetTokenAddress(address);
    } catch (e: any) {
      if (e.code === "INVALID_ARGUMENT") {
        console.log("invalid");
        setTokenAddress(undefined);
      } else {
        throw e;
      }
    }
  };
  const mintDisabled = !tokenAddress;

  return (
    <Card sx={{ p: 6 }}>
      <Stack spacing={2}>
        <Typography variant="h2">Mint a Gauge</Typography>
        <p>Current price: 2 MERC</p>

        <TextField
          id="tokenAddress"
          placeholder="0x..."
          label="Token Address"
          variant="outlined"
          autoComplete="false"
          autoCorrect="false"
          onChange={handleAddressChange}
        />
        {tokenAddress && <ContractInfo address={tokenAddress} />}
        <Button disabled={mintDisabled} variant="contained">
          Create Gauge
        </Button>
      </Stack>
    </Card>
  );
};

export default Mint;

import {
  Box,
  Button,
  Grid,
  Link,
  Stack,
  Tab,
  Table,
  TableBody,
  TableCell,
  TableRow,
  Tabs,
  Typography,
} from "@mui/material";
import React, { useState } from "react";
import { useParams } from "react-router-dom";

type GaugeParams = {
  id: string;
};

function a11yProps(index: number) {
  return {
    id: `simple-tab-${index}`,
    "aria-controls": `simple-tabpanel-${index}`,
  };
}

const Gauge = () => {
  let { id } = useParams<GaugeParams>();

  const [value, setValue] = useState(0);

  const handleChange = (event: React.SyntheticEvent, newValue: number) => {
    setValue(newValue);
  };

  return (
    <Box sx={{ pt: 4 }}>
      <Grid container spacing={5}>
        <Grid item xs={12} sm={6}>
          <img
            className="rotate3D"
            src="/exampleNFT.svg"
            alt={`Gauge ${id}`}
            width="100%"
          />
        </Grid>
        <Grid item xs={12} sm={6}>
          <Typography variant="h1">mERC20 Staking Gauge</Typography>

          <Box sx={{ borderBottom: 1, borderColor: "divider" }}>
            <Tabs
              value={value}
              onChange={handleChange}
              aria-label="basic tabs example"
            >
              <Tab label="Rewards" {...a11yProps(0)} />
              <Tab label="Stake/Unstake" {...a11yProps(1)} />
              <Tab label="Gauge Weight" {...a11yProps(2)} />
            </Tabs>
          </Box>
          <Box sx={{ display: value === 0 ? "block" : "none" }}>
            <p>You have rewards to collect.</p>

            <Stack spacing={1}>
              <Button variant="contained" color="secondary">
                Claim all Rewards
              </Button>
              <Table size="small">
                <TableBody>
                  <TableRow>
                    <TableCell>Your MERC Rewards</TableCell>
                    <TableCell align="right">32.14 MERC</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Reward Value (USD)</TableCell>
                    <TableCell align="right">$97.12</TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </Stack>
          </Box>
          <Box sx={{ display: value === 1 ? "block" : "none" }}>
            <p>Stake mERC20 to the gauge to earn MERC rewards.</p>
            <Stack spacing={1}>
              <Button variant="contained">Stake mERC20</Button>
              <Button disabled={true} variant="outlined" color="secondary">
                Unstake mERC20
              </Button>

              <Table size="small">
                <TableBody>
                  <TableRow>
                    <TableCell>Staking APY</TableCell>
                    <TableCell align="right">3.1%</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Staking Token</TableCell>
                    <TableCell align="right">
                      <Link>mERC20</Link>
                    </TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Currently Staked</TableCell>
                    <TableCell align="right">1,000,102</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Staked Value (USD)</TableCell>
                    <TableCell align="right">$32.19M</TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </Stack>
          </Box>

          <Box sx={{ display: value === 2 ? "block" : "none" }}>
            <Stack spacing={1}>
              <p>
                Pledge MERC to the gauge to increase its weight and drive MERC
                yields to your stakers.
              </p>

              <Table size="small">
                <TableBody>
                  <TableRow>
                    <TableCell>Your pMERC</TableCell>
                    <TableCell align="right">11.2 MERC</TableCell>
                  </TableRow>
                </TableBody>
              </Table>

              <Button variant="contained">Pledge/Burn MERC</Button>
              <Button variant="outlined">Unpledge MERC</Button>

              <Table size="small">
                <TableBody>
                  <TableRow>
                    <TableCell>Reward Rate</TableCell>
                    <TableCell align="right">102 MERC/hr</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Weight %</TableCell>
                    <TableCell align="right">8.79%</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Weight</TableCell>
                    <TableCell align="right">878</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Pledged Weight</TableCell>
                    <TableCell align="right">125</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Permanent Weight</TableCell>
                    <TableCell align="right">758</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Burned:Pledged Ratio</TableCell>
                    <TableCell align="right">6.1</TableCell>
                  </TableRow>

                  <TableRow>
                    <TableCell>Owner</TableCell>
                    <TableCell align="right">
                      <Link>0x1234...afde</Link>
                    </TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>ID</TableCell>
                    <TableCell align="right">{id}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Market</TableCell>
                    <TableCell align="right">
                      <Link>OpenSea</Link>
                    </TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </Stack>
          </Box>
        </Grid>
      </Grid>
    </Box>
  );
};

export default Gauge;

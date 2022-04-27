import {
  Box,
  Card,
  Grid,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Typography,
} from "@mui/material";
import { useParams } from "react-router-dom";
import { useContract } from "wagmi";
import Mint from "./Mint";

type GaugeParams = {
  id: string;
};

const Gauge = () => {
  let { id } = useParams<GaugeParams>();

  return (
    <Box sx={{ pt: 6 }}>
      <Grid container spacing={5}>
        <Grid item sm={6}>
          <img
            className="rotate3D"
            src="/exampleNFT.svg"
            alt={`Gauge ${id}`}
            width="100%"
          />
        </Grid>
        <Grid item sm={6}>
          <Typography variant="h1">Gauge {id}</Typography>
          <Table size="small">
            <TableBody>
              <TableRow>
                <TableCell>ID</TableCell>
                <TableCell align="right">{id}</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>Total MERC</TableCell>
                <TableCell align="right">1234</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>Pledged MERC</TableCell>
                <TableCell align="right">999</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>Burned MERC</TableCell>
                <TableCell align="right">235</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>Owner</TableCell>
                <TableCell align="right">0x1234...afde</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>Staking Token</TableCell>
                <TableCell align="right">mERC-veMax</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>Staked</TableCell>
                <TableCell align="right">1,000,102</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>Staked (USD)</TableCell>
                <TableCell align="right">$32.19M</TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </Grid>
      </Grid>
    </Box>
  );
};

export default Gauge;

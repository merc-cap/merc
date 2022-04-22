import { Card } from "@mui/material";
import { useParams } from "react-router-dom";
import Mint from "./Mint";

type GaugeParams = {
  id: string;
};

const Gauge = () => {
  let { id } = useParams<GaugeParams>();

  return <div>{id}</div>;
};

export default Gauge;

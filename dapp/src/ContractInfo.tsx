import Alert from "@mui/material/Alert";
import AlertTitle from "@mui/material/AlertTitle";
import CircularProgress from "@mui/material/CircularProgress";
import { ethers } from "ethers";
import { useToken } from "wagmi";
import ExternalLink from "./ExternalLink";
import { useBlockExplorerUrl } from "./helpers";
import TokenImage from "./TokenImage";
interface Props {
  address: string;
}

const ContractInfo = (props: Props) => {
  const [{ data, error, loading }] = useToken({
    address: props.address,
  });
  const url = useBlockExplorerUrl(props.address);
  console.log(loading, error, data);

  if (props.address === ethers.constants.AddressZero) {
    return (
      <Alert severity="info" icon="🧑‍🌾">
        <AlertTitle>Farming Gauge</AlertTitle>
        Mint a special gauge for address 0x0. No one can stake, but you can
        pledge and burn MERC to build weight.
      </Alert>
    );
  }

  if (loading)
    return (
      <Alert severity="info" icon={<CircularProgress size={22} />}>
        Checking token address
      </Alert>
    );
  if (error) return <Alert severity="error">ERC-20 not found</Alert>;
  return (
    <Alert
      severity="success"
      icon={<TokenImage address={props.address} width={24} height={24} />}
    >
      <AlertTitle>{data?.symbol}</AlertTitle>
      Create a Gauge for{" "}
      {url ? (
        <ExternalLink href={url}>{data?.symbol}</ExternalLink>
      ) : (
        <span>
          {data?.symbol} ({data?.address})
        </span>
      )}
    </Alert>
  );
};

export default ContractInfo;

import { Img } from "react-image";
import { useToken } from "wagmi";

function urlForTokenImage(address: string) {
  return `https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/${address}/logo.png`;
}

type Props = {
  address: string;
  width: number;
  height: number;
};

const TokenImage = ({ address, width, height }: Props) => {
  const [{ data }] = useToken({ address: address });
  const src = urlForTokenImage(address);
  return (
    <Img
      src={[src]}
      width={width}
      height={height}
      alt={data?.symbol}
      unloader={<span>🌈</span>}
    />
  );

  // if (error) {
  //   return <span>??</span>;
  // } else {
  //   return <img src={src} alt={data?.symbol} width={width} height={height} />;
  // }
};

export default TokenImage;

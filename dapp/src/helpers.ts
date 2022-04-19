import { useNetwork } from "wagmi";
import { allChains } from "wagmi";

export function urlForTokenImage(address: string) {
  return `https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/${address}/logo.png`;
}

export function useBlockExplorerUrl(address: string) {
  const [{ data, error, loading }] = useNetwork();
  console.log(data, data.chain);
  if (data.chain) {
    const config = allChains.find((c) => c.id === data.chain?.id);
    if (config?.blockExplorers?.length) {
      const baseUrl = config.blockExplorers[0].url;
      return `${baseUrl}/address/${address}`;
    }
  }
  return null;
}

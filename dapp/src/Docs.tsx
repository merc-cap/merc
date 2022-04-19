import { Card, Typography } from "@mui/material";
import Box from "@mui/material/Box";

const Docs = () => (
  <Box sx={{ my: 6 }}>
    <Card sx={{ p: 3 }}>
      <Typography variant="h2">Overview</Typography>

      <p>MERC is a protocol for tradeable, gauged rewards staking.</p>
      <p>
        A MERC gauge entitles the owner to incentivize liquidity using MERC
        rewards. You could build a market where people are growing and selling
        their own gauges to protocols.
      </p>

      <Typography variant="h2">Nuts &amp; Bolts</Typography>
      <p>MERC</p>
      <ul>
        <li>ERC-20 based on OpenZeppelin</li>
        <li>Available on Uniswap</li>
        <li>Linear supply increase over 400 years</li>
        <li>Initial supply: 100,000,000 MERC</li>
        <li>Max supply after 400 years: 1,000,000,000 MERC</li>
        <li>Supports flashloans; proceeds go to MERC Treasury.</li>
      </ul>

      <p>Gauge</p>
      <ul>
        <li>
          Each gauge is an ERC-721 NFT
          <ul>
            <li>Tradeable on NFT marketplaces</li>
            <li>Transferrable</li>
            <li>On-chain metadata / art</li>
          </ul>
        </li>
        <li>
          Each gauge has two associated ERC-4626 token vaults:
          <ul>
            <li>
              <code>MERC-&lt;tokenName&gt;</code>, e.g.{" "}
              <code>MERC-UST-FRAX-f</code>
            </li>
            <li>
              <code>P-MERC-&lt;tokenName&gt;</code>, e.g.{" "}
              <code>P-MERC-UST-FRAX-f</code>
            </li>
          </ul>
        </li>

        <li>Mint with an assigned staking token</li>
        <li>
          Mint fee:
          <ul>
            <li>
              Starts at 1 MERC and doubles every mint. Currently {"TODO"} MERC
            </li>
            <li>Mint revenue goes to MERC Treasury</li>
          </ul>
        </li>
      </ul>

      <p>MERC Treasury</p>
      <ul>
        <li>Limited governance</li>
        <li>Used to support and promote the protocol</li>
        <li>Multisig ownership</li>
      </ul>

      <p>Security</p>
      <ul>
        <li>Permissionless, non-upgradeable contracts</li>
        <li>Code4Arena Audit Contest - LINK</li>
      </ul>

      <Typography variant="h2">How to use MERC</Typography>
      <Typography variant="h3">Farmers</Typography>
      <p>DeFi is at war. CRV wars, PTP wars, TOKE wars, everything wars.</p>
      <p>
        How does the humble farmer plow yields in these turbulent times? Become
        a MERCenary with MERC.
      </p>
      <p>
        MERC sits on top of it all and lets farmers double-dip. Stake your FRAX
        in Curve, your fraxCrv in Convex or Yearn, then stake those tokens in a
        MERC gauge.
      </p>
      <Typography variant="h3">Protocols</Typography>
      <p>Protocols use MERC gauges to incentivize liquidity to any token.</p>
      <p>
        Want people to hold your shitcoin? Buy a MERC gauge and instant yield.
        MERC has a similar value-add as TOKE&mdash;buying it entitles you to
        rent liquidity using another token's rewards. However, instead of
        vote-locking and bribing votes, gauges are tradeable on NFT markets.
      </p>
      <p>Or sell your weighty gauge to the highest bidder.</p>
      {/* <p>Works great for:</p>
      <ul>
        <li>LP tokens</li>
        <li>Vault tokens (Yearn, Rari, any 4626 vault)</li>
      </ul>

      <p>Say you have a token you want to incentivize staking:</p>
      <ul>
        <li>Buy some MERC from Uniswap.</li>
        <li>
          Pay with MERC to mint a Gauge for an ERC-20 token for which you want
          to incentivize staking. Mint fee starts at 1 MERC and doubles with
          each mint.
        </li>
        <li>Your Gauge is a NFT. Sell it on any marketplace.</li>
      </ul> */}
    </Card>
  </Box>
);

export default Docs;

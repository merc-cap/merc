import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deploy, read, execute } = hre.deployments;
  const { deployer } = await hre.getNamedAccounts();

  const gauge = await hre.deployments.get("Gauge");

  const deployment = await deploy("Renderer", {
    from: deployer,
    log: true,
    args: [gauge.address],
  });

  const rendererAddress = await read("Gauge", {}, "renderer()");
  if (deployment.address !== rendererAddress) {
    await execute(
      "Gauge",
      { from: deployer, log: true },
      "setRenderer(address)",
      deployment.address
    );
  }
};

func.dependencies = ["Gauge"];
func.tags = ["Renderer"];
export default func;

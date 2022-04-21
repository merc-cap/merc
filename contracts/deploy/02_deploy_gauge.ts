import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deploy } = hre.deployments;
  const { deployer } = await hre.getNamedAccounts();

  const merc = await hre.deployments.get("Merc");

  await deploy("Gauge", {
    from: deployer,
    log: true,
    args: [merc.address],
  });
};

func.dependencies = ["Merc"];
func.tags = ["Gauge"];
export default func;

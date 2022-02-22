async function main() {
  const PNSFactory = await hre.ethers.getContractFactory("Domains");
  const PNS = await PNSFactory.deploy("cyber");
  await PNS.deployed();

  console.log("PNS deployed to:", PNS.address);

  let txn = null;
  txn = await PNS.registerDomain("secure", {
    value: hre.ethers.utils.parseEther("0.3"),
  });
  await txn.wait();

  const domainOwner = await PNS.getAddress("secure");
  console.log("Domain owner:", domainOwner);

  txn = await PNS.setRecord("secure", "Welcome to my domain!");
  await txn.wait();

  const balance = await hre.ethers.provider.getBalance(PNS.address);
  console.log("contract balance:", hre.ethers.utils.formatEther(balance));
}

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();

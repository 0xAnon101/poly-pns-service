async function main() {
  const [owner, randomPerson] = await hre.ethers.getSigners();
  const PNSFactory = await hre.ethers.getContractFactory("Domains");
  const PNS = await PNSFactory.deploy();
  await PNS.deployed();

  console.log("PNS deployed to:", PNS.address);
  console.log("Contract deployed by:", owner.address);

  let txn = null;
  txn = await PNS.registerDomain("doom");
  await txn.wait();

  const domainOwner = await PNS.getAddress("doom");
  console.log("Domain owner:", domainOwner);

  txn = await PNS.connect(randomPerson).setRecord(
    "doom",
    "Welcome to my domain!"
  );
  await txn.wait();
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

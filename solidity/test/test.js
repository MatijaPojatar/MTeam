const hre = require("hardhat");
const {
  TASK_TEST_RUN_SHOW_FORK_RECOMMENDATIONS,
} = require("hardhat/builtin-tasks/task-names");
describe("Yearn-view", function () {
  this.timeout(80000);
  let senderAcc;
  let yearnRegistry;
  let mainContractObj;
  before(async () => {
    const MainContract = await hre.ethers.getContractFactory("Mteam");
    mainContractObj = await MainContract.deploy(15);
    senderAcc = await hre.ethers.getSigners();
  });
  it("... should get pool liquidity", async () => {
    await mainContractObj
      .connect(senderAcc[0])
      .depositTokens({ value: 100000000 });
      await mainContractObj
      .connect(senderAcc[2])
      .depositTokens({ value: 100000000 });
      await mainContractObj
      .connect(senderAcc[3])
      .depositTokens({ value: 100000000 });
      await mainContractObj
      .connect(senderAcc[4])
      .depositTokens({ value: 100000000 });
      await mainContractObj
      .connect(senderAcc[5])
      .depositTokens({ value: 100000000 });
    await mainContractObj
      .connect(senderAcc[1])
      .depositTokens({ value: 100000000 });
      await mainContractObj
      .connect(senderAcc[6])
      .depositTokens({ value: 100000000 });
      await mainContractObj
      .connect(senderAcc[7])
      .depositTokens({ value: 100000000 });
      await mainContractObj
      .connect(senderAcc[8])
      .depositTokens({ value: 100000000 });
      await mainContractObj
      .connect(senderAcc[9])
      .depositTokens({ value: 100000000 });
    var millisecondsToWait = 1000;
    setTimeout(function () {}, millisecondsToWait);
    await mainContractObj.connect(senderAcc[8]).withdrawTokens();
    setTimeout(function () {}, millisecondsToWait);
    await mainContractObj.connect(senderAcc[1]).withdrawTokens();
    await mainContractObj.connect(senderAcc[2]).withdrawTokens();
    await mainContractObj.connect(senderAcc[3]).withdrawTokens();
    await mainContractObj.connect(senderAcc[4]).withdrawTokens();
    await mainContractObj.connect(senderAcc[5]).withdrawTokens();
    await mainContractObj.connect(senderAcc[6]).withdrawTokens();
    await mainContractObj.connect(senderAcc[7]).withdrawTokens();
    await mainContractObj.connect(senderAcc[9]).withdrawTokens();
    setTimeout(function () {}, 10000);
    await mainContractObj.connect(senderAcc[0]).withdrawTokens();
  });
});

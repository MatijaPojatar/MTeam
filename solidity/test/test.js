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
    mainContractObj = await MainContract.deploy(10);
    senderAcc = await hre.ethers.getSigners();
  });
  it("... should get pool liquidity", async () => {
    await mainContractObj
      .connect(senderAcc[0])
      .depositTokens({ value: 100000000 });
    await mainContractObj
      .connect(senderAcc[1])
      .depositTokens({ value: 100000000 });
    var millisecondsToWait = 1000;
    setTimeout(function () {}, millisecondsToWait);
    await mainContractObj.connect(senderAcc[0]).withdrawTokens();
    await mainContractObj.connect(senderAcc[1]).withdrawTokens();
  });
});

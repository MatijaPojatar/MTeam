const hre = require('hardhat');
describe('Yearn-view', function () {
    this.timeout(80000);
    let senderAcc;
    let yearnRegistry;
    let mainContractObj;
    before(async () => {
        const MainContract = await hre.ethers.getContractFactory("Mteam");
        mainContractObj = await MainContract.deploy(300);
        senderAcc = (await hre.ethers.getSigners());
    });
    it('... should get pool liquidity', async () => {
        await mainContractObj.connect(senderAcc[0]).depositTokens({value: 100000000});
        await mainContractObj.connect(senderAcc[1]).depositTokens({value: 100000000});
        await mainContractObj.connect(senderAcc[0]).withdrawTokens();
        await mainContractObj.connect(senderAcc[1]).withdrawTokens();
    });
});
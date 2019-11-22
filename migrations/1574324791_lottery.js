var Lottery = artifacts.require("./Lottery.sol");


module.exports = async function(deployer, networks, accounts) {
  // Use deployer to state migration tasks
  console.log(networks, accounts);
  await deployer.deploy(Lottery);
  const eth = 10**18
  let l = await Lottery.deployed();
  await l.bet(2, {from: accounts[0], value:eth})
  await l.bet(1, {from: accounts[1], value:2*eth})
  await l.bet(0, {from: accounts[2], value:3*eth})

  await l.bet(0, {from: accounts[3], value:2*eth})
  await l.bet(1, {from: accounts[4], value:3*eth})
  await l.bet(2, {from: accounts[5], value:1*eth})

};

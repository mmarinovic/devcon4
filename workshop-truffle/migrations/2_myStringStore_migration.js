var MyStringStore = artifacts.require("./MyStringStore.sol");

module.exports = function(deployer) {
  deployer.deploy(MyStringStore);
};

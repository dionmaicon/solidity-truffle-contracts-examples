const ConvertLib = artifacts.require("ConvertLib");
const MetaCoin = artifacts.require("MetaCoin");
const SimpleToken = artifacts.require("SimpleToken")
const DecentralizedExchange = artifacts.require("DecentralizedExchange")

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, MetaCoin);
  deployer.deploy(MetaCoin);
  deployer.deploy(SimpleToken)
  deployer.link(SimpleToken, DecentralizedExchange);
  deployer.deploy(DecentralizedExchange)
};

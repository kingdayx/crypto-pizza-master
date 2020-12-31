const CryptoPizza = artifacts.require('./CryptoPizza.sol')

module.exports = function (deployer) {
  deployer.deploy(CryptoPizza)
}

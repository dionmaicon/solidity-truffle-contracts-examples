/*eslint-disable*/
const SimpleToken = artifacts.require("./SimpleToken.sol");

require('chai')
  .use(require('chai-as-promised'))
  .should();

contract('SimpleToken', ([deployer, seller, buyer]) => {
  let simpleToken;

  before(async () => {
    simpleToken = await SimpleToken.deployed();
  })

  describe('deployment', async () => {
    it('deploys successfully', async () => {
      const address  = await simpleToken.address;
      assert.notEqual(address, 0x0);
      assert.notEqual(address, '');
      assert.notEqual(address, null);
      assert.notEqual(address, undefined);
    })

    it('has name', async () => {
      const name = await simpleToken.name()
      assert.equal(name, 'Simple Token');
    })
  })

})

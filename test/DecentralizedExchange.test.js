/*eslint-disable*/
const DecentralizedExchange = artifacts.require("./DecentralizedExchange.sol");

require('chai')
  .use(require('chai-as-promised'))
  .should();

contract('DecentralizedExchange', ([deployer, seller, buyer]) => {
  let dex;

  before(async () => {
    dex = await DecentralizedExchange.deployed();
  })

  describe('deployment', async () => {
    it('deploys successfully', async () => {
      const address  = await dex.address;
      assert.notEqual(address, 0x0);
      assert.notEqual(address, '');
      assert.notEqual(address, null);
      assert.notEqual(address, undefined);
    })

    it('has name', async () => {
      const name = await dex.name()
      assert.equal(name, 'Decentralized Exchange');
    })
  })


  describe('buy', async () => {
    it('Buy token', async () => {
      result =  await dex.buy({ from: buyer, value: 1});
      const event = result.logs[0].args;

      assert.equal(event.amount, 1 , 'Amount is correct');
    })
  })

})

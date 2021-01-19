import Web3 from 'web3'
import CryptoPizza from '../contracts/CryptoPizza.json'
import { contract } from '../lib/constants.js'

const createRandomPizza = (value, accounts) =>
  new Promise((resolve, reject) => {
    console.log(accounts)
    console.log(value)
    const web3 = new Web3(Web3.givenProvider)
    const account = accounts.toString()
    const todo = new web3.eth.Contract(CryptoPizza.abi, contract)

    console.log('account = ', account)

    // Calls the public `createRandomPizza` function from the smart contract
    todo.methods
      .createRandomPizza(value)
      .send({
        from: account,
        value: 7100000000000000,
        gas: 1000000,
        gasPrice: 1000000000,
        gasLimit: 1000000,
      })
      .on('error', reject)
      .on('receipt', resolve)
  })

export default createRandomPizza

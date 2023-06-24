import React, { useState, useEffect } from 'react'
import Web3 from 'web3'
import TraitBasedNFTABI from './TraitBasedNFT.json'

const contractABI = TraitBasedNFTABI.abi // Replace with your contract's ABI
const contractAddress = '0x6Ce95F6ad2451213c35909d4B651034D4Dc71f41' // Replace with your contract's address

function App() {
  const [web3, setWeb3] = useState(null)
  const [account, setAccount] = useState('')
  const [contract, setContract] = useState(null)
  const [quantity, setQuantity] = useState(1)
  const [trait, setTrait] = useState(1) // Setting the default trait to 1
  const [supply, setSupply] = useState({}) // Object to hold supply per trait

  const traitList = [1, 2] // Replace with your traits

  useEffect(() => {
    loadWeb3()
    loadBlockchainData()

    window.ethereum.on('accountsChanged', function (accounts) {
      setAccount(accounts[0])
    })
  }, [])

  const loadWeb3 = async () => {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum)
      await window.ethereum.enable()
      setWeb3(window.web3)
    }
  }

  const loadBlockchainData = async () => {
    const web3 = window.web3
    const accounts = await web3.eth.getAccounts()
    setAccount(accounts[0])

    const myContract = new web3.eth.Contract(contractABI, contractAddress)
    setContract(myContract)

    // Get the supply for each trait
    let traitSupply = {}
    for (let trait of traitList) {
      // Use getTraitTokenCount instead of traitToTokenIds
      const supply = await myContract.methods.getTraitTokenCount(trait).call()
      traitSupply[trait] = supply
    }
    setSupply(traitSupply)
  }

  const handlePlusButton = () => {
    if (quantity < 6) {
      setQuantity(quantity + 1)
    }
  }

  const handleMinusButton = () => {
    if (quantity > 0) {
      setQuantity(quantity - 1)
    }
  }

  const handleMint = async () => {
    const price = await contract.methods.price_1().call() // Update to your correct price retrieval method
    const cost = Web3.utils.toWei(price.toString(), 'ether') * quantity
    await contract.methods
      .mintWithTraitPublic(trait, quantity)
      .send({ from: account, value: cost })
  }

  return (
    <div>
      <h1>Mint Your NFT</h1>
      <h2>Quantity: {quantity}</h2>
      <button onClick={handlePlusButton}>+</button>
      <button onClick={handleMinusButton}>-</button>

      <h2>Trait: {trait}</h2>
      <select value={trait} onChange={(e) => setTrait(Number(e.target.value))}>
        {traitList.map((trait, index) => (
          <option key={index} value={trait}>
            {trait}
          </option>
        ))}
      </select>

      <button onClick={handleMint}>Mint NFT</button>

      <h2>Supply:</h2>
      {traitList.map((trait, index) => (
        <p key={index}>
          Trait {trait}: {supply[trait]}
        </p>
      ))}
    </div>
  )
}

export default App

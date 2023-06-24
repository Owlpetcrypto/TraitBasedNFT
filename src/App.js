import React, { useState, useEffect } from 'react'
import { ethers } from 'ethers'
import contractABI from './TraitBasedNFT.json'

function App() {
  const [provider, setProvider] = useState(null)
  const [contractInstance, setContractInstance] = useState(null)

  const [supplyA, setSupplyA] = useState(0)
  const [supplyB, setSupplyB] = useState(0)
  const [supplyC, setSupplyC] = useState(0)
  const [supplyD, setSupplyD] = useState(0)

  const [quantity, setQuantity] = useState(1)
  const [price, setPrice] = useState(0)

  const ZERO = ethers.parseEther('0')

  useEffect(() => {
    initialize()
  }, [])

  useEffect(() => {
    switch (quantity) {
      case 1:
        setPrice(ethers.parseEther('0.01'))
        break
      case 2:
      case 3:
        setPrice(ethers.parseEther('0.02'))
        break
      default:
        setPrice(ethers.parseEther('0.03'))
        break
    }
  }, [quantity])

  async function initialize() {
    try {
      await connectToProvider()
      await connectToContract()
      updateSupply()
    } catch (error) {
      console.error('Error initializing:', error)
    }
  }

  async function connectToProvider() {
    if (window.ethereum) {
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      await window.ethereum.request({ method: 'eth_requestAccounts' }) // Request user accounts
      setProvider(provider)
    } else {
      console.log('Please install MetaMask!')
    }
  }

  async function connectToContract() {
    if (provider) {
      const signer = provider.getSigner()
      const contractInstance = new ethers.Contract(
        '0x2F2E5631a0861D094CECB8d1a2633da3eD72ee97',
        contractABI.abi,
        signer,
      )
      setContractInstance(contractInstance)
    }
  }

  async function updateSupply() {
    if (contractInstance) {
      const redTraitSupply = await contractInstance.traitToTokenIds('red')
      setSupplyA(redTraitSupply.length)

      const blueTraitSupply = await contractInstance.traitToTokenIds('blue')
      setSupplyB(blueTraitSupply.length)

      const greenTraitSupply = await contractInstance.traitToTokenIds('green')
      setSupplyC(greenTraitSupply.length)

      const purpleTraitSupply = await contractInstance.traitToTokenIds('purple')
      setSupplyD(purpleTraitSupply.length)
    }
  }

  async function mint(trait, proof) {
    try {
      let tx
      const signerAddress = await provider.getSigner().getAddress()
      const userMintCount = await contractInstance.userMintCount(signerAddress)

      if (userMintCount === 1 && quantity === 1) {
        tx = await contractInstance.mintWithTraitOG(trait, quantity, proof, {
          value: ZERO,
        })
      } else {
        tx = await contractInstance.mintWithTraitOG(trait, quantity, proof, {
          value: price,
        })
      }

      await tx.wait()
      updateSupply()
    } catch (err) {
      console.error(err)
    }
  }

  async function getHardhatNetworkProvider() {
    if (typeof window.ethereum !== 'undefined') {
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      await provider.send('eth_requestAccounts', []) // Request user accounts
      return provider
    } else {
      console.log('Please install MetaMask!')
      return null
    }
  }

  return (
    <div>
      <p>Red Trait Supply: {supplyA}</p>
      <p>Blue Trait Supply: {supplyB}</p>
      <p>Green Trait Supply: {supplyC}</p>
      <p>Purple Trait Supply: {supplyD}</p>

      <select
        value={quantity}
        onChange={(e) => setQuantity(Number(e.target.value))}
      >
        <option value={1}>1</option>
        <option value={3}>3</option>
        <option value={6}>6</option>
      </select>

      <button onClick={() => mint('red', [])}>Mint Red Trait</button>
      <button onClick={() => mint('blue', [])}>Mint Blue Trait</button>
      <button onClick={() => mint('green', [])}>Mint Green Trait</button>
      <button onClick={() => mint('purple', [])}>Mint Purple Trait</button>
    </div>
  )
}

export default App

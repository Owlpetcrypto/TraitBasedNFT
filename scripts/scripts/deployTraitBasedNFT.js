async function main() {
  const [deployer] = await ethers.getSigners()

  console.log('Deploying contracts with the account:', deployer.address)

  const TraitBasedNFTFactory = await ethers.getContractFactory('TraitBasedNFT')
  const traitBasedNFT = await TraitBasedNFTFactory.deploy() // Add constructor arguments here if needed
  console.log('Contract deployed, instance:', traitBasedNFT)

  console.log('Waiting for transaction...')
  await traitBasedNFT.deployed()

  console.log(`Contract Address: ${traitBasedNFT.address}`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

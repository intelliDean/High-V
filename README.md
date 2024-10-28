# High-V
High-V is an event management and ticketing platform that manages your event from registration, checking in and also mint NFT to your event attendees as souvenir. It gives each event creator the power to manage their event from start till finish without the need for any intermediary - completely decentralized. It also help you manage your event data and statistic and save them on-chain. Whatever event you are planning, tech event, wedding event, bootcamp, tutorial, HIgh-V gats you.

## Description
This smart contract helps you in creating your event contract, and deploy it for you onchain, enabling you to manage your event yourself. The contract makes use of the Factory pattern architecture and also libraries to house the contract logic.

## Getting Started
```git clone https://github.com/intelliDean/High-V``` to clone the project. 
After cloning the project on Github, do the following to get the code running on your computer.

- Inside the project directory, in the terminal type: ```npm i``` to install all the necessary dependencies, including that of Hardhat
- When all of the dependencies are downloaded, in your terminal use ```npx hardhat vars set <THE ENVIROMENT VARIAVLES>```. e.g in the ```hardhat.config.ts``` file, you have something like this ```vars.get("SEPOLIA_URL")```, to set the SEPOLIA_URL environment variable type ```npx hardhat vars set SEPOLIA_URL``` in your terminal. This will set your SEPOLIA_URL. Do this for all your environment varibles needed. With this you won't need a .env file to avoid the mistake of pushing your secret key and other important information to GitHub.
- Once these are done, run ```npx hardhat compile``` to compile your smart contrat.
- If your smart contract compiled successfully, go ahead to deploy your contract by running this command ```npx hardhat run scripts/deploy.js --network sepolia``` or any network of your choice.
- After deployment, you can do whatever you want with your smart contract.
- You can also verify your smart contract by running this command: ```npx hardhat verify --network <THE NAME OF YOUR NETWORK e.g, sepolia> <YOUR CONTRACT ADDRESS> <IF YOUR CONTRACT HAS CONSTRUCTOR PARAMETERS PUT THEM HERE WITH SPACE AND NO COMMA>```

# Interraction

## HighVFactory
  - Verified: [0xC4D840Ec9dAf12395B35Db6FA6A37D703f7F9284](https://sepolia.etherscan.io/address/0xC4D840Ec9dAf12395B35Db6FA6A37D703f7F9284#code)


## HighVPay (In case you need an ERC20 contract for payment for your event)
- Verified: [0xE0fd265B43d5820957E1f0306f370Ca7f7dadf1F](https://sepolia.etherscan.io/address/0xE0fd265B43d5820957E1f0306f370Ca7f7dadf1F#code)

## Authors
Michael Dean Oyewole

## License
This project is licensed under the MIT License - see the LICENSE.md file for details



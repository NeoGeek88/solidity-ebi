# solidity-ebi

An ERC20 compatible token for coffee shop.

Code structure:
- ebi.sol: our main contract code
- IERC20.sol: ERC20 standard interface code file
- IERC20Metadata.sol: ERC20 standard interface code file
- Context.sol: ERC20 ultility functions

### Our contract on Goerli network:
Feel free to test our deployed smart contract in Goerli network! Our contract address is: https://goerli.etherscan.io/address/0xea9c8c88f8412e909a9356bd8567aa581298e7ea

---
# Deployment and testing Manual

## Remix IDE:

To compile and test the code, you need to download and install Remix IDE, or use the web version.

You can access the web version Remix IDE here: https://remix.ethereum.org/

or download the desktop version here: https://github.com/ethereum/remix-desktop/releases

For how to use the Remix IDE to compile, test and deploy the code, please refer to the official documentation: https://remix-ide.readthedocs.io/en/latest/


## Compile the smart contract:

To compile the EBI Token code, first you need to create a file in the Remix IDE and copy the code there.

You can do this in the Remix IDE File Explorer.

<img src="images/1.png" width="40%" />



Then you can go to Compiler and compile the code using the latest version of Compiler.

<img src="images/2.png" width="40%" />


## Deploy and test the smart contract locally:

To test the smart contract locally, you can deploy it to the Remix VM. Normally we will select Remix VM (London) for the test VM, and select one of the account from the list. The account you choose will become the contract owner after deploy. Additionally, the smart contract will need 4 parameters:

name_: The name of the token. (Our own contract uses "Ebi Token")

symbol_: The symbol of the token. (Our own contract uses "EBI")

handingRateNum: The tax percentage. (Our own contract uses 12, this can be changed later by calling "setHandlingRate" function)

tipRateNum: The tips percentage. (Our own contract uses 15, this can be changed later by calling "setTipRate" function)

<img src="images/3.png" width="40%" />


After deployment, you will be able to test all the functions in the generated contract at the bottom. To test the function, just put the required parameters,  and click the function name. Note that the account you choose earlier will be the one who actually call the function. Remember to change account to another one in order to test all functions.

<img src="images/4.png" width="40%" />


More specifically, function names showing in blue are read only functions, function names showing in orange are functions that will write or update data to the smart contract, and function names showing in red is payable functions, and you will need to specify the amount of Ether to pay when calling these functions.

To know more about each function's usage, please check the remark inside the code file.


## Deploy the smart contract to the test network or main network:

To deploy the smart contract to the test network or main network, first you have to prepare for a wallet and get some Ether.


### Prepare Metamask:

Metamask is one of the most popular software wallet to let you interact with Ethereum test and main network. To get the Metamask, you can go to https://metamask.io/ for more information.

After installing Metamask to your browser, you will have to create an account. Please follow the steps inside the Metamask to create one, and you will get an Ethereum address as your account.


### Get some Ether for contract deployment:

The smart contract deployment is also a transaction and will cost a lot of gas. The actual deployment for our smart contract will cost around 3.5M gas, which is around 0.05Ether (at ~20 gwei gas fee) if you want to deploy it to the Main network.

For the Goerli test network, you can get the test Ether from one of the Faucets listed in here: https://faucetlink.to/goerli


### Deploy to the test network or main network:

After you have done the preparation, you can go to Remix IDE, and in the Deploy page, select "Injected Provider - MetaMask" as your envionment. The MetaMask may pop up and ask you to sign to confirm the connection. Make sure you have selected the right network, and select the correct account to deploy the contract. If you want to deploy the contract to the test network but did not see any test networks, you can go to Metamask settings and enable "Show test networks" in the advanced tab.

<img src="images/13.png" width="40%" /><img src="images/5.png" width="40%" />

Then if everything is good you can click "Deploy" to proceed. MetaMask will pop up again and ask you to confirm the transaction. Double check all the information and click "Confirm" to confirm the transaction.

<img src="images/6.png" width="40%" />


Then after a while you should see your contract to be deployed. For the Goerli test network, you can check your account and contract status here: https://goerli.etherscan.io/, and for the Main network, you can check the information here: https://etherscan.io/


### Link the code to the contract in the etherscan.io:

After the deployment, you will be able to check the transaction and see the contract address on the Etherscan.

<img src="images/7.png" width="60%" />


But when you check the contract, you will see that the code is shown as ByteCode. To convert it to actual code and be able to test on Etherscan, you will have to Verify and Publish your code.

<img src="images/8.png" width="60%" />


To do this, you can click "Verify and Publish", and select your envionment and click "Continue".

<img src="images/9.png" width="50%" />


Next you will have to upload all your source code in here for verification. You can leave other area as default and click "Verify and Publish".

<img src="images/10.png" width="40%" />


If everything works fine, you will see the following message indicate that the code has been verified successfully.

<img src="images/11.png" width="60%" />


Then go back to the contract page, you will see that the code page is now showing actual code, plus the endpoint to let you read and write contract.

<img src="images/12.png" width="60%" />


## Test the smart contract:

To test functions inside the smart contract, simply go to "Read Contract" or "Write Contract", and then fill the needed parameter and execute it.
Functions in "Read Contract" are read-only functions and does not need a wallet connection. These functions will not create transaction.
However, functions in "Write Contract" will need a valid wallet connection and it will create transactions in order to execute the function. You will need to sign for every function call.

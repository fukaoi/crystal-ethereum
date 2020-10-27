# crystal-ethereum
[![Build Status](https://travis-ci.org/fukaoi/crystal-ethereum.svg?branch=master)](https://travis-ci.org/fukaoi/crystal-ethereum)

Client SDK for a ethereum,  Can doing about creates accounts, setting multisig, sends payment.
this SDK dependency is [web3.js](https://github.com/ethereum/web3.js), [crystal-nodejs](https://github.com/fukaoi/crystal-nodejs), [ReasonML](https://reasonml.github.io/). And no need to install Node.JS, web3.js of the npm module, Because of the function of crystal-nodejs. If you want to know crystal-nodejs, read README of crystal-nodejs

The main function as Account, Multisig, Payment has existed, there always run verify function after submit the transaction on ethereum network . So is the finallize response that return value of crystal-ethereum 

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     ethereum:
       github: fukaoi/crystal-ethereum
   ```

2. Run `shards install`

## NPM module installation

want to add npm module

1. Add the npm module to `js/package.json`

2. Run `make && make install`

## Audit NPM mobule and JS code

Scan npm module for vulnerability and Perform static analyze of js code for security

1. Run `make secure_check`

## Usage

### Account

#### Set up network(testnet or mainnet)

 Only once call set_network() in an application

```crystal
Ethereum.set_network(Ethereum::Network::Testnet)

or 

Ethereum.set_network(Ethereum::Network::Mainnet)
```

Connect to ethereum(infura.io) URL("https://ropsten.infura.io" or "https://mainnet.infura.io")in default, But want to change URL

>Warning: default url is for demo, don't use your product as it is.If this sdk will using that you should register new account from infura.io 

```crystal
Ethereum.set_network(Ethereum::Network::Testnet, "https://xxxxxxxxxxxxxxxxxxx")

or 

Ethereum.set_network(Ethereum::Network::Mainnet, "https://xxxxxxxxxxxxxxxxxxx")
```

#### Generate an account for mainnet

```crystal
require "ethereum"

Ethereum.set_network(Ethereum::Network::Mainnet)
Ethereum::Account.generate_account

# <Ethereum::Response::Account:0x7f689a4f19a0 
# @address="0x95aF794889DcC1D5dd7E62cdC602540799eBBbea", 
# @privateKey="0x4dace16e3056dc303ffa9944ff5211d483996487ca5f40fcc1474a1323b33372">
```

#### Generate an account for testnet

Can receive payment 0.5 ETH from testnet faucet when a created account

```crystal
require "ethereum"

Ethereum.set_network(Ethereum::Network::Testnet)
Ethereum::Account.generate_account

# [TESTNET]
# faucet success.
# <Ethereum::Response::Account:0x7f4face469a0 
# @address="0x55D88859124E37fD25F2AE2B9d063B490b4F48a7", 
# @privateKey="0x9159f5e67fc3859b25fe3ea2757e60e1537aab3f35e0351e8fb01c8371030470">
```

#### Get balance by address

```crystal
require "ethereum"

Ethereum::Account.get_balance("0x55D88859124E37fD25F2AE2B9d063B490b4F48a7")

# "0.5"
```

### Payment

#### Send payment

```crystal
require "ethereum"

from = {
  address: "0x75d5196ad433f4d2CC76Ebb5677437170f15Aa26",
  secret:  "0x2bb195c03c48967522c4ba374e1cb1973555c2a11fbecee571a1d487fd960e27",
}
to = "0xFd886c8f0c8185Ee814a74EB9cDcA2CfE910474C"

Ethereum.set_network(Ethereum::Network::Testnet)

signed = Ethereum::Payment.sign(
  from: from[:address],
  to: to,
  amount: "0.00001",
  secret: from[:secret],
)

Ethereum::Payment.send_by_signed(signed.rawTransaction)

## tx hash
# 0x1fee02f76d4102b8d83230aded597801dfe3ff0e5e249802844978c21cb18690
```

### Contract

#### Send token

```crystal
require "ethereum"

from = {
  address: "0x75d5196ad433f4d2CC76Ebb5677437170f15Aa26",
  secret:  "0x2bb195c03c48967522c4ba374e1cb1973555c2a11fbecee571a1d487fd960e27",
}
to = "0xFd886c8f0c8185Ee814a74EB9cDcA2CfE910474C"
contract_address = "0x3e1edc25850a943da36b1e2a8ba23e8a19d4f4b3"

abi = <<-ABI
    [
      {
        "constant":false,
        "inputs":[
          {
            "name":"recipient",
            "type":"address"
          },
          {
            "name":"amount",
            "type":"uint256"
          }],
          "name":"transfer",
          "outputs":[
            {
              "name":"",
              "type":"bool"
            }],
            "payable":false,
            "stateMutability":"nonpayable",
            "type":"function"
      }
    ]
ABI

Ethereum.set_network(Ethereum::Network::Testnet)
contract_hex = Ethereum::Contract.encode_transfer_method(
  abi: abi,
  contract_address: contract_address,
  to: to,
  amount: "1"
)

signed = Ethereum::Payment.sign_contract(
  from: from[:address],
  secret: from[:secret],
  contract_address: contract_address,
  contract_hex: contract_hex
)

Ethereum::Payment.send_by_signed(signed.rawTransaction)

## tx hash
# 0x1fee02f76d4102b8d83230aded597801dfe3ff0e5e249802844978c21cb18690
```



More example code, look at [this link](https://github.com/fukaoi/crystal-ethereum/tree/master/example)


## Development

#### JS(ReasonML) codes

Raw js code is transpile  from reasonML.Look at package.json and bsconfig.json  for know more detail that setting options 

>source: src/ethereum/js/*


#### Response types

Be Converted to Ethereum::Response class from all responses of web3js

>source: src/ethereum/response/*

* Ethereum::Response::Account
* Ethereum::Response::Contract
* Ethereum::Response::Payment

#### Error types

>source: src/ethereum.cr

ValidationError

* Raised this exception in the case  when did validation error in Crystal code 

#### Create address in command line

a wordy command, but you can write with one liner.Changing Mainnet and Testnet is 
 only change of param(Ethereum::Network)  in set_network() method

* testnet: 

```crystal
crystal eval 'require "./src/ethereum";Ethereum.set_network(Ethereum::Network::Testnet);p Ethereum::Account.generate_account'
```

* mainnet: 

```crystal
crystal eval 'require "./src/ethereum";Ethereum.set_network(Ethereum::Network::Mainnet);p Ethereum::Account.generate_account'
```



## Contributing

1. Fork it (<https://github.com/fukaoi/crystal-ethereum/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [fukaoi](https://github.com/fukaoi) - creator and maintainer

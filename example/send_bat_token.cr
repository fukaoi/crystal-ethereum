require "../src/ethereum.cr"

from = {
  address: "0xF47Bf71e7A04E41F38B9FBe06820F96998944d8B",
  secret:  "0x69387f5aac3b0d3024599cf3ad55f1e3997528bb7145b3f398f4b427ab45d6d8",
}
to = "0xFd886c8f0c8185Ee814a74EB9cDcA2CfE910474C"
contract_address = "0xdb0040451f373949a4be60dcd7b6b8d6e42658b6"

# ## bat token abi ###
abi = <<-ABI
[
  {
    "constant":false,
    "inputs":[
    {
      "name":"_to",
      "type":"address"
    },
    {
      "name":"_value",
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

# ## Testnet or Mainnet or Custome net ###
Ethereum.set_network(Ethereum::Network::Testnet)

# ## encode transfer method of token ####
contract_hex = Ethereum::Contract.encode_transfer_method(
  abi: abi,
  contract_address: contract_address,
  to: to,
  amount: "1"
)

# ## Signning ####
signed = Ethereum::Payment.sign_contract(
  from: from[:address],
  secret: from[:secret],
  contract_address: contract_address,
  contract_hex: contract_hex
)

# ## Send transaction ###
p Ethereum::Payment.send_by_signed(signed.rawTransaction)

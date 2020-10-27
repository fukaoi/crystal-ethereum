require "../src/ethereum.cr"

from = {
  address: "0x75d5196ad433f4d2CC76Ebb5677437170f15Aa26",
  secret:  "0x2bb195c03c48967522c4ba374e1cb1973555c2a11fbecee571a1d487fd960e27",
}
to = "0xFd886c8f0c8185Ee814a74EB9cDcA2CfE910474C"
contract_address = "0x3e1edc25850a943da36b1e2a8ba23e8a19d4f4b3"

# ## crystal token abi ###
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

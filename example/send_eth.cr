require "../src/ethereum.cr"

from = {
  address: "0x75d5196ad433f4d2CC76Ebb5677437170f15Aa26",
  secret:  "0x2bb195c03c48967522c4ba374e1cb1973555c2a11fbecee571a1d487fd960e27",
}
to = "0xFd886c8f0c8185Ee814a74EB9cDcA2CfE910474C"

# ## Testnet or Mainnet or Custome net ###
Ethereum.set_network(Ethereum::Network::Testnet)

# ## Get currnet nonce number ###
nonce = Ethereum::Payment.get_current_nonce(from[:address])
p "current nonce: #{nonce}"

# ## Signning ####
signed = Ethereum::Payment.sign(
  from: from[:address],
  to: to,
  amount: "0.00001",
  secret: from[:secret],
  nonce: nonce,
)

# ## Send transaction ###
p Ethereum::Payment.send_by_signed(signed.rawTransaction)

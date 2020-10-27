require "spec"
require "../src/ethereum"

module Helper
  extend self

  def from
    {
      address: "0x75d5196ad433f4d2CC76Ebb5677437170f15Aa26",
      secret:  "0x2bb195c03c48967522c4ba374e1cb1973555c2a11fbecee571a1d487fd960e27",
    }
  end

  def to
    {
      address: "0xFd886c8f0c8185Ee814a74EB9cDcA2CfE910474C",
      secret:  "0x8ea7e23edc7889f644d5e331659a646c9f67821e2abd54c12e36b5965ba929e2",
    }
  end

  def contract_address
    "0x3e1edc25850a943da36b1e2a8ba23e8a19d4f4b3"
  end

  def abi
    <<-ABI
  [
  {
    "constant": false,
    "inputs": [
      {
        "name": "recipient",
        "type": "address"
      },
      {
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "transfer",
    "outputs": [
      {
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "account",
        "type": "address"
      }
    ],
    "name": "balanceOf",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "decimals",
    "outputs": [
      {
        "name": "",
        "type": "uint8"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }
  ]
	ABI
  end
end

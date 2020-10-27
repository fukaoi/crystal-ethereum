require "nodejs"
require "file_utils"
require "./ethereum/response/*"
require "./ethereum/*"

module Ethereum
  extend self

  enum Network
    Testnet
    Mainnet
  end

  @@network = Network::Testnet
  @@server = ""

  def get_network : NamedTuple(network: String, server: String)
    {network: @@network.to_s.downcase, server: @@server}
  end

  def set_network(network : Network, customize_server : String = "") : Void
    case network
    when Network::Testnet
      @@network = network
      @@server = "https://ropsten.infura.io/v3/509acee7b08c46c290532382bd73d4d5"
    when Network::Mainnet
      @@network = network
      @@server = "https://mainnet.infura.io/v3/509acee7b08c46c290532382bd73d4d5"
    end
    unless customize_server.empty?
      @@server = customize_server
    end
  end

  class ValidationError < Exception; end
end

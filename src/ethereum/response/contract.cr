require "json"

module Ethereum::Response
  struct Contract
    struct DecodeData
      JSON.mapping(
        method: String,
        types: Array(String),
        inputs: Array(String),
        names: Array(String)
      )
    end
  end
end

require "json"

module Ethereum::Response
  class Payment
    class Sign
      JSON.mapping(
        messageHash: String,
        rawTransaction: String,
        v: String,
        r: String,
        s: String
      )
    end
  end
end

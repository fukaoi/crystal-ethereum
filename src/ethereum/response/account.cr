require "json"

module Ethereum::Response
  class Account
    JSON.mapping(
      address: String,
      privateKey: String
    )
  end
end

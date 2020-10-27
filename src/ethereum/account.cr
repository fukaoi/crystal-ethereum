require "http/client"
require "colorize"

module Ethereum::Account
  extend self

  def generate_account : Response::Account
    code = <<-CODE
      #{load_accountjs}
      let account = create("#{Ethereum.get_network[:server]}");
      toCrystal(account);
    CODE
    res = Nodejs.eval(code).to_json
    obj = Response::Account.from_json(res)
    if is_testnet?
      puts "[TESTNET]".colorize(:blue)
      eth_faucet(obj.address)
      # token_faucet(obj.address)
    end
    obj
  end

  def get_balance(address : String) : String
    raise ValidationError.new("Invalid eth address") unless is_address?(address)
    code = <<-CODE
      #{load_accountjs}
      getBalance("#{address}")
      .then(res => toCrystal(res))
      .catch(err => toCrystalErr(err));
    CODE
    Nodejs.eval(code).to_json
  end

  def is_address?(address : String) : Bool
    code = <<-CODE
      #{load_accountjs}
      toCrystal(isAddress("#{address}"));
    CODE
    Nodejs.eval(code).to_json == "true" ? true : false
  end

  private def is_testnet?
    testnet_str = Network::Testnet.to_s.downcase
    Ethereum.get_network[:network] == testnet_str
  end

  private def eth_faucet(address : String)
    res = HTTP::Client.post(
      url: "https://ropsten.faucet.b9lab.com/tap",
      headers: HTTP::Headers{"Content-type" => "application/json"},
      body: "{\"toWhom\":\"#{address}\"}"
    )
    puts res.success? ? "faucet success.".colorize(:green) : "faucet failed.#{res.body}".colorize(:red)
  end

  private def token_faucet(address : String)
    res = HTTP::Client.post(
      url: "https://ropsten.faucet.b9lab.com/tap",
      headers: HTTP::Headers{"Content-type" => "application/json"},
      body: "{\"toWhom\":\"#{address}\"}"
    )
    puts res.success? ? "faucet success.".colorize(:green) : "faucet failed.#{res.body}".colorize(:red)
  end

  private def load_accountjs
    <<-CODE
    #{Nodejs.load_jsfile("ethereum/account.bs.js")}
      const set = Util.Util[4];
      set('#{Ethereum.get_network[:server]}');
    CODE
  end
end

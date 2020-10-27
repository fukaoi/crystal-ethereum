module Ethereum::Contract
  extend self

  def encode_transfer_method(abi : String, contract_address : String, to : String, amount : String) : String
    raise ValidationError.new("Not found abi") if abi.empty?
    raise ValidationError.new("Invalid eth address is contract_address") unless Account.is_address?(contract_address)
    raise ValidationError.new("Invalid eth address is to") unless Account.is_address?(to)
    raise ValidationError.new("Not found amount") if amount.empty?
    code = <<-CODE
      #{load_contractjs}
      const obj = createObject(#{abi}, "#{contract_address}");
      toCrystal(transferEncodeABI(obj, "#{to}", "#{Payment.to_wei(amount)}"));
    CODE
    Nodejs.eval(code).to_s
  end

  def decode_input_data(abi : String, input_data : String) : Response::Contract::DecodeData
    raise ValidationError.new("Not found abi") if abi.empty?
    raise ValidationError.new("Not found input data") if input_data.empty?
    code = <<-CODE
      #{load_contractjs}
      toCrystal(decodeData(#{abi}, "#{input_data}"));
    CODE
    res = Nodejs.eval(code).to_json
    Response::Contract::DecodeData.from_json(res)
  end

  def get_balance(abi : String, contract_address : String, address : String) : String
    raise ValidationError.new("Not found abi") if abi.empty?
    raise ValidationError.new("Invalid eth address is contract_address") unless Account.is_address?(contract_address)
    raise ValidationError.new("Invalid eth address") unless Account.is_address?(address)
    code = <<-CODE
      #{load_contractjs}
      const obj = createObject(#{abi}, "#{contract_address}");
      getBalance(obj, "#{address}")
      .then(res => toCrystal(res))
      .catch(err => toCrystalErr(err));
    CODE
    Nodejs.eval(code).to_json
  end

  private def load_contractjs
    <<-CODE
    #{Nodejs.load_jsfile("ethereum/contract.bs.js")}
      const set = Util.Util[4];
      set('#{Ethereum.get_network[:server]}');
    CODE
  end
end

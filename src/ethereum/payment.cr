require "colorize"

module Ethereum::Payment
  extend self

  ETH_SEND_GAS_LIMIT     = "21000"  # 21_000
  ETH_CONTRACT_GAS_LIMIT = "100000" # 100_000

  def sign(
    from : String,
    to : String,
    amount : String,
    secret : String,
    gas_limit : String = ETH_SEND_GAS_LIMIT,
    gas_price : String = get_current_gas_price,
    nonce : Int64 | Nil = nil
  ) : Response::Payment::Sign
    raise ValidationError.new("Invalid eth address: from") unless Account.is_address?(from)
    raise ValidationError.new("Invalid eth address: to") unless Account.is_address?(to)
    raise ValidationError.new("Not found amount") if amount.empty?
    raise ValidationError.new("Not found secret") if secret.empty?

    code = <<-CODE
    #{load_paymentjs}
      signTransaction(
        '#{from}',
        '#{to}',
        '#{to_wei(amount)}',
        '#{secret}',
        '#{gas_limit}',
        '#{gas_price}',
        '', // contract_hex
         #{convert_nonce(nonce)}
      )
      .then(res => toCrystal(res))
      .catch(err => toCrystalErr(err));
    CODE
    res = Nodejs.eval(code).to_json
    Response::Payment::Sign.from_json(res)
  end

  def sign_contract(
    from : String,
    secret : String,
    contract_address : String,
    contract_hex : String,
    gas_limit = ETH_CONTRACT_GAS_LIMIT,
    gas_price = get_current_gas_price,
    nonce : Int64 | Nil = nil
  ) : Response::Payment::Sign
    raise ValidationError.new("Invalid eth address: from") unless Account.is_address?(from)
    raise ValidationError.new("Invalid eth address: contract address") unless Account.is_address?(contract_address)
    raise ValidationError.new("Not found secret") if secret.empty?
    raise ValidationError.new("Not found contract hex") if contract_hex.empty?

    code = <<-CODE
    #{load_paymentjs}
      signTransaction(
        '#{from}',
        '#{contract_address}',
        '', // amount
        '#{secret}',
        '#{gas_limit}',
        '#{gas_price}',
        '#{contract_hex}',
         #{convert_nonce(nonce)}
      )
      .then(res => toCrystal(res))
      .catch(err => toCrystalErr(err));
    CODE
    res = Nodejs.eval(code).to_json
    Response::Payment::Sign.from_json(res)
  end

  def convert_nonce(nonce : Int64 | Nil)
    if nonce == nil
      nonce
    else
      "'#{nonce}'"
    end
  end

  def send_by_signed(tx_raw : String) : String
    raise ValidationError.new("Not found tx_raw") if tx_raw.empty?
    code = <<-CODE
    #{load_paymentjs}
      sendSignedTransaction('#{tx_raw}')
      .once('transactionHash', tx => {
        toCrystal(tx);
        process.exit(0);
      })
      .once('error', err => toCrystalErr(err));
    CODE
    Nodejs.eval(code).to_s
  end

  def get_current_nonce(from : String) : Int64
    code = <<-CODE
    #{load_paymentjs}
    getTransactionCount('#{from}')
    .then(res => toCrystal(res))
    .catch(err => toCrystalErr(err));
    CODE
    Nodejs.eval(code).as_i64
  end

  def get_current_gas_price : String
    code = <<-CODE
    #{load_paymentjs}
    getGasPrice()
    .then(res => toCrystal(res))
    .catch(err => toCrystalErr(err));
    CODE
    Nodejs.eval(code).to_s
  end

  def estimate_gas_limit : String
    code = <<-CODE
    #{load_paymentjs}
    estimateGas()
    .then(res => toCrystal(res))
    .catch(err => toCrystalErr(err));
    CODE
    Nodejs.eval(code).to_s
  end

  def estimate_gas_limit(to : String, contract_hex : String = "") : String
    code = <<-CODE
    #{load_paymentjs}
    estimateGas('#{to}', '#{contract_hex}')
    .then(res => toCrystal(res))
    .catch(err => toCrystalErr(err));
    CODE
    Nodejs.eval(code).to_s
  end

  def to_wei(eth : String) : String
    code = <<-CODE
    #{Nodejs.load_jsfile("ethereum/util.bs.js")}
      toCrystal(toWei('#{eth}'));
    CODE
    Nodejs.eval(code).to_s
  end

  private def load_paymentjs
    <<-CODE
    #{Nodejs.load_jsfile("ethereum/payment.bs.js")}
      const set = Util.Util[4];
      set('#{Ethereum.get_network[:server]}');
    CODE
  end
end

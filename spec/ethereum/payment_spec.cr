require "../spec_helper"

describe Ethereum::Payment do
  Spec.before_each do
    Ethereum.set_network(Ethereum::Network::Testnet)
  end

  describe "sign" do
    it "Success signning" do
      res = Ethereum::Payment.sign(
        from: Helper.from[:address],
        to: Helper.to[:address],
        gas_price: "100000",
        gas_limit: "21000",
        amount: "1",
        secret: Helper.from[:secret]
      )
      res.rawTransaction.should_not be_nil
    end

    it "Success signning. No set gas_price and gas_limit" do
      res = Ethereum::Payment.sign(
        from: Helper.from[:address],
        to: Helper.to[:address],
        amount: "1",
        secret: Helper.from[:secret]
      )
      res.rawTransaction.should_not be_nil
    end

    it "Success signning. No set gas_price" do
      res = Ethereum::Payment.sign(
        from: Helper.from[:address],
        to: Helper.to[:address],
        amount: "1",
        gas_limit: "41000",
        secret: Helper.from[:secret]
      )
      res.rawTransaction.should_not be_nil
    end

    it "Success signning. No set gas_limit" do
      res = Ethereum::Payment.sign(
        from: Helper.from[:address],
        to: Helper.to[:address],
        amount: "1",
        gas_price: "100000",
        secret: Helper.from[:secret]
      )
      res.rawTransaction.should_not be_nil
    end

    it "Success signning. set empty in gas_price" do
      res = Ethereum::Payment.sign(
        from: Helper.from[:address],
        to: Helper.to[:address],
        gas_price: "",
        gas_limit: "21000",
        amount: "1",
        secret: Helper.from[:secret]
      )
      res.should_not be_nil
    end

    it "Success signning. with nonce" do
      res = Ethereum::Payment.sign(
        from: Helper.from[:address],
        to: Helper.to[:address],
        amount: "1",
        secret: Helper.from[:secret],
        nonce: Ethereum::Payment.get_current_nonce(Helper.from[:address])
      )
      res.should_not be_nil
    end

    it "Failed signning. set empty in gas_limit" do
      expect_raises(Nodejs::JSSideException) do
        Ethereum::Payment.sign(
          from: Helper.from[:address],
          to: Helper.to[:address],
          gas_price: "100000",
          gas_limit: "",
          amount: "1",
          secret: Helper.from[:secret]
        )
      end
    end

    it "Invalid eth address. from, to" do
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Payment.sign(
          from: "0x",
          to: Helper.to[:address],
          gas_price: "100000",
          gas_limit: "21000",
          amount: "1",
          secret: Helper.from[:secret]
        )
      end
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Payment.sign(
          from: Helper.from[:address],
          to: "0x",
          gas_price: "100000",
          gas_limit: "21000",
          amount: "1",
          secret: Helper.from[:secret]
        )
      end
    end

    it "Not found. amount or secret" do
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Payment.sign(
          from: Helper.from[:address],
          to: Helper.to[:address],
          gas_price: "100000",
          gas_limit: "21000",
          amount: "",
          secret: Helper.from[:secret]
        )
      end
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Payment.sign(
          from: Helper.from[:address],
          to: Helper.to[:address],
          gas_price: "100000",
          gas_limit: "21000",
          amount: "1",
          secret: ""
        )
      end
    end
  end

  describe "sign_contract" do
    it "Success. signning" do
      res = Ethereum::Payment.sign_contract(
        from: Helper.from[:address],
        secret: Helper.from[:secret],
        contract_address: Helper.contract_address,
        contract_hex: "0xa9059cbb0000000000000000000000000e691f40b041ea43273116b2fa9e59662e7dec7c0000000000000000000000000000000000000000000000000000000000000001",
        gas_price: "10000000000",
        gas_limit: "100000",
      )
      p "sign contract rawTransaction: #{res.rawTransaction}"
      res.should_not be_nil
    end

    it "Success. no set gas_limit gas_price" do
      res = Ethereum::Payment.sign_contract(
        from: Helper.from[:address],
        secret: Helper.from[:secret],
        contract_address: Helper.contract_address,
        contract_hex: "0xa9059cbb0000000000000000000000000e691f40b041ea43273116b2fa9e59662e7dec7c0000000000000000000000000000000000000000000000000000000000000001"
      )
      p "sign contract rawTransaction: #{res.rawTransaction}"
      res.should_not be_nil
    end

    it "Success signning. with nonce" do
      res = Ethereum::Payment.sign_contract(
        from: Helper.from[:address],
        secret: Helper.from[:secret],
        contract_address: Helper.contract_address,
        contract_hex: "0xa9059cbb0000000000000000000000000e691f40b041ea43273116b2fa9e59662e7dec7c0000000000000000000000000000000000000000000000000000000000000001",
        nonce: Ethereum::Payment.get_current_nonce(Helper.from[:address])
      )
      res.should_not be_nil
    end

    it "Invalid eth address. from, contract_address" do
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Payment.sign_contract(
          from: "0x",
          secret: Helper.from[:secret],
          contract_address: Helper.contract_address,
          contract_hex: "0xa9059cbb0000000000000000000000000e691f40b041ea43273116b2fa9e59662e7dec7c0000000000000000000000000000000000000000000000000000000000000001",
        )
      end
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Payment.sign_contract(
          from: Helper.from[:address],
          secret: Helper.from[:secret],
          contract_address: "0x",
          contract_hex: "0xa9059cbb0000000000000000000000000e691f40b041ea43273116b2fa9e59662e7dec7c0000000000000000000000000000000000000000000000000000000000000001",
        )
      end
    end

    it "Not found. secret, contract_hex" do
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Payment.sign_contract(
          from: Helper.from[:address],
          secret: "",
          contract_address: Helper.contract_address,
          contract_hex: "0xa9059cbb0000000000000000000000000e691f40b041ea43273116b2fa9e59662e7dec7c0000000000000000000000000000000000000000000000000000000000000001",
        )
      end
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Payment.sign_contract(
          from: Helper.from[:address],
          secret: Helper.from[:secret],
          contract_address: Helper.contract_address,
          contract_hex: "",
        )
      end
    end
  end

  describe "send_by_signed" do
    it "Success send" do
      nonce = Ethereum::Payment.get_current_nonce(Helper.from[:address])
      sign_send = ->(n : Int64) {
        tx = Ethereum::Payment.sign(
          from: Helper.from[:address],
          to: Helper.to[:address],
          amount: "0.000000000000000001",
          secret: Helper.from[:secret],
          nonce: n,
        )
        res = Ethereum::Payment.send_by_signed(tx.rawTransaction)
        p "tx: #{res}"
        res.should_not be_nil
      }

      begin
        p "begin: #{nonce}"
        sign_send.call(nonce)
      rescue ex
        p "rescue: #{nonce}"
        sign_send.call(nonce + 1) # Fix tool low nonce
      end
    end

    it "Success send via contract" do
      nonce = Ethereum::Payment.get_current_nonce(Helper.from[:address])
      sign_contract_send = ->(n : Int64) {
        tx = Ethereum::Payment.sign_contract(
          from: Helper.from[:address],
          secret: Helper.from[:secret],
          contract_address: Helper.contract_address,
          contract_hex: "0xa9059cbb0000000000000000000000000e691f40b041ea43273116b2fa9e59662e7dec7c0000000000000000000000000000000000000000000000000000000000000001",
          nonce: n,
        )

        res = Ethereum::Payment.send_by_signed(tx.rawTransaction)
        p "tx: #{res}"
        res.should_not be_nil
      }

      begin
        p "begin: #{nonce}"
        sign_contract_send.call(nonce)
      rescue ex
        p "rescue: #{nonce}"
        sign_contract_send.call(nonce + 1) # Fix tool low nonce
      end
    end

    it "Not found: tx_raw" do
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Payment.send_by_signed("")
      end
    end

    it "Invalid: tx_raw" do
      expect_raises(Nodejs::JSSideException) do
        Ethereum::Payment.send_by_signed("0xf8637f843f952bd5426HOGEHOGE")
      end
    end
  end

  describe "get_current_gas_price" do
    it "Get current gas price" do
      res = Ethereum::Payment.get_current_gas_price
      p "Current gas price: #{res}"
      res.should_not be_nil
    end
  end

  describe "estimate_gas_limit" do
    it "Estimate gas" do
      res = Ethereum::Payment.estimate_gas_limit
      p "Estimate gas limit: #{res}"
      res.should_not be_nil
    end

    it "Estimate gas with to address" do
      res = Ethereum::Payment.estimate_gas_limit(
        to: Helper.to[:address],
      )
      p "Estimate gas limit(with to): #{res}"
      res.should_not be_nil
    end

    it "Estimate gas via contract" do
      res = Ethereum::Payment.estimate_gas_limit(
        to: Helper.to[:address],
        contract_hex: "0xa9059cbb0000000000000000000000000e691f40b041ea43273116b2fa9e59662e7dec7c0000000000000000000000000000000000000000000000000000000000000001",
      )
      p "Estimate gas limit(with contract): #{res}"
      res.should_not be_nil
    end
  end

  describe "get_current_nonce" do
    it "Get current nonce" do
      res = Ethereum::Payment.get_current_nonce("0x75d5196ad433f4d2CC76Ebb5677437170f15Aa26")
      (res > 0).should be_true
    end
  end

  describe "to_wei" do
    it "Convert eth to wei" do
      eth = "0.0000000123456789"
      res = Ethereum::Payment.to_wei(eth)
      res.should eq "12345678900"
    end
  end

  describe "convert_nonce" do
    it "nonce is nil" do
      res = Ethereum::Payment.convert_nonce(nil)
      res.should eq nil
    end

    it "nonce is integer" do
      res = Ethereum::Payment.convert_nonce(123456)
      res.should eq "'123456'"
    end
  end
end

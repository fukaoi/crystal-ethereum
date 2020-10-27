require "../spec_helper"

describe Ethereum::Contract do
  Spec.before_each do
    Ethereum.set_network(Ethereum::Network::Testnet)
  end

  describe "encode_transfer_method" do
    it "Success encode transfer method data" do
      res = Ethereum::Contract.encode_transfer_method(
        abi: Helper.abi,
        contract_address: Helper.contract_address,
        to: Helper.to[:address],
        amount: "1"
      )
      p "transfer method hex: #{res}"
      res.size.should eq 138
    end

    it "Not found abi" do
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Contract.encode_transfer_method(
          abi: "",
          contract_address: Helper.contract_address,
          to: Helper.to[:address],
          amount: "1"
        )
      end
    end

    it "Invalid abi" do
      expect_raises(Nodejs::JSSideException) do
        Ethereum::Contract.encode_transfer_method(
          abi: "xxxxxxxxxxxxxxxxxx",
          contract_address: Helper.contract_address,
          to: Helper.to[:address],
          amount: "1"
        )
      end
    end

    it "Not found contract address" do
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Contract.encode_transfer_method(
          abi: Helper.abi,
          contract_address: "",
          to: Helper.to[:address],
          amount: "1"
        )
      end
    end

    it "Not found to" do
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Contract.encode_transfer_method(
          abi: Helper.abi,
          contract_address: Helper.contract_address,
          to: "",
          amount: "1"
        )
      end
    end

    it "Not found amount" do
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Contract.encode_transfer_method(
          abi: Helper.abi,
          contract_address: Helper.contract_address,
          to: Helper.to[:address],
          amount: ""
        )
      end
    end
  end

  describe "decode_input_data" do
    it "Decode input data" do
      input_data = "0xa9059cbb0000000000000000000000000e691f40b041ea43273116b2fa9e59662e7dec7c0000000000000000000000000000000000000000000000000de0b6b3a7640000"
      res = Ethereum::Contract.decode_input_data(
        abi: Helper.abi,
        input_data: input_data
      )
      res.inputs[0].should eq "0x0e691f40b041ea43273116b2fa9e59662e7dec7c"
      res.inputs[1].should eq "1"
    end

    it "Not found abi" do
      input_data = "0xa9059cbb0000000000000000000000000e691f40b041ea43273116b2fa9e59662e7dec7c0000000000000000000000000000000000000000000000000de0b6b3a7640000"
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Contract.decode_input_data(
          abi: "",
          input_data: input_data
        )
      end
    end

    it "Invalid abi" do
      input_data = "0xa9059cbb0000000000000000000000000e691f40b041ea43273116b2fa9e59662e7dec7c0000000000000000000000000000000000000000000000000de0b6b3a7640000"
      expect_raises(Nodejs::JSSideException) do
        Ethereum::Contract.decode_input_data(
          abi: "xxxxxxxxxxxxxxxxxxxxxxx",
          input_data: input_data
        )
      end
    end

    it "Invalid input data" do
      input_data = "0x0000000000000000000000000000000000000000"
      expect_raises(JSON::MappingError) do
        Ethereum::Contract.decode_input_data(
          abi: Helper.abi,
          input_data: input_data
        )
      end
    end

    it "Not found input data" do
      expect_raises(Ethereum::ValidationError) do
        Ethereum::Contract.decode_input_data(
          abi: Helper.abi,
          input_data: ""
        )
      end
    end
  end

  describe "get_balance" do
    it "Get token balance" do
      res = Ethereum::Contract.get_balance(
        abi: Helper.abi,
        contract_address: Helper.contract_address,
        address: Helper.to[:address]
      )
      res.should_not be_nil
    end
  end
end

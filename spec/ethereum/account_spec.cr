require "../spec_helper"

describe Ethereum::Account do
  Spec.before_each do
    Ethereum.set_network(Ethereum::Network::Testnet)
  end

  it "Create address and private key" do
    res = Ethereum::Account.generate_account
    p "Testnet:"
    p res
    res.address.should_not be_nil
    res.privateKey.should_not be_nil
  end

  it "Create address and private key on Mainnet" do
    Ethereum.set_network(Ethereum::Network::Mainnet)
    res = Ethereum::Account.generate_account
    p "Mainnet:"
    p res
    res.address.should_not be_nil
    res.privateKey.should_not be_nil
  end

  it "Is ethereum address" do
    address = "0x83e341CECD2Ec950b6Ac167b06147C26cc61ae26"
    res = Ethereum::Account.is_address?(address)
    res.should be_true
  end

  it "Invalid ethereum address" do
    address = "0x432343CECD2Ec950b6Ac122b06147C26cc61ae8"
    res = Ethereum::Account.is_address?(address)
    res.should be_false
  end

  it "Get balance" do
    address = "0x83e341CECD2Ec950b6Ac167b06147C26cc61ae26"
    res = Ethereum::Account.get_balance(address)
    res.should eq "1"
  end

  it "Set empty address" do
    expect_raises(Ethereum::ValidationError, "Invalid eth address") do
      Ethereum::Account.get_balance("")
    end
  end
end

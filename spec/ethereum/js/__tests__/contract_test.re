open Jest;
open Contract;
open Util;
open ExpectJs;
open Js.Promise;

let abi = [%bs.raw
  {|
  [{
    "constant":false,
    "inputs":[
    {
      "name":"recipient",
      "type":"address"
    },
    {
      "name":"amount",
      "type":"uint256"
    }],
    "name":"transfer",
    "outputs":[
    {
      "name":"",
      "type":"bool"
    }],
    "payable":false,
    "stateMutability":"nonpayable",
    "type":"function"
  },
  {"constant":true,
    "inputs":[
    {
      "name":"account",
      "type":"address"
    }],
    "name":"balanceOf",
    "outputs":[
    {
      "name":"",
      "type":"uint256"
    }],
    "payable":false,
    "stateMutability":"view",
    "type":"function"
  },
  {
    "constant":true,
    "inputs":[],
    "name":"decimals",
    "outputs":[
    {
      "name":"",
      "type":"uint8"
    }],
    "payable":false,
    "stateMutability":"view",
    "type":"function"
  },
  ]
  |}
];

let contractAddress = "0x3e1edc25850a943da36b1e2a8ba23e8a19d4f4b3";

describe("beforeAll", () =>
  "https://ropsten.infura.io/v3/1835809e0e6a4de38eaf1f7afb51e0ec" |> Util.set
);

describe("createObject", () => {
  test("Sucess", () =>
    Contract.createObject(~abi, ~contractAddress)
    |> (res => expect(res) |> toMatchSnapshot) 
  );
  test("Error empty contractAddress", () =>
    expect(() =>
      Contract.createObject(~abi="", ~contractAddress)
    ) |> toThrow
  );
  test("Error empty abi", () =>
    expect(() =>
      Contract.createObject(~abi, ~contractAddress="")
    ) |> toThrow
  );
});

describe("Encode transfer abi", () =>
  test("Sucess", () => {
    let obj = Contract.createObject(~abi, ~contractAddress);
    let res =
      Contract.transferEncodeABI(
        ~contract=obj,
        ~to_="0x0e691F40b041ea43273116b2fa9e59662e7deC7C",
        ~amount=10,
      );
    Js.log2("transferEncodeABI Hex:", res);
    res |> expect |> toBeDefined;
  })
);

describe("Decode input data", () =>
  test("Sucess", () => {
    let inputData = "0xa9059cbb0000000000000000000000000e691f40b041ea43273116b2fa9e59662e7dec7c0000000000000000000000000000000000000000000000000de0b6b3a7640000";
    let res = Contract.decodeData(~abi, ~inputData);
    Js.log2("decodeData:", res);
    res |> expect |> toBeDefined;
  })
);

describe("Divide by big number", () => {
  test("Sucess", () =>
    Contract.bnDivMod("10", 2.0) |> expect |> toBe("0.10")
  );

  test("Sucess big number", () =>
    Contract.bnDivMod("1234560000000000329", 18.0)
    |> expect
    |> toBe("1.234560000000000329")
  );
});

describe("Get decimals for contract", () =>
  testPromise("Sucess", () =>
    Contract.createObject(~abi, ~contractAddress)
    |> Contract.getDecimals
    |> then_(v =>
         {
           expect(v);
         }
         |> toBe("18")
         |> resolve
       )
  )
);

describe("Get balance from contract", () =>
  testPromise("get balance", () => {
    let contract = Contract.createObject(~abi, ~contractAddress);
    let address = "0x0e691F40b041ea43273116b2fa9e59662e7deC7C";
    Contract.getBalance(~contract, ~address)
    |> then_(v =>
         {
           Js.log2("contract balance", v);
           expect(v);
         }
         |> toBe("4.000000000000000414")
         |> resolve
       );
  })
);

open Jest;
open Util;
open Payment;
open ExpectJs;
open Contract;
open Js.Promise;

[@bs.val]
external setTimeout: (unit => assertion, int) => assertion = "setTimeout";

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
      }]
      |}
];

describe("beforeAll", () =>
  "https://ropsten.infura.io/v3/1835809e0e6a4de38eaf1f7afb51e0ec" |> Util.set
);

describe("getGasPrice", () =>
  testPromise("get gas price", () =>
    Payment.getGasPrice()
    |> then_(v =>
         {
           Js.log2("Current gas:", v);
           expect(v);
         }
         |> toBeDefined
         |> resolve
       )
  )
);

describe("estimateGas", () => {
  testPromise("Estimate gas price", () =>
    Payment.estimateGas(
      ~to_="0x0e691F40b041ea43273116b2fa9e59662e7deC7C",
      ~data=None,
    )
    |> then_(v =>
         {
           Js.log2("Estimate gas:", v);
           expect(v);
         }
         |> toBeDefined
         |> resolve
       )
  );

  testPromise("Estimate gas price via contract", () => {
    let obj =
      Contract.createObject(
        ~abi,
        ~contractAddress="0x3e1edc25850a943da36b1e2a8ba23e8a19d4f4b3",
      );

    let hex =
      Contract.transferEncodeABI(
        ~contract=obj,
        ~to_="0x3e1edc25850a943da36b1e2a8ba23e8a19d4f4b3",
        ~amount=10,
      );

    Payment.estimateGas(
      ~to_="0x0e691F40b041ea43273116b2fa9e59662e7deC7C",
      ~data=hex,
    )
    |> then_(v =>
         {
           Js.log2("Estimate gas(contract):", v);
           expect(v);
         }
         |> toBeDefined
         |> resolve
       );
  });
});

describe("getTransactionCount", () =>
  testPromise("get nonce", () =>
    Payment.getTransactionCount("0x75d5196ad433f4d2CC76Ebb5677437170f15Aa26")
    |> then_(v =>
         {
           Js.log2("Current nonce:", v);
           expect(v);
         }
         |> toBeDefined
         |> resolve
       )
  )
);

describe("signTransaction", () => {
  testPromise("Success sign", () =>
    Payment.signTransaction(
      ~from="0x75d5196ad433f4d2CC76Ebb5677437170f15Aa26",
      ~to_="0x0e691F40b041ea43273116b2fa9e59662e7deC7C",
      ~gasPrice="100000",
      ~gasLimit="21000",
      ~amount="1",
      ~privateKey=
        "0x2bb195c03c48967522c4ba374e1cb1973555c2a11fbecee571a1d487fd960e27",
      ~hex=None,
      ~nonce=None,
    )
    |> then_(v => expect(v) |> toBeDefined |> resolve)
  );

  testPromise("Success sign with contract hex", () => {
    let obj =
      Contract.createObject(
        ~abi,
        ~contractAddress="0x3e1edc25850a943da36b1e2a8ba23e8a19d4f4b3",
      );

    let hex =
      Contract.transferEncodeABI(
        ~contract=obj,
        ~to_="0x3e1edc25850a943da36b1e2a8ba23e8a19d4f4b3",
        ~amount=10,
      );

    Payment.signTransaction(
      ~from="0x75d5196ad433f4d2CC76Ebb5677437170f15Aa26",
      ~to_="0x0e691F40b041ea43273116b2fa9e59662e7deC7C",
      ~gasPrice="100000",
      ~gasLimit="21000",
      ~amount="1",
      ~privateKey=
        "0x2bb195c03c48967522c4ba374e1cb1973555c2a11fbecee571a1d487fd960e27",
      ~hex,
      ~nonce=None,
    )
    |> then_(v => expect(v) |> toBeDefined |> resolve);
  });

  testPromise("Success sign by no set gasPrice", () =>
    Payment.signTransaction(
      ~from="0x75d5196ad433f4d2CC76Ebb5677437170f15Aa26",
      ~to_="0x0e691F40b041ea43273116b2fa9e59662e7deC7C",
      ~gasPrice="",
      ~gasLimit="21000",
      ~amount="1",
      ~privateKey=
        "0x2bb195c03c48967522c4ba374e1cb1973555c2a11fbecee571a1d487fd960e27",
      ~hex=None,
      ~nonce=None,
    )
    |> then_(v => expect(v) |> toBeDefined |> resolve)
  );

  testPromise("Failed sign by no set gasLimit", () =>
    Payment.signTransaction(
      ~from="0x75d5196ad433f4d2CC76Ebb5677437170f15Aa26",
      ~to_="0x0e691F40b041ea43273116b2fa9e59662e7deC7C",
      ~gasPrice="100000",
      ~gasLimit="",
      ~amount="1",
      ~privateKey=
        "0x2bb195c03c48967522c4ba374e1cb1973555c2a11fbecee571a1d487fd960e27",
      ~hex=None,
      ~nonce=None,
    )
    |> catch(e => {j|$e|j} |> resolve)
    |> then_(v => expect(v) |> toBe("Error: \"gas\" is missing") |> resolve)
  );

  testPromise("Success sign with nonce", () => {
    let nonce = Some(123456);
    Payment.signTransaction(
      ~from="0x75d5196ad433f4d2CC76Ebb5677437170f15Aa26",
      ~to_="0x0e691F40b041ea43273116b2fa9e59662e7deC7C",
      ~gasPrice="100000",
      ~gasLimit="21000",
      ~amount="1",
      ~privateKey=
        "0x2bb195c03c48967522c4ba374e1cb1973555c2a11fbecee571a1d487fd960e27",
      ~hex=None,
      ~nonce,
    )
    |> then_(v => expect(v) |> toBeDefined |> resolve);
  });
});

describe("sendSignedTransaction", () => {
  testPromise("send", ~timeout=60000, () =>
    Payment.signTransaction(
      ~from="0x75d5196ad433f4d2CC76Ebb5677437170f15Aa26",
      ~to_="0x0e691F40b041ea43273116b2fa9e59662e7deC7C",
      ~gasPrice="2000000000",
      ~gasLimit="21000",
      ~amount="1",
      ~privateKey=
        "0x2bb195c03c48967522c4ba374e1cb1973555c2a11fbecee571a1d487fd960e27",
      ~hex=None,
      ~nonce=None,
    )
    |> then_(tx =>
         Payment.sendSignedTransaction(tx##rawTransaction)
         |> then_(v => {
              Js.log2("Transaction Hash:", v##transactionHash);
              expect(v##status) |> toBe(true) |> resolve;
            })
       )
  );

  testPromise("send with contract", ~timeout=80000, () =>
    Payment.signTransaction(
      ~from="0x75d5196ad433f4d2CC76Ebb5677437170f15Aa26",
      ~to_="0x3e1edc25850a943da36b1e2a8ba23e8a19d4f4b3",
      ~gasPrice="5000000000",
      ~gasLimit="100000",
      ~amount="",
      ~privateKey=
        "0x2bb195c03c48967522c4ba374e1cb1973555c2a11fbecee571a1d487fd960e27",
      ~hex=
        Some(
          "0xa9059cbb0000000000000000000000000e691f40b041ea43273116b2fa9e59662e7dec7c000000000000000000000000000000000000000000000000000000000000000a",
        ),
      ~nonce=None,
    )
    |> then_(tx =>
         Payment.sendSignedTransaction(tx##rawTransaction)
         |> then_(v => {
              Js.log2("Transaction Hash(contract):", v##transactionHash);
              expect(v##status) |> toBe(true) |> resolve;
            })
       )
  );
});

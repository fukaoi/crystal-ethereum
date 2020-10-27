open Util;
open Js.Promise;

module Contract = {
  [@bs.module] [@bs.new] external web3: string => Js.t('a) = "web3";
  [@bs.module] [@bs.new]
  external decoder: string => Js.t('a) = "ethereum-input-data-decoder";

  let createObject = (~abi, ~contractAddress: string): Js.t('a) => {
    abi |> Util.empty ? invalid_arg("Not found abi") : ();
    contractAddress |> Util.empty
      ? invalid_arg("Not found contractAddress") : ();

    Util.arg.server |> Util.checkServerUrl
      ? {
        let internal: (Js.t('a), string, string) => Js.t('b) = [%raw
          (obj, abi, address) => {|return new obj.eth.Contract(abi, address)|}
        ];
        internal(web3(Util.arg.server), abi, contractAddress);
      }
      : invalid_arg("Not found server url");
  };

  let transferEncodeABI = (~contract, ~to_: string, ~amount: int) =>
    contract##methods##transfer(to_, amount)##encodeABI();

  let decodeData = (~abi: string, ~inputData: string) => {
    let res = decoder(abi)##decodeData(inputData);
    Array.iteri(
      (i, e) =>
        switch (e) {
        | "uint256" =>
          res##inputs[i] = res##inputs[i]##toString(10) |> Util.toEth
        | "address" => res##inputs[i] = "0x" ++ res##inputs[i]
        | _ => ()
        },
      res##types,
    );
    res;
  };

  let bnDivMod = (balance: string, decimal: float): string => {
    let web3 = web3("");
    let internal: (Js.t('a), string) => Js.t('a) = [%raw
      (obj, number) => {| return new obj.utils.BN(number) |}
    ];
    let bx = internal(web3, balance);
    let by = internal(web3, 10.0 ** decimal |> Js.Float.toString);
    let division: (Js.t('a), Js.t('a), float) => string = [%raw
      (bl, ex, dec) => {|
        const res = bl.divmod(ex);
        return `${res.div.toString()}.${res.mod.toString(10, dec)}`;
      |}
    ];
    division(bx, by, decimal);
  };

  let getDecimals = contract => contract##methods##decimals()##call();

  let getBalance = (~contract, ~address: string) =>
    contract##methods##balanceOf(address)##call()
    |> then_(balance =>
         getDecimals(contract)
         |> then_(decimal => bnDivMod(balance, decimal) |> resolve)
       );
};

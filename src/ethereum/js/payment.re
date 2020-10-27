open Util;

module Payment = {
  [@bs.new] [@bs.module] external web3: string => Js.t('a) = "web3";

  [@bs.deriving abstract]
  type rawTx = {
    from: string,
    [@bs.as "to"]
    to_: string,
    gas: string,
    value: string,
    gasPrice: string,
    [@bs.optional]
    data: string,
    [@bs.optional]
    mutable nonce: int,
  };

  [@bs.deriving abstract]
  type rawEstimateTx = {
    [@bs.as "to"]
    to_: string,
    [@bs.optional]
    data: string,
  };

  let getGasPrice = () =>
    Util.arg.server |> Util.checkServerUrl
      ? web3(Util.arg.server)##eth##getGasPrice()
      : invalid_arg("Not found server url");

  let estimateGas = (~to_: string, ~data: option(string)) =>
    Util.arg.server |> Util.checkServerUrl
      ? {
        let obj =
          switch (data) {
          | None => rawEstimateTx(~to_, ())
          | Some(d) => rawEstimateTx(~to_, ~data=d, ())
          };
        web3(Util.arg.server)##eth##estimateGas(obj);
      }
      : invalid_arg("Not found server url");

  let getTransactionCount = (from: string) =>
    Util.arg.server |> Util.checkServerUrl
      ? web3(Util.arg.server)##eth##getTransactionCount(from)
      : invalid_arg("Not found server url");

  let signTransaction =
      (
        ~from: string,
        ~to_: string,
        ~amount: string,
        ~privateKey: string,
        ~gasLimit: string,
        ~gasPrice: string,
        ~hex: option(string),
        ~nonce: option(int),
      ) =>
    Util.arg.server |> Util.checkServerUrl
      ? {
        let tx =
          switch (hex) {
          | None =>
            rawTx(~from, ~to_, ~gasPrice, ~gas=gasLimit, ~value=amount, ())
          | Some(h) =>
            rawTx(
              ~from,
              ~to_,
              ~gasPrice,
              ~gas=gasLimit,
              ~value=amount,
              ~data=h,
              (),
            )
          };

        switch (nonce) {
        | None => ()
        | Some(n) => nonceSet(tx, n)
        };
        web3(Util.arg.server)##eth##accounts##signTransaction(
          tx,
          privateKey,
        );
      }
      : invalid_arg("Not found server url");

  let sendSignedTransaction = (txRaw: string) =>
    Util.arg.server |> Util.checkServerUrl
      ? web3(Util.arg.server)##eth##sendSignedTransaction(txRaw)
      : invalid_arg("Not found server url");
};

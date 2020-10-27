open Util;

module Account = {
  [@bs.deriving abstract]
  type accountConvertJs = {
    address: string,
    privateKey: string,
  };

  [@bs.new] [@bs.module] external web3: string => Js.t('a) = "web3";

  type account = {
    address: string,
    privateKey: string,
  };

  /* Convert json to reason type */
  let parseAccounts = (json: Js.Json.t): account =>
    Json.Decode.{
      address: json |> field("address", string),
      privateKey: json |> field("privateKey", string),
    };

  /* Create address and private key */
  let create = (): accountConvertJs =>
    web3("")##eth##accounts##create()
    |> parseAccounts
    |> (
      account =>
        accountConvertJs(
          ~address=account.address,
          ~privateKey=account.privateKey,
        )
    );

  /* Checks if a given string is a valid Ethereum address */
  let isAddress = (address: string): bool =>
    web3("")##utils##isAddress(address);

  /* Get ETH balance from an address (Converted from wei to eth before return result) */
  let getBalance = (address: string): Js.Promise.t('a) =>
    Util.arg.server |> Util.checkServerUrl
      ? web3(Util.arg.server)##eth##getBalance(address)
        |> Js.Promise.(
             then_(value => Util.toEth(value) |> resolve)
           )
      : invalid_arg("Not found server url");
};

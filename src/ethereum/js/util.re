module Util = {
  [@bs.new] [@bs.module] external web3: string => Js.t('a) = "web3";

  let checkServerUrl = (url): bool =>
    url |> Js.Re.test_([%re "/^(http|https):\\/\\//"]);

  let toEth = (wei: string): string => web3("")##utils##fromWei(wei, "ether");

  let toWei = (eth: string): string => web3("")##utils##toWei(eth);

  type argument = {mutable server: string};

  let arg = {server: ""};

  let set = (server: string) => arg.server = server;

  let empty = (str: string): bool => String.length(str) == 0
};


open Jest;
open Util;

describe("checkServerUrl", () => {
  open Expect;

  test("Success http://", () =>
    Util.checkServerUrl("http://google.com") |> expect |> toBe(true)
  );

  test("Success https://", () =>
    Util.checkServerUrl("https://google.com") |> expect |> toBe(true)
  );

  test("Failed wss://", () =>
    Util.checkServerUrl("wss://google.com") |> expect |> toBe(false)
  );

  test("Sucess toWei, toEth", () => {
    let eth = "0.0000000000001";
    eth |> Util.toWei |> Util.toEth |> expect |> toEqual(eth);
  });
});

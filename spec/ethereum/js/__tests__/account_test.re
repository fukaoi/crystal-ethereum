open Jest;
open Account;
open Util;

describe("beforeAll", () => 
  "https://ropsten.infura.io/v3/1835809e0e6a4de38eaf1f7afb51e0ec"
  |> Util.set
);

describe("create", () => {
  open Expect;

  test("address", () => {
    let res = Account.create();
    Js.log(Account.addressGet(res));
    expect(String.length(Account.addressGet(res))) |> toBe(42);
  });

  test("privateKey", () => {
    let res = Account.create();
    Js.log(Account.privateKeyGet(res));
    expect(String.length(Account.privateKeyGet(res))) |> toBe(66);
  });
});

describe("isAddress", () => {
  open Expect;

  test("valid address", () =>
    "0x0e691F40b041ea43273116b2fa9e59662e7deC7C"
    |> Account.isAddress
    |> expect
    |> toBe(true)
  );

  test("invalid address", () =>
    "0x0e671F40b041e443273116b2fa9e596e7deC7CERO"
    |> Account.isAddress
    |> expect
    |> toBe(false)
  );

  test("no set a address value", () =>
    "" |> Account.isAddress |> expect |> toBe(false)
  );
});

describe("getBalance", () => {
  open Expect;

  testPromise("balance ok", () => {
    "0xe5e3A9be78990d5747F1dd6261B0094C147Dc52a"
    |> Account.getBalance
    |> Js.Promise.(then_(v => expect(v) |> toBe("0.5") |> resolve));
  });

  testPromise("no balance", () => {
    "0x238020883e5b2aA4ce7433eA1442426a4e96c739"
    |> Account.getBalance
    |> Js.Promise.(then_(v => expect(v) |> toBe("0") |> resolve));
  });

  test("Empty error", () => {
    Util.set("");
    expect(() =>
      "0x238020883e5b2aA4ce7433eA1442426a4e96c739"
      |> Account.getBalance
    ) |> toThrow;
  });

  test("Validation error", () => {
    expect(() =>
      "0x238020883e5b2aA4ce7433eA1442426a4e96c739"
      |> Account.getBalance
    ) |> toThrow;
  });
});

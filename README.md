# GSNV1 Adapter

[![Build Status](https://travis-ci.com/akropolisio/gsn-v1-adapter.svg?branch=master)](https://travis-ci.com/akropolisio/gsn-v1-adapter)
[![codecov](https://codecov.io/gh/akropolisio/gsn-v1-adapter/branch/master/graph/badge.svg)](https://codecov.io/gh/akropolisio/gsn-v1-adapter)

Implements delegation of calls to other contracts via GSN, with proper forwarding of return values and bubbling of failures.

## Developer Tools 🛠️

- [Truffle](https://trufflesuite.com/)
- [TypeChain](https://github.com/ethereum-ts/TypeChain)
- [OpenZeppelin SDK](https://openzeppelin.com)

## Start

Create `.infura` and `.secret` files. Install the dependencies:

```bash
$ yarn
```

## Tests

```bash
$ yarn test
```

## Coverage

```bash
$ yarn coverage
```

## Deploying

Deploy to Kovan:

```bash
$ yarn oz deploy
```

## API

All functions in this implementation have a `0xb373a41f` postfix, that prevents names from intersecting with the target contract.

> 0xb373a41f == bytes4(keccak256(bytes("GSNV1Adapter")))

## deposit\_\_0xb373a41f - read

_No parameters_
See {IRelayHub-depositFor}. https://github.com/OpenZeppelin/openzeppelin-contracts-ethereum-package

Returns:
|name |type |description
|-----|-----|-----------
|result|bool|Boolean value indicating whether the operation succeeded.

## getManagerRole\_\_0xb373a41f - read

_No parameters_
Returns hash of the manager role.
Returns:
|name |type |description
|-----|-----|-----------
|managerRole|bytes32|Hash of the manager role.

## getTargetAddress\_\_0xb373a41f - read

| name            | type  | description                         |
| --------------- | ----- | ----------------------------------- |
| encodedFunction | bytes | First 4 bytes of the function hash. |

Returns address of the target.

Returns:
|name |type |description
|-----|-----|-----------
|targetAddress|address|Address of the target.

## getTargetName\_\_0xb373a41f - read

| name            | type  | description                         |
| --------------- | ----- | ----------------------------------- |
| encodedFunction | bytes | First 4 bytes of the function hash. |

Returns name of the target.

Returns:
|name |type |description
|-----|-----|-----------
|targetName|string|Name of the target.

## initilize\_\_0xb373a41f - read

| name          | type    | description                    |
| ------------- | ------- | ------------------------------ |
| trustedSigner | address | Address of the trusted signer. |
| admin         | address | Address of the admin.          |

Sets the values for {trustedSigner} and {admin}. All two of these values are immutable: they can only be set once during initialization.
Returns:
_No parameters_

## setTarget\_\_0xb373a41f - read

| name            | type    | description                         |
| --------------- | ------- | ----------------------------------- |
| encodedFunction | bytes   | First 4 bytes of the function hash. |
| targetName      | string  | String name of the target.          |
| targetAddress   | address | Address of the target.              |

Sets target struct in mapping. Returns a boolean value indicating whether the operation succeeded.

Returns:
|name |type |description
|-----|-----|-----------
|result|bool|Boolean value indicating whether the operation succeeded.

## withdraw\_\_0xb373a41f - read

| name   | type    | description                                                       |
| ------ | ------- | ----------------------------------------------------------------- |
| amount | uint256 | The amount of eth that is transferred to the recipient's address. |
| payee  | address | Recipient address.                                                |

Withdraws the recipient's deposits in `RelayHub`. Returns a boolean value indicating whether the operation succeeded.

Returns:
|name |type |description
|-----|-----|-----------
|result|bool|Boolean value indicating whether the operation succeeded.

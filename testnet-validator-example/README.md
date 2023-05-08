Aptos Testnet Validator
============
This is an Aptos Testnet Validator [Kurtosis package](https://docs.kurtosis.com/concepts-reference/packages). 
It creates a local testnet with 1 validator and a Faucet to generate coins. 
For more background on local testnets [reference Aptos' docs](https://aptos.dev/nodes/local-testnet/run-a-local-testnet). 

Run this package
----------------
If you have [Kurtosis installed][install-kurtosis], run:

```bash
kurtosis run github.com/kurtosis-tech/aptos-package/testnet-validator-example --enclave aptos
```

If you don't have Kurtosis installed, [click here to run this package on the Kurtosis playground](https://gitpod.io/new/#https://github.com/kurtosis-tech/aptos-package/tree/main/testnet-validator-example).
To blow away the created [enclave][enclaves-reference], run `kurtosis clean -a`.

### Interacting with the Validator

After running the package (as shown above) you can query the validator using the ephemeral port assigned by kurtosis.
The assigned ephemeral port is printed at the end of the run command or can be found by invoking `enclave inspect` on 
the enclave (in this case named `aptos`):

```bash
kurtosis enclave inspect aptos 
```

You'll get an output similar to this, but with different port assignments:

```bash
$ kurtosis enclave inspect aptos 
Name:            aptos
UUID:            82b2752167a5
Status:          RUNNING
Creation Time:   Mon, 08 May 2023 13:32:16 EDT

========================================= Files Artifacts =========================================
UUID           Name
ffaf30896868   mint.key

========================================== User Services ==========================================
UUID           Name        Ports                                                Status
a21e5f1d25b5   faucet      faucet_port: 8000/tcp -> http://127.0.0.1:64942      RUNNING
ca3a5c91e92a   validator   validator_port: 8080/tcp -> http://127.0.0.1:64629   RUNNING

```

You can query the Validator from outside the enclave and verify that it's incrementing the block height and epochs:
```
curl 'localhost:64629/v1/'
{
    "chain_id": 4,
    "epoch": "4",
    "ledger_version": "650",
    "oldest_ledger_version": "0",
    "ledger_timestamp": "1683566521529836",
    "node_role": "validator",
    "oldest_block_height": "0",
    "block_height": "325",
    "git_hash": "04ba6c70f91244fb510bf7a2cff9fd02782efd9a"
}

```

You can also verify that the Faucet is generating coins by query the validator accounts endpoint:
```
curl 'localhost:64629/v1/accounts/0xa550c18'
{
    "sequence_number": "2",
    "authentication_key": "0x92c607ddd90ca90d766726d5051948777f00d4c03b08efae6513ae1586f16184"
}
```
Notice that sequence number has been incremented to 2, 
indicating this is the second transaction from the Faucet minting account `0xa550c18`.


Use this package in your package
--------------------------------
Kurtosis packages can be composed inside other Kurtosis packages. To use this package in your package:

First, import this package by adding the following to the top of your Starlark file:

```python
this_package = import_module("github.com/kurtosis-tech/aptos-package/testnet-validator-example/main.star")
```

Then, call the this package's `run` function somewhere in your Starlark script:

```python
this_package_output = this_package.run(plan, args)
```

Develop on this package
-----------------------
1. [Install Kurtosis][install-kurtosis]
1. Clone this repo
1. For your dev loop, run `kurtosis clean -a && kurtosis run .` inside the repo directory


<!-------------------------------- LINKS ------------------------------->
[install-kurtosis]: https://docs.kurtosis.com/install
[enclaves-reference]: https://docs.kurtosis.com/concepts-reference/enclaves

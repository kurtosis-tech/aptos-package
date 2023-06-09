Aptos Testnet
============
This is an Aptos testnet [Kurtosis package](https://docs.kurtosis.com/concepts-reference/packages). 
It creates a local testnet with an arbitrary number of validators, validator full nodes and public full nodes.  
For more background on the different types of networks [reference Aptos' docs](https://aptos.dev/concepts/). 

Run this package
----------------
If you have [Kurtosis installed][install-kurtosis], run:

```bash
kurtosis run github.com/kurtosis-tech/aptos-package/testnet-topology --enclave aptos
```

To blow away the created [enclave][enclaves-reference], run `kurtosis clean -a`.


#### Configuration

<details>
    <summary>Click to see configuration</summary>

You can configure this package using a JSON structure as an argument to the `kurtosis run` function. The full structure that this package accepts are as follows, with default values shown (note that the `//` lines are not valid JSON and should be removed!):

```javascript
{
    "num_validators": 2
}
```

These arguments can either be provided manually:

```bash
kurtosis run github.com/kurtosis-tech/aptos-package/testnet-topology --enclave aptos '{"num_validators":2}'
```

or by loading via a file, for instance using the [args.json](args.json) file in this repo:

```bash
kurtosis run github.com/kurtosis-tech/aptos-package/testnet-topology --enclave aptos "$(cat args.json)"
```

</details>


Use this package in your package
--------------------------------
Kurtosis packages can be composed inside other Kurtosis packages. To use this package in your package:

First, import this package by adding the following to the top of your Starlark file:

```python
this_package = import_module("github.com/kurtosis-tech/aptos-package/testnet-topology/main.star")
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

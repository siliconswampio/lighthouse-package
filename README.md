geth-package
============
This is a [Kurtosis package](https://docs.kurtosis.com/concepts-reference/packages).

Use this package in your package
--------------------------------
Kurtosis packages can be composed inside other Kurtosis packages. To use this package in your package:

<!-- TODO Replace YOURUSER and THISREPO with the correct values! -->
First, import this package by adding the following to the top of your Starlark file:

```python
this_package = import_module("github.com/kurtosis-tech/geth-package/lib/main.star")
```

Then, call the this package's `run` function somewhere in your Starlark script:

```python
this_package_output = this_package.run(plan, args)
```

For an example of using this package with other packages, check out the example in the Geth Lighthouse package:
https://github.com/kurtosis-tech/geth-lighthouse-package

Develop on this package
-----------------------
1. [Install Kurtosis][install-kurtosis]
1. Clone this repo
1. For your dev loop, run `kurtosis clean -a && kurtosis run .` inside the repo directory


<!-------------------------------- LINKS ------------------------------->
[install-kurtosis]: https://docs.kurtosis.com/install
[enclaves-reference]: https://docs.kurtosis.com/concepts-reference/enclaves

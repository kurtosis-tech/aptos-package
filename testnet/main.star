validator = import_module("github.com/kurtosis-tech/aptos-package/validator@anders/aptos-package")


NAME_ARG = "name"
def run(plan, args):
    validator.run(plan, args)

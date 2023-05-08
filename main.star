APTOS_VALIDATOR_IMAGE = "aptoslabs/validator:devnet"
APTOS_VALIDATOR_SERVICE_NAME = "validator"
APTOS_VALIDATOR_API_PROTOCOL_NAME = "http"
APTOS_VALIDATOR_PORT_NAME = "validator_port"
APTOS_VALIDATOR_API_PORT = 8080

APTOS_FAUCET_IMAGE = "aptoslabs/faucet:devnet"
APTOS_FAUCET_SERVICE_NAME = "faucet"
APTOS_FAUCET_API_PROTOCOL_NAME = "http"
APTOS_FAUCET_PORT_NAME = "faucet_port"
APTOS_FAUCET_API_PORT = 8000

WAIT_DISABLE = None

def run(plan, args):
    files = plan.upload_files(
        src="github.com/kurtosis-tech/aptos-package/testnet_files",
        name="testnet_files"
    )

    validator_service = plan.add_service(
        name=APTOS_VALIDATOR_SERVICE_NAME,
        config=ServiceConfig(
            image=APTOS_VALIDATOR_IMAGE,
            ports={
                APTOS_VALIDATOR_PORT_NAME: PortSpec(
                    number=APTOS_VALIDATOR_API_PORT,
                    application_protocol=APTOS_VALIDATOR_API_PROTOCOL_NAME,
                    wait=WAIT_DISABLE,
                ),
            },
            env_vars={
            },
            cmd=[
                "/usr/local/bin/aptos-node",
                "--test",
                "--test-dir",
                "/opt/aptos/var/",
                "--config",
                "/opt/aptos/var/validator_node_template.yaml"
            ],
            files={
                "/opt/aptos/var/": files,
            }
            # public_ports={
            #     APTOS_VALIDATOR_PORT_NAME: PortSpec(number=APTOS_VALIDATOR_API_PORT),
            # }
        ),
    )

    mintKeyAvailableRecipe = ExecRecipe(
        command=["ls", "/opt/aptos/var/mint.key"],
    )

    plan.wait(
        service_name=APTOS_VALIDATOR_SERVICE_NAME,
        recipe=mintKeyAvailableRecipe,
        field="code",
        assertion="==",
        target_value=0,
        timeout="30s",
    )

    mint_key = plan.store_service_files(
        service_name=APTOS_VALIDATOR_SERVICE_NAME,
        src="/opt/aptos/var/mint.key",
        name="mint.key",
    )

    validator_service_url = "%s://%s:%d" % (
        APTOS_VALIDATOR_API_PROTOCOL_NAME,
        validator_service.ip_address,
        APTOS_VALIDATOR_API_PORT
    )
    plan.print("Validator running with url %s" % validator_service_url)
    faucet_service = plan.add_service(
        name=APTOS_FAUCET_SERVICE_NAME,
        config=ServiceConfig(
            image=APTOS_FAUCET_IMAGE,
            ports={
                APTOS_FAUCET_PORT_NAME: PortSpec(
                    number=APTOS_FAUCET_API_PORT,
                    application_protocol=APTOS_FAUCET_API_PROTOCOL_NAME,
                    wait=WAIT_DISABLE,
                ),
            },
            env_vars={
            },
            cmd=[
                "/usr/local/bin/aptos-faucet",
                "--chain-id",
                "TESTING",
                "--mint-key-file-path",
                "/opt/aptos/var/mint.key",
                "--server-url",
                "%s" % validator_service_url
            ],
            files={
                "/opt/aptos/var/": mint_key,
            }
            # public_ports={
            #     APTOS_FAUCET_PORT_NAME: PortSpec(number=APTOS_FAUCET_API_PORT),
            # }
        ),
    )

    return

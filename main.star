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
    file = plan.upload_files(
        src="github.com/kurtosis-tech/aptos-package/validator_node_template.yaml@anders/aptos-package",
        name="validator_node_template.yaml"
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
            cmd=["/usr/local/bin/aptos-node", "--test", "--test-dir", "/opt/aptos/var/", "--config",
                 "/opt/aptos/var/validator_node_template.yaml"],
            files={
                "/opt/aptos/var/": file,
            }
            # public_ports={
            #     APTOS_VALIDATOR_PORT_NAME: PortSpec(number=APTOS_API__PORT),
            # }
        ),
    )
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
                "/bin/bash",
                "-c",
                """
                    for i in {1..10}; do
                      if [[ ! -s /opt/aptos/var/mint.key ]]; then
                        echo 'Validator has not populated mint.key yet. Is it running?'
                        sleep 1
                      else
                        sleep 1
                        /usr/local/bin/aptos-faucet \\
                          --chain-id TESTING \\
                          --mint-key-file-path /opt/aptos/var/mint.key \\
                          --server-url http://172.16.1.10:8080
                        echo 'Faucet failed to run likely due to the Validator still starting. Will try again.'
                      fi
                    done
                    exit 1
                """
                
            ],

            # public_ports={
            #     APTOS_FAUCET_PORT_NAME: PortSpec(number=APTOS_API__PORT),
            # }
        ),
    )

    return
APTOS_VALIDATOR_IMAGE = "aptoslabs/validator:devnet"
APTOS_VALIDATOR_SERVICE_NAME = "validator"
APOTS_API_PROTOCOL_NAME = "http"
APTOS_VALIDATOR_PORT_NAME = "validator_port"
ATPOS_API__PORT = 8080

WAIT_DISABLE=None

def run(plan, args):

    file = plan.upload_files(
        src = "github.com/kurtosis-tech/aptos-package/validator/validator_node_template.yaml@anders/aptos-package",
        name = "validator_node_template.yaml"
    )

    validator_service = plan.add_service(
        name=APTOS_VALIDATOR_SERVICE_NAME,
        config=ServiceConfig(
            image=APTOS_VALIDATOR_IMAGE,
            ports={
                APTOS_VALIDATOR_PORT_NAME: PortSpec(
                    number=ATPOS_API__PORT,
                    application_protocol=APOTS_API_PROTOCOL_NAME,
                    wait=WAIT_DISABLE,
                ),
            },
            env_vars={
            },
            cmd = ["/usr/local/bin/aptos-node", "--test", "--test-dir", "/opt/aptos/var/", "--config", "/opt/aptos/var/validator_node_template.yaml"],
            files = {
                "/opt/aptos/var/": file,
            }

    # public_ports={
            #     APTOS_VALIDATOR_PORT_NAME: PortSpec(number=ATPOS_API__PORT),
            # }
        ),
    )

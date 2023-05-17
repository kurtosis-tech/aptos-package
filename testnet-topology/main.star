
# Shared
APTOS_GENESIS_FILES_LABEL = "aptos_genesis_files"
APTOS_GENESIS_FILES_SOURCE_PATH = "github.com/kurtosis-tech/aptos-package/testnet-topology/genesis_files"
APTOS_GENESIS_FILES_TARGET_PATH = "/opt/aptos/genesis"

# Aptos Validator
APTOS_VALIDATOR_IMAGE = "aptoslabs/validator:testnet"
APTOS_VALIDATOR_SERVICE_NAME = "validator"

APTOS_VALIDATOR_API_PROTOCOL_NAME = "http"
APTOS_VALIDATOR_API_PORT_NAME = "vaport"
APTOS_VALIDATOR_API_PORT = 8080

APTOS_VALIDATOR_NETWORK_PROTOCOL_NAME = "tcp"
APTOS_VALIDATOR_NETWORK_PORT_NAME = "vneport"
APTOS_VALIDATOR_NETWORK_PORT = 6180

APTOS_VALIDATOR_NETWORK_FULLNODE_PROTOCOL_NAME = "tcp"
APTOS_VALIDATOR_NETWORK_FULLNODE_PORT_NAME = "vnfnp"
APTOS_VALIDATOR_NETWORK_FULLNODE_PORT = 6181

APTOS_VALIDATOR_CONFIG_PATH = "/opt/aptos/etc/validator.yaml"
APTOS_VALIDATOR_CONFIG_FILES_LABEL = "aptos_validator_config_files"
APTOS_VALIDATOR_CONFIG_FILES_SOURCE_PATH = "github.com/kurtosis-tech/aptos-package/testnet-topology/validator_config"
APTOS_VALIDATOR_CONFIG_FILES_TARGET_PATH = "/opt/aptos/etc"

# Aptos Full Node
APTOS_VALIDATOR_FULL_NODE_IMAGE = "aptoslabs/validator:testnet"
APTOS_VALIDATOR_FULL_NODE_SERVICE_NAME = "validator-full-node"

APTOS_VALIDATOR_FULL_NODE_API_PROTOCOL_NAME = "http"
APTOS_VALIDATOR_FULL_NODE_PORT_NAME = "vfnap"
APTOS_VALIDATOR_FULL_NODE_API_PORT = 8080

APTOS_VALIDATOR_FULL_NODE_PUBLIC_NETWORK_PROTOCOL_NAME = "tcp"
APTOS_VALIDATOR_FULL_NODE_PUBLIC_NETWORK_PORT_NAME = "validator-full-node-public-network-port"
APTOS_VALIDATOR_FULL_NODE_PUBLIC_NETWORK_PORT = 6182

APTOS_VALIDATOR_FULL_NODE_METRICS_PROTOCOL_NAME = "tcp"
APTOS_VALIDATOR_FULL_NODE_METRICS_PORT_NAME = "vfnmp"
APTOS_VALIDATOR_FULL_NODE_METRICS_PORT = 9101

APTOS_VALIDATOR_FULL_NODE_CONFIG_PATH = "/opt/aptos/etc/validator_full_node.yaml"
APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_LABEL = "aptos_validator_full_node_config_files"
APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_SOURCE_PATH = "github.com/kurtosis-tech/aptos-package/testnet-topology/validator_full_node_config"
APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_TARGET_PATH = "/opt/aptos/etc"

# Aptos Public full node
APTOS_PUBLIC_FULL_NODE_IMAGE = APTOS_VALIDATOR_FULL_NODE_IMAGE
APTOS_PUBLIC_FULL_NODE_SERVICE_NAME = "public_full_node"

APTOS_PUBLIC_FULL_NODE_API_PROTOCOL_NAME = "http"
APTOS_PUBLIC_FULL_NODE_PORT_NAME = "fnap"
APTOS_PUBLIC_FULL_NODE_API_PORT = 8080

APTOS_PUBLIC_FULL_NODE_PUBLIC_NETWORK_PROTOCOL_NAME = "tcp"
APTOS_PUBLIC_FULL_NODE_PUBLIC_NETWORK_PORT_NAME = "fnpnp"
APTOS_PUBLIC_FULL_NODE_PUBLIC_NETWORK_PORT = 6182

APTOS_PUBLIC_FULL_NODE_METRICS_PROTOCOL_NAME = "tcp"
APTOS_PUBLIC_FULL_NODE_METRICS_PORT_NAME = "fnmp"
APTOS_PUBLIC_FULL_NODE_METRICS_PORT = 9101

APTOS_PUBLIC_FULL_NODE_CONFIG_PATH = "/opt/aptos/etc/public_full_node.yaml"
APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_LABEL = "aptos_public_full_node_config_files"
APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_SOURCE_PATH = "github.com/kurtosis-tech/aptos-package/testnet-topology/public_full_node_config"
APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_TARGET_PATH = "/opt/aptos/etc"

WAIT_DISABLE = None

# Number of nodes:
DEFAULT_NUM_VALIDATORS=2
DEFAULT_NUM_VALIDATORS_FULL_NODE=2
DEFAULT_NUM_PUBLIC_FULL_NODE=2

NUM_VALIDATORS_ARG_KEY="num_validators"
NUM_VALIDATOR_FULL_NODES_ARG_KEY="num_validator_full_nodes"
NUM_PUBLIC_FULL_NODES_ARG_KEY="num_public_full_nodes"

def run(plan, args):
    # Get topology configuration
    num_validators = args.get(NUM_VALIDATORS_ARG_KEY, DEFAULT_NUM_VALIDATORS)
    num_validator_full_nodes = args.get(NUM_VALIDATOR_FULL_NODES_ARG_KEY, DEFAULT_NUM_VALIDATORS_FULL_NODE)
    num_public_full_nodes = args.get(NUM_PUBLIC_FULL_NODES_ARG_KEY, DEFAULT_NUM_PUBLIC_FULL_NODE)

    # Upload genesis and node config files to enclave
    validator_genesis_files_artifact = upload_validator_genesis_files(plan)
    validator_config_files_artifact = upload_validator_config(plan)
    validator_full_node_config_files_artifact = upload_validator_full_node_config(plan)
    public_node_config_files_artifact = upload_public_full_node_config(plan)

    # Create the nodes
    for num in range(0, num_validators):
        create_validator_node(plan, num, validator_config_files_artifact, validator_genesis_files_artifact)
    for num in range(0, num_validator_full_nodes):
        create_validator_full_node(plan, num, validator_full_node_config_files_artifact, validator_genesis_files_artifact)
    for num in range(0, num_public_full_nodes):
        create_public_full_node(plan, num, public_node_config_files_artifact, validator_genesis_files_artifact)

    return

def upload_validator_genesis_files(plan):
    return plan.upload_files(
        src=APTOS_GENESIS_FILES_SOURCE_PATH,
        name=APTOS_GENESIS_FILES_LABEL,
    )

def upload_validator_config(plan):
    return plan.upload_files(
        src=APTOS_VALIDATOR_CONFIG_FILES_SOURCE_PATH,
        name=APTOS_VALIDATOR_CONFIG_FILES_LABEL,
    )

def upload_validator_full_node_config(plan):
    return plan.upload_files(
        src=APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_SOURCE_PATH,
        name=APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_LABEL,
    )

def upload_public_full_node_config(plan):
    return plan.upload_files(
        src=APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_SOURCE_PATH,
        name=APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_LABEL,
    )

def create_validator_node(plan, node_number, validator_config_files_artifact, validator_genesis_files_artifact):
    service = plan.add_service(
        name="%s_%s" % (APTOS_VALIDATOR_SERVICE_NAME, node_number),
        config=ServiceConfig(
            image=APTOS_VALIDATOR_IMAGE,
            ports={
                APTOS_VALIDATOR_API_PORT_NAME: PortSpec(
                    number=APTOS_VALIDATOR_API_PORT,
                    application_protocol=APTOS_VALIDATOR_API_PROTOCOL_NAME,
                    wait=WAIT_DISABLE,
                ),
                APTOS_VALIDATOR_NETWORK_PORT_NAME: PortSpec(
                    number=APTOS_VALIDATOR_NETWORK_PORT,
                    application_protocol=APTOS_VALIDATOR_NETWORK_PROTOCOL_NAME,
                    wait=WAIT_DISABLE,
                ),
                APTOS_VALIDATOR_NETWORK_FULLNODE_PORT_NAME: PortSpec(
                    number=APTOS_VALIDATOR_NETWORK_FULLNODE_PORT,
                    application_protocol=APTOS_VALIDATOR_NETWORK_FULLNODE_PROTOCOL_NAME,
                    wait=WAIT_DISABLE,
                ),
            },
            files={
                APTOS_VALIDATOR_CONFIG_FILES_TARGET_PATH: validator_config_files_artifact,
                APTOS_GENESIS_FILES_TARGET_PATH: validator_genesis_files_artifact,
            },
            cmd=[
                "/usr/local/bin/aptos-node",
                "-f",
                APTOS_VALIDATOR_CONFIG_PATH,
            ],
        ),
    )
    return service


def create_validator_full_node(plan, node_number, validator_config_files_artifact, validator_genesis_files_artifact):
    service = plan.add_service(
        name="%s_%s" % (APTOS_VALIDATOR_FULL_NODE_SERVICE_NAME, node_number),
        config=ServiceConfig(
            image=APTOS_VALIDATOR_FULL_NODE_IMAGE,
            ports={
                APTOS_VALIDATOR_FULL_NODE_PORT_NAME: PortSpec(
                    number=APTOS_VALIDATOR_FULL_NODE_API_PORT,
                    application_protocol=APTOS_VALIDATOR_FULL_NODE_API_PROTOCOL_NAME,
                    wait=WAIT_DISABLE,
                ),
                APTOS_VALIDATOR_FULL_NODE_PUBLIC_NETWORK_PORT_NAME: PortSpec(
                    number=APTOS_VALIDATOR_FULL_NODE_PUBLIC_NETWORK_PORT,
                    application_protocol=APTOS_VALIDATOR_FULL_NODE_PUBLIC_NETWORK_PROTOCOL_NAME,
                    wait=WAIT_DISABLE,
                ),
                APTOS_VALIDATOR_FULL_NODE_METRICS_PORT_NAME: PortSpec(
                    number=APTOS_VALIDATOR_FULL_NODE_METRICS_PORT,
                    application_protocol=APTOS_VALIDATOR_FULL_NODE_METRICS_PROTOCOL_NAME,
                    wait=WAIT_DISABLE,
                ),
            },
            files={
                APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_TARGET_PATH: validator_config_files_artifact,
                APTOS_GENESIS_FILES_TARGET_PATH: validator_genesis_files_artifact,
            },
            cmd=[
                "/usr/local/bin/aptos-node",
                "-f",
                APTOS_VALIDATOR_FULL_NODE_CONFIG_PATH,
            ],
        ),
    )
    return service


def create_public_full_node(plan, node_number, validator_config_files_artifact, validator_genesis_files_artifact):
    service = plan.add_service(
        name="%s_%s" % (APTOS_PUBLIC_FULL_NODE_SERVICE_NAME, node_number),
        config=ServiceConfig(
            image=APTOS_PUBLIC_FULL_NODE_IMAGE,
            ports={
                APTOS_PUBLIC_FULL_NODE_PORT_NAME: PortSpec(
                    number=APTOS_PUBLIC_FULL_NODE_API_PORT,
                    application_protocol=APTOS_PUBLIC_FULL_NODE_API_PROTOCOL_NAME,
                    wait=WAIT_DISABLE,
                ),
                APTOS_PUBLIC_FULL_NODE_PUBLIC_NETWORK_PORT_NAME: PortSpec(
                    number=APTOS_PUBLIC_FULL_NODE_PUBLIC_NETWORK_PORT,
                    application_protocol=APTOS_PUBLIC_FULL_NODE_PUBLIC_NETWORK_PROTOCOL_NAME,
                    wait=WAIT_DISABLE,
                ),
                APTOS_PUBLIC_FULL_NODE_METRICS_PORT_NAME: PortSpec(
                    number=APTOS_PUBLIC_FULL_NODE_METRICS_PORT,
                    application_protocol=APTOS_PUBLIC_FULL_NODE_METRICS_PROTOCOL_NAME,
                    wait=WAIT_DISABLE,
                ),
            },
            files={
                APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_TARGET_PATH: validator_config_files_artifact,
                APTOS_GENESIS_FILES_TARGET_PATH: validator_genesis_files_artifact,
            },
            cmd=[
                "/usr/local/bin/aptos-node",
                "-f",
                APTOS_PUBLIC_FULL_NODE_CONFIG_PATH,
            ],
        ),
    )
    return service
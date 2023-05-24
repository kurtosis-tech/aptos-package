# Shared
APTOS_GENESIS_FILES_LABEL = "aptos_genesis_files"
APTOS_GENESIS_FILES_SOURCE_PATH = "github.com/kurtosis-tech/aptos-package/testnet-topology/genesis_files"
APTOS_GENESIS_FILES_TARGET_PATH = "/opt/aptos/genesis"

APTOS_GENESIS_ORGANIZER_FILES_SOURCE_PATH = "github.com/kurtosis-tech/aptos-package/testnet-topology/organizer_files"
APTOS_GENESIS_ORGANIZER_FILES_LABEL = "aptos_genesis_organizer_files"
APTOS_GENESIS_ORGANIZER_FILES_TARGET_PATH = "/opt/aptos/organizer"

# Aptos Validator
APTOS_VALIDATOR_IMAGE = "aptoslabs/validator:testnet"
APTOS_VALIDATOR_SERVICE_NAME = "validator"

APTOS_VALIDATOR_API_PROTOCOL_NAME = "http"
APTOS_VALIDATOR_API_PORT_NAME = "v-api"
APTOS_VALIDATOR_API_PORT = 8080

APTOS_VALIDATOR_NETWORK_PROTOCOL_NAME = "tcp"
APTOS_VALIDATOR_NETWORK_PORT_NAME = "v-net"
APTOS_VALIDATOR_NETWORK_PORT = 6180

APTOS_VALIDATOR_NETWORK_FULLNODE_PROTOCOL_NAME = "tcp"
APTOS_VALIDATOR_NETWORK_FULLNODE_PORT_NAME = "v-net-full"
APTOS_VALIDATOR_NETWORK_FULLNODE_PORT = 6181

APTOS_VALIDATOR_CONFIG_PATH = "/opt/aptos/etc/validator.yaml"
APTOS_VALIDATOR_CONFIG_FILES_LABEL = "aptos_validator_config_files"
APTOS_VALIDATOR_CONFIG_FILES_SOURCE_PATH = "github.com/kurtosis-tech/aptos-package/testnet-topology/validator_config"
APTOS_VALIDATOR_CONFIG_FILES_TARGET_PATH = "/opt/aptos/etc"

# Aptos Full Node
APTOS_VALIDATOR_FULL_NODE_IMAGE = "aptoslabs/validator:testnet"
APTOS_VALIDATOR_FULL_NODE_SERVICE_NAME = "validator-full-node"

APTOS_VALIDATOR_FULL_NODE_API_PROTOCOL_NAME = "http"
APTOS_VALIDATOR_FULL_NODE_PORT_NAME = "v-full"
APTOS_VALIDATOR_FULL_NODE_API_PORT = 8080

APTOS_VALIDATOR_FULL_NODE_PUBLIC_NETWORK_PROTOCOL_NAME = "tcp"
APTOS_VALIDATOR_FULL_NODE_PUBLIC_NETWORK_PORT_NAME = "v-full-net-pub"
APTOS_VALIDATOR_FULL_NODE_PUBLIC_NETWORK_PORT = 6182

APTOS_VALIDATOR_FULL_NODE_METRICS_PROTOCOL_NAME = "tcp"
APTOS_VALIDATOR_FULL_NODE_METRICS_PORT_NAME = "v-full-metrics"
APTOS_VALIDATOR_FULL_NODE_METRICS_PORT = 9151

APTOS_VALIDATOR_FULL_NODE_CONFIG_PATH = "/opt/aptos/etc/validator_full_node.yaml"
APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_LABEL = "aptos_validator_full_node_config_files"
APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_SOURCE_PATH = "github.com/kurtosis-tech/aptos-package/testnet-topology/validator_full_node_config"
APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_TARGET_PATH = "/opt/aptos/etc"

# Aptos Public full node
APTOS_PUBLIC_FULL_NODE_IMAGE = APTOS_VALIDATOR_FULL_NODE_IMAGE
APTOS_PUBLIC_FULL_NODE_SERVICE_NAME = "public_full_node"

APTOS_PUBLIC_FULL_NODE_API_PROTOCOL_NAME = "http"
APTOS_PUBLIC_FULL_NODE_PORT_NAME = "p-pub-full"
APTOS_PUBLIC_FULL_NODE_API_PORT = 8080

APTOS_PUBLIC_FULL_NODE_PUBLIC_NETWORK_PROTOCOL_NAME = "tcp"
APTOS_PUBLIC_FULL_NODE_PUBLIC_NETWORK_PORT_NAME = "p-full-pub-net"
APTOS_PUBLIC_FULL_NODE_PUBLIC_NETWORK_PORT = 6182

APTOS_PUBLIC_FULL_NODE_METRICS_PROTOCOL_NAME = "tcp"
APTOS_PUBLIC_FULL_NODE_METRICS_PORT_NAME = "p-full-metric"
APTOS_PUBLIC_FULL_NODE_METRICS_PORT = 9101

APTOS_PUBLIC_FULL_NODE_CONFIG_PATH = "/opt/aptos/etc/public_full_node.yaml"
APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_LABEL = "aptos_public_full_node_config_files"
APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_SOURCE_PATH = "github.com/kurtosis-tech/aptos-package/testnet-topology/public_full_node_config"
APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_TARGET_PATH = "/opt/aptos/etc"

WAIT_DISABLE = None

# Number of nodes:
DEFAULT_NUM_VALIDATORS = 2
DEFAULT_NUM_VALIDATORS_FULL_NODE = 2
DEFAULT_NUM_PUBLIC_FULL_NODE = 2

NUM_VALIDATORS_ARG_KEY = "num_validators"
NUM_VALIDATOR_FULL_NODES_ARG_KEY = "num_validator_full_nodes"
NUM_PUBLIC_FULL_NODES_ARG_KEY = "num_public_full_nodes"

LAYOUT_YAML = """
---
root_key: "0xca3579457555c80fc7bb39964eb298c414fd60f81a2f8eedb0244ec07a26e575"
users:
    - organizer
chain_id: 123
allow_new_validators: true
epoch_duration_secs: 7200
is_test: true
min_stake: 100000000000000
min_voting_threshold: 100000000000000
max_stake: 100000000000000000
recurring_lockup_duration_secs: 86400
required_proposer_stake: 100000000000000
rewards_apy_percentage: 10
voting_duration_secs: 43200
voting_power_increase_limit: 20
total_supply: ~
employee_vesting_start: 1663456089
employee_vesting_period_duration: 300

"""

def run(plan, args):

    create_and_upload_genesis_files(plan)

    # For testing stop now:
    return


    # Get topology configuration
    num_validators = args.get(NUM_VALIDATORS_ARG_KEY, DEFAULT_NUM_VALIDATORS)
    num_validator_full_nodes = args.get(NUM_VALIDATOR_FULL_NODES_ARG_KEY, DEFAULT_NUM_VALIDATORS_FULL_NODE)
    num_public_full_nodes = args.get(NUM_PUBLIC_FULL_NODES_ARG_KEY, DEFAULT_NUM_PUBLIC_FULL_NODE)

    # Upload genesis and node config files to enclave
    validator_genesis_files_artifact = upload_validator_genesis_files(plan)
    validator_config_files_artifact = upload_validator_config(plan)
    validator_full_node_config_files_artifact = upload_validator_full_node_config(plan)
    public_node_config_files_artifact = upload_public_full_node_config(plan)

    validator_nodes = [get_validator_node(plan, num, validator_config_files_artifact, validator_genesis_files_artifact) for num in range(0, num_validators)]
    validator_full_nodes = [get_validator_full_node(plan, num, validator_full_node_config_files_artifact, validator_genesis_files_artifact) for num in range(0, num_validator_full_nodes)]
    full_nodes = [get_public_full_node(plan, num, public_node_config_files_artifact, validator_genesis_files_artifact) for num in range(0, num_public_full_nodes)]

    # Create the nodes
    plan.add_services(dict(validator_nodes + validator_full_nodes + full_nodes))


def create_and_upload_genesis_files(plan) :
    service_name="genesis_organizer"

    plan.upload_files(
        src=APTOS_GENESIS_ORGANIZER_FILES_SOURCE_PATH,
        name=APTOS_GENESIS_ORGANIZER_FILES_LABEL,
    )

    # Run ubuntu amd64 as Aptos CLI does not support arm
    service = plan.add_service(
        name=service_name,
        config=ServiceConfig(
            image="amd64/ubuntu:mantic",
            entrypoint = ["sleep", "9999999"],
            env_vars = {
                "WORKSPACE": "/root/workspace",
            },
            ports={
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
                APTOS_GENESIS_ORGANIZER_FILES_TARGET_PATH: APTOS_GENESIS_ORGANIZER_FILES_LABEL,
            }
        ),
    )

    plan.wait(
        service_name=service_name,
        recipe=ExecRecipe(command=[
            "bash",
            "-c",
            "apt-get update && apt install -y curl libc6 python3 vim"
        ]),
        field="code",
        assertion="==",
        target_value=0,
        timeout="5m",
    )

    plan.wait(
        service_name=service_name,
        recipe=ExecRecipe(command=[
            "bash",
            "-c",
            "curl -fsSL https://aptos.dev/scripts/install_cli.py | python3"
        ]),
        field="code",
        assertion="==",
        target_value=0,
        timeout="30s",
    )

    # Generate layout.yaml
    plan.wait(
        service_name=service_name,
        recipe=ExecRecipe(command=[
            "bash",
            "-c",
            "mkdir -p $WORKSPACE/genesis && echo \"%s\" > $WORKSPACE/genesis/layout.yml" % (LAYOUT_YAML),
        ]),
        field="code",
        assertion="==",
        target_value=0,
        timeout="5m",
    )
    # Generate framework.mrb
    plan.wait(
        service_name=service_name,
        recipe=ExecRecipe(command=[
            "bash",
            "-c",
            "mv %s/framework.mrb $WORKSPACE/genesis/framework.mrb" % APTOS_GENESIS_ORGANIZER_FILES_TARGET_PATH
        ]),
        field="code",
        assertion="==",
        target_value=0,
        timeout="5m",
    )

    plan.wait(
        service_name=service_name,
        recipe=ExecRecipe(command=[
            "bash",
            "-c",
            "/root/.local/bin/aptos genesis generate-keys --output-dir $WORKSPACE/keys",
        ]),
        field="code",
        assertion="==",
        target_value=0,
        timeout="5m",
    )

    plan.wait(
        service_name=service_name,
        recipe=ExecRecipe(command=[
            "bash",
            "-c",
            "cd $WORKSPACE/keys && /root/.local/bin/aptos genesis set-validator-configuration --username organizer --validator-host %s --full-node-host %s --local-repository-dir $WORKSPACE/genesis" % (service.ip_address + ":" + str(service.ports[APTOS_VALIDATOR_NETWORK_PORT_NAME].number), service.ip_address + ":" + str(service.ports[APTOS_VALIDATOR_NETWORK_FULLNODE_PORT_NAME].number)),
        ]),
        field="code",
        assertion="==",
        target_value=0,
        timeout="5m",
    )

    plan.wait(
        service_name=service_name,
        recipe=ExecRecipe(command=[
            "bash",
            "-c",
            "/root/.local/bin/aptos genesis generate-genesis --local-repository-dir $WORKSPACE/genesis --output-dir $WORKSPACE/genesis-output/",
        ]),
        field="code",
        assertion="==",
        target_value=0,
        timeout="30s",
    )

    # Next up get the framework.mrb
    # wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.3.0/framework.mrb framework.mrb


# # Wait to proceed with execution until the validator has produced the mint key that the faucet needs:
#     plan.wait(
#         service_name=service_name,
#         recipe=ExecRecipe(command=["ls", "~/workspace/genesis.blob"]),
#         field="code",
#         assertion="==",
#         target_value=0,
#         timeout="30s",
#     )
#     plan.wait(
#         service_name=service_name,
#         recipe=ExecRecipe(command=["ls", "~/workspace/waypoint.txt"]),
#         field="code",
#         assertion="==",
#         target_value=0,
#         timeout="30s",
#     )

#     # Create a files artifact of the mint.key (the faucet will mount later)
#     genesis_files = plan.store_service_files(
#         service_name=service_name,
#         src="~/workspace",
#         name="genesis_files",
#     )

#     plan.remove_service(service_name)

#     return genesis_files


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

def get_node_name(service_name, node_number):
    return "%s_%s" % (service_name, node_number)

def get_validator_node(plan, node_number, validator_config_files_artifact, validator_genesis_files_artifact):
    return (get_node_name(APTOS_VALIDATOR_SERVICE_NAME, node_number), ServiceConfig(
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
    ))


def get_validator_full_node(plan, node_number, validator_config_files_artifact, validator_genesis_files_artifact):
    return (get_node_name(APTOS_VALIDATOR_FULL_NODE_SERVICE_NAME, node_number), ServiceConfig(
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
    ))


def get_public_full_node(plan, node_number, validator_config_files_artifact, validator_genesis_files_artifact):
    return (get_node_name(APTOS_PUBLIC_FULL_NODE_SERVICE_NAME, node_number), ServiceConfig(
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
    ))

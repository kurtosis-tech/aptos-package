# Shared
APTOS_ROOT_KEY = "0xca3579457555c80fc7bb39964eb298c414fd60f81a2f8eedb0244ec07a26e575"
APTOS_CHAIN_ID = "30"
APTOS_GENESIS_FILES_TARGET_PATH = "/opt/aptos/genesis"
APTOS_USERNAME_PREFIX = "node"
APTOS_NODE_IDENTITY_CONFIG_PREFIX = "identity"

APTOS_FILES_TARGET_PATH = "/opt/aptos/"
APTOS_IDENTITY_FILES_TARGET_PATH = "/opt/aptos/workspace/"

APTOS_WORKSPACE = "/root/workspace"

# Genesis organizer
GENESIS_ORGANIZER_SERVICE_NAME = "genesis_organizer"
GENESIS_ORGANIZER_FILES_SOURCE_PATH = "github.com/kurtosis-tech/aptos-package/testnet-topology/organizer_files"
GENESIS_ORGANIZER_FILES_LABEL = "genesis_organizer_files"
GENESIS_ORGANIZER_FILES_TARGET_PATH = "/opt/aptos/organizer"

# Aptos Validator Node
APTOS_VALIDATOR_IMAGE = "aptoslabs/validator:testnet"
APTOS_VALIDATOR_SERVICE_NAME = "v"

APTOS_VALIDATOR_API_PROTOCOL_NAME = "http"
APTOS_VALIDATOR_API_PORT_NAME = "v-api"
APTOS_VALIDATOR_API_PORT = 8080

APTOS_VALIDATOR_NETWORK_PROTOCOL_NAME = "tcp"
APTOS_VALIDATOR_NETWORK_PORT_NAME = "v-net"
APTOS_VALIDATOR_NETWORK_PORT = 6180

APTOS_VALIDATOR_NETWORK_FULLNODE_PROTOCOL_NAME = "tcp"
APTOS_VALIDATOR_NETWORK_FULLNODE_PORT_NAME = "v-net-full"
APTOS_VALIDATOR_NETWORK_FULLNODE_PORT = 6181

APTOS_VALIDATOR_METRICS_PROTOCOL_NAME = "tcp"
APTOS_VALIDATOR_METRICS_PORT_NAME = "v-metrics"
APTOS_VALIDATOR_METRICS_PORT = 9101

APTOS_VALIDATOR_CONFIG_FILE_PATH = "/opt/aptos/etc/validator.yaml"
APTOS_VALIDATOR_CONFIG_FILES_LABEL = "v_config_files"
APTOS_VALIDATOR_CONFIG_FILES_SOURCE_PATH = "github.com/kurtosis-tech/aptos-package/testnet-topology/validator_config/validator.yaml"
APTOS_VALIDATOR_CONFIG_FILES_TARGET_FILE = "validator.yaml"
APTOS_VALIDATOR_CONFIG_FILES_TARGET_PATH = "/opt/aptos/etc"

# Aptos Validator Full Node
APTOS_VALIDATOR_FULL_NODE_IMAGE = "aptoslabs/validator:testnet"
APTOS_VALIDATOR_FULL_NODE_SERVICE_NAME = "vfn"

APTOS_VALIDATOR_FULL_NODE_API_PROTOCOL_NAME = "http"
APTOS_VALIDATOR_FULL_NODE_PORT_NAME = "v-full"
APTOS_VALIDATOR_FULL_NODE_API_PORT = 8080

APTOS_VALIDATOR_FULL_NODE_PRIVATE_NETWORK_PROTOCOL_NAME = "tcp"
APTOS_VALIDATOR_FULL_NODE_PRIVATE_NETWORK_PORT_NAME = "v-full-net-priv"
APTOS_VALIDATOR_FULL_NODE_PRIVATE_NETWORK_PORT = 6181

APTOS_VALIDATOR_FULL_NODE_PUBLIC_NETWORK_PROTOCOL_NAME = "tcp"
APTOS_VALIDATOR_FULL_NODE_PUBLIC_NETWORK_PORT_NAME = "v-full-net-pub"
APTOS_VALIDATOR_FULL_NODE_PUBLIC_NETWORK_PORT = 6182

APTOS_VALIDATOR_FULL_NODE_METRICS_PROTOCOL_NAME = "tcp"
APTOS_VALIDATOR_FULL_NODE_METRICS_PORT_NAME = "v-full-metrics"
APTOS_VALIDATOR_FULL_NODE_METRICS_PORT = 9101

APTOS_VALIDATOR_FULL_NODE_CONFIG_PATH = "/opt/aptos/etc/validator_full_node.yaml"
APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_LABEL = "vfn_config_files"
APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_SOURCE_PATH = "github.com/kurtosis-tech/aptos-package/testnet-topology/validator_full_node_config/validator_full_node.yaml"
APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_TARGET_FILE = "validator_full_node.yaml"
APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_TARGET_PATH = "/opt/aptos/etc"

# Aptos Public full node
APTOS_PUBLIC_FULL_NODE_IMAGE = APTOS_VALIDATOR_FULL_NODE_IMAGE
APTOS_PUBLIC_FULL_NODE_SERVICE_NAME = "pfn"

APTOS_PUBLIC_FULL_NODE_API_PROTOCOL_NAME = "http"
APTOS_PUBLIC_FULL_NODE_PORT_NAME = "p-pub-full"
APTOS_PUBLIC_FULL_NODE_API_PORT = 8080

APTOS_PUBLIC_FULL_NODE_PUBLIC_NETWORK_PROTOCOL_NAME = "tcp"
APTOS_PUBLIC_FULL_NODE_PUBLIC_NETWORK_PORT_NAME = "p-full-pub-net"
APTOS_PUBLIC_FULL_NODE_PUBLIC_NETWORK_PORT = 6180

APTOS_PUBLIC_FULL_NODE_METRICS_PROTOCOL_NAME = "tcp"
APTOS_PUBLIC_FULL_NODE_METRICS_PORT_NAME = "p-full-metric"
APTOS_PUBLIC_FULL_NODE_METRICS_PORT = 9101

APTOS_PUBLIC_FULL_NODE_CONFIG_PATH = "/opt/aptos/etc/public_full_node.yaml"
APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_LABEL = "pfn_config_files"
APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_SOURCE_PATH = "github.com/kurtosis-tech/aptos-package/testnet-topology/public_full_node_config/public_full_node.yaml"
APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_TARGET_FILE = "public_full_node.yaml"
APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_TARGET_PATH = "/opt/aptos/etc"

WAIT_DISABLE = None

# Number of nodes:
DEFAULT_NUM_VALIDATORS = 3
NUM_VALIDATORS_ARG_KEY = "num_validators"


def run(plan, args):
    num_validators = args.get(NUM_VALIDATORS_ARG_KEY, DEFAULT_NUM_VALIDATORS)

    user_names = generate_user_names(num_validators)

    genesis_files_artifact, identities = create_and_upload_genesis_files(plan, user_names)

    services = {}
    for i in range(0, len(identities)):
        user_name = user_names[i]
        identity = identities[i]
        validator_config_files_artifact = render_validator_node_template(plan, user_name)
        service_name, service_config = get_validator_node(user_name,
                                                          genesis_files_artifact,
                                                          validator_config_files_artifact,
                                                          identity)
        services[service_name] = service_config

        validator_full_node_config_files_artifact = render_validator_full_node_template(plan, user_name)
        service_name, service_config = get_validator_full_node(user_name,
                                                               genesis_files_artifact,
                                                               validator_full_node_config_files_artifact,
                                                               identity)
        services[service_name] = service_config

        public_full_node_config_files_artifact = render_public_full_node_template(plan, user_name)
        service_name, service_config = get_public_full_node(user_name,
                                                            genesis_files_artifact,
                                                            public_full_node_config_files_artifact,
                                                            identity)
        services[service_name] = service_config

    plan.add_services(services)


def render_validator_node_template(plan, user_name):
    return render_yaml_template(
        plan,
        APTOS_VALIDATOR_CONFIG_FILES_SOURCE_PATH,
        APTOS_VALIDATOR_CONFIG_FILES_LABEL,
        APTOS_VALIDATOR_CONFIG_FILES_TARGET_FILE,
        user_name,
    )


def render_validator_full_node_template(plan, user_name):
    return render_yaml_template(
        plan,
        APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_SOURCE_PATH,
        APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_LABEL,
        APTOS_VALIDATOR_FULL_NODE_CONFIG_FILES_TARGET_FILE,
        user_name,
    )


def render_public_full_node_template(plan, user_name):
    return render_yaml_template(
        plan,
        APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_SOURCE_PATH,
        APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_LABEL,
        APTOS_PUBLIC_FULL_NODE_CONFIG_FILES_TARGET_FILE,
        user_name,
    )


def render_yaml_template(plan, config_files_source_path, config_files_label, config_files_target_file, user_name):
    return plan.render_templates(
        name=render_template_name(config_files_label, user_name),
        config={
            config_files_target_file: struct(
                template=read_file(config_files_source_path),
                data={
                    "NODE_PATH": user_name,
                }
            ),
        }
    )


def render_template_name(label, user_name):
    return label + "_" + user_name


def generate_user_names(num_validators):
    return [APTOS_USERNAME_PREFIX + '_{}'.format(x) for x in range(0, num_validators)]


def create_and_upload_genesis_files(plan, user_names):
    # Upload files needed by the Genesis Organizer to the enclave
    plan.upload_files(
        src=GENESIS_ORGANIZER_FILES_SOURCE_PATH,
        name=GENESIS_ORGANIZER_FILES_LABEL,
    )

    # Run ubuntu amd64 as Aptos CLI does not support arm
    plan.add_service(
        name=GENESIS_ORGANIZER_SERVICE_NAME,
        config=ServiceConfig(
            image="kurtosistech/aptos-package-organizer:latest",
            env_vars={
                "WORKSPACE": APTOS_WORKSPACE,
            },
            files={
                GENESIS_ORGANIZER_FILES_TARGET_PATH: GENESIS_ORGANIZER_FILES_LABEL,
            }
        ),
    )

    # Install Aptos CLI
    plan.wait(
        service_name=GENESIS_ORGANIZER_SERVICE_NAME,
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

    # Generate and upload layout.yaml
    layout_yaml = create_layout_yaml(APTOS_ROOT_KEY, APTOS_CHAIN_ID, user_names)
    plan.print(layout_yaml)
    plan.wait(
        service_name=GENESIS_ORGANIZER_SERVICE_NAME,
        recipe=ExecRecipe(command=[
            "bash",
            "-c",
            "mkdir -p $WORKSPACE/configuration && echo \"%s\" > $WORKSPACE/configuration/layout.yaml" % layout_yaml,
        ]),
        field="code",
        assertion="==",
        target_value=0,
        timeout="5m",
    )

    # Get framework.mrb
    plan.wait(
        service_name=GENESIS_ORGANIZER_SERVICE_NAME,
        recipe=ExecRecipe(command=[
            "bash",
            "-c",
            "mv %s/framework.mrb $WORKSPACE/configuration/framework.mrb" % GENESIS_ORGANIZER_FILES_TARGET_PATH
        ]),
        field="code",
        assertion="==",
        target_value=0,
        timeout="5m",
    )

    # For each user name: generate keys and validator configurations
    for user_name in user_names:
        user_dir = "%s/%s" % (
            APTOS_WORKSPACE,
            user_name,
        )
        validator_host = "%s_%s:%d" % (
            APTOS_VALIDATOR_SERVICE_NAME,
            user_name,
            APTOS_VALIDATOR_NETWORK_PORT,
        )
        validator_full_node_host = "%s_%s:%d" % (
            APTOS_VALIDATOR_FULL_NODE_SERVICE_NAME,
            user_name,
            APTOS_VALIDATOR_FULL_NODE_PUBLIC_NETWORK_PORT,
        )

        plan.wait(
            service_name=GENESIS_ORGANIZER_SERVICE_NAME,
            recipe=ExecRecipe(command=[
                "bash",
                "-c",
                "/root/.local/bin/aptos genesis generate-keys --output-dir %s" % user_dir,
            ]),
            field="code",
            assertion="==",
            target_value=0,
            timeout="5m",
        )

        command = "cd %s && /root/.local/bin/aptos genesis set-validator-configuration --owner-public-identity-file %s/public-keys.yaml --username %s --validator-host %s --full-node-host %s --local-repository-dir $WORKSPACE/configuration" % (
            user_dir,
            user_dir,
            user_name,
            validator_host,
            validator_full_node_host,
        )

        plan.print("Executing command: %s" % command)
        plan.wait(
            service_name=GENESIS_ORGANIZER_SERVICE_NAME,
            recipe=ExecRecipe(command=[
                "bash",
                "-c",
                command,
            ]),
            field="code",
            assertion="==",
            target_value=0,
            timeout="5m",
        )

    # Once all validator configs have been created, create the genesis
    plan.wait(
        service_name=GENESIS_ORGANIZER_SERVICE_NAME,
        recipe=ExecRecipe(command=[
            "bash",
            "-c",
            "mkdir -p $WORKSPACE/genesis/ && /root/.local/bin/aptos genesis generate-genesis --local-repository-dir $WORKSPACE/configuration --output-dir $WORKSPACE/genesis/",
        ]),
        field="code",
        assertion="==",
        target_value=0,
        timeout="60s",
    )

    # Verify that genesis.blob and waypoint.txt exists before attempting to upload to the enclave
    plan.wait(
        service_name=GENESIS_ORGANIZER_SERVICE_NAME,
        recipe=ExecRecipe(command=[
            "bash",
            "-c",
            "ls %s/genesis/genesis.blob" % APTOS_WORKSPACE]
        ),
        field="code",
        assertion="==",
        target_value=0,
        timeout="60s",
    )
    plan.wait(
        service_name=GENESIS_ORGANIZER_SERVICE_NAME,
        recipe=ExecRecipe(command=[
            "bash",
            "-c",
            "ls %s/genesis/waypoint.txt" % APTOS_WORKSPACE]
        ),
        field="code",
        assertion="==",
        target_value=0,
        timeout="60s",
    )

    # Upload the genesis files
    genesis_files = plan.store_service_files(
        service_name=GENESIS_ORGANIZER_SERVICE_NAME,
        src="%s/genesis" % APTOS_WORKSPACE,
        name="genesis_files",
    )

    # Upload the validator node identities
    node_identities = []
    for user_name in user_names:
        node_identity = plan.store_service_files(
            service_name=GENESIS_ORGANIZER_SERVICE_NAME,
            src=APTOS_WORKSPACE + "/%s" % user_name,
            name="%s_%s" % (APTOS_NODE_IDENTITY_CONFIG_PREFIX, user_name),
        )
        node_identities.append(node_identity)

    return genesis_files, node_identities


def get_node_name(service_name, node_number):
    return "%s_%s" % (service_name, node_number)


def get_validator_node(user_name,
                       validator_genesis_files_artifact,
                       validator_config_files_artifact,
                       validator_keys_files_artifact,
                       ):
    return (
        get_node_name(APTOS_VALIDATOR_SERVICE_NAME, user_name),
        ServiceConfig(
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
                APTOS_VALIDATOR_METRICS_PORT_NAME: PortSpec(
                    number=APTOS_VALIDATOR_METRICS_PORT,
                    application_protocol=APTOS_VALIDATOR_METRICS_PROTOCOL_NAME,
                    wait=WAIT_DISABLE,
                ),
            },
            files={
                APTOS_VALIDATOR_CONFIG_FILES_TARGET_PATH: validator_config_files_artifact,
                APTOS_GENESIS_FILES_TARGET_PATH: validator_genesis_files_artifact,
                APTOS_IDENTITY_FILES_TARGET_PATH: validator_keys_files_artifact,
            },
            cmd=[
                "/usr/local/bin/aptos-node",
                "-f",
                APTOS_VALIDATOR_CONFIG_FILE_PATH,
            ],
        ))


def get_validator_full_node(user_name,
                            validator_genesis_files_artifact,
                            validator_config_files_artifact,
                            validator_keys_files_artifact,
                            ):
    return (
        get_node_name(APTOS_VALIDATOR_FULL_NODE_SERVICE_NAME, user_name),
        ServiceConfig(
            image=APTOS_VALIDATOR_FULL_NODE_IMAGE,
            ports={
                APTOS_VALIDATOR_FULL_NODE_PORT_NAME: PortSpec(
                    number=APTOS_VALIDATOR_FULL_NODE_API_PORT,
                    application_protocol=APTOS_VALIDATOR_FULL_NODE_API_PROTOCOL_NAME,
                    wait=WAIT_DISABLE,
                ),
                APTOS_VALIDATOR_FULL_NODE_PRIVATE_NETWORK_PORT_NAME: PortSpec(
                    number=APTOS_VALIDATOR_FULL_NODE_PRIVATE_NETWORK_PORT,
                    application_protocol=APTOS_VALIDATOR_FULL_NODE_PRIVATE_NETWORK_PROTOCOL_NAME,
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
                APTOS_IDENTITY_FILES_TARGET_PATH: validator_keys_files_artifact,
            },
            cmd=[
                "/usr/local/bin/aptos-node",
                "-f",
                APTOS_VALIDATOR_FULL_NODE_CONFIG_PATH,
            ],
        ))


def get_public_full_node(node_number,
                         validator_genesis_files_artifact,
                         validator_config_files_artifact,
                         validator_keys_files_artifact,
                         ):
    return (
        get_node_name(APTOS_PUBLIC_FULL_NODE_SERVICE_NAME, node_number),
        ServiceConfig(
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
                APTOS_IDENTITY_FILES_TARGET_PATH: validator_keys_files_artifact,
            },
            cmd=[
                "/usr/local/bin/aptos-node",
                "-f",
                APTOS_PUBLIC_FULL_NODE_CONFIG_PATH,
            ],
        ))


def create_layout_yaml(root_key, chain_id, user_names):
    serialized_usernames = ', '.join(user_names)
    return """
---
root_key: "%s"
users: [%s]
chain_id: %s
allow_new_validators: true
epoch_duration_secs: 7200
is_test: true
min_stake: 1
min_voting_threshold: 1
max_stake: 100000000000000000
recurring_lockup_duration_secs: 86400
required_proposer_stake: 100000000000000
rewards_apy_percentage: 10
voting_duration_secs: 43200
voting_power_increase_limit: 20
total_supply: ~
employee_vesting_start: 1663456089
employee_vesting_period_duration: 300

""" % (root_key, serialized_usernames, chain_id)

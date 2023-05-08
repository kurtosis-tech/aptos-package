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

APTOS_TEST_DIR_PATH = "/opt/aptos/var"
APTOS_MINT_KEY_PATH = "%s/mint.key" % APTOS_TEST_DIR_PATH

APTOS_FAUCET_ACCOUNT='0xa550c18'
APTOS_EXPECTED_SEQUENCE_COUNT=2

WAIT_DISABLE = None

def run(plan, args):
    # Create the validator in a local testnet:
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
            cmd=[
                "/usr/local/bin/aptos-node",
                "--test",
                "--test-dir",
                APTOS_TEST_DIR_PATH,
            ],
        ),
    )
    validator_service_url = get_service_url(
        APTOS_VALIDATOR_API_PROTOCOL_NAME,
        validator_service,
        APTOS_VALIDATOR_API_PORT,
    )
    plan.print("Validator running with url %s" % validator_service_url)

    # Wait to proceed with execution until the validator has produced the mint key that the faucet needs:
    plan.wait(
        service_name=APTOS_VALIDATOR_SERVICE_NAME,
        recipe=ExecRecipe(command=["ls", APTOS_MINT_KEY_PATH]),
        field="code",
        assertion="==",
        target_value=0,
        timeout="30s",
    )

    # Create a files artifact of the mint.key (the faucet will mount later)
    mint_key = plan.store_service_files(
        service_name=APTOS_VALIDATOR_SERVICE_NAME,
        src=APTOS_MINT_KEY_PATH,
        name="mint.key",
    )

    # Start the faucet and mount the mint.key
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
            cmd=[
                "/usr/local/bin/aptos-faucet",
                "--chain-id",
                "TESTING",
                "--mint-key-file-path",
                APTOS_MINT_KEY_PATH,
                "--server-url",
                validator_service_url
            ],
            files={
                APTOS_TEST_DIR_PATH: mint_key,
            }
        ),
    )
    faucet_service_url = get_service_url(
        APTOS_FAUCET_API_PROTOCOL_NAME,
        faucet_service,
        APTOS_FAUCET_API_PORT,
    )
    plan.print("Faucet running with url: %s" % faucet_service_url)

    # Finally verify that the Faucet account has had transactions validated:
    plan.print("Verifying that %d transactions are validated originating from the faucet account (%s)" % (APTOS_EXPECTED_SEQUENCE_COUNT, APTOS_FAUCET_ACCOUNT))
    get_request_recipe = GetHttpRequestRecipe(
        port_id = APTOS_VALIDATOR_PORT_NAME,
        endpoint = "/v1/accounts/%s" % APTOS_FAUCET_ACCOUNT,
        extract = {
            "sequence_number" : ".sequence_number",
        },
    )
    plan.wait(
        service_name=APTOS_VALIDATOR_SERVICE_NAME,
        recipe=get_request_recipe,
        field="extract.sequence_number",
        assertion="==",
        target_value=str(APTOS_EXPECTED_SEQUENCE_COUNT),
        timeout="30s",
    )
    plan.print("Verified that %d transactions were validated for the faucet account by the validator." % APTOS_EXPECTED_SEQUENCE_COUNT)

    return

def get_service_url(protocol, service, api_port):
    return "%s://%s:%d" % (protocol, service.ip_address, api_port)

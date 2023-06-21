# Imports
lighthouse = import_module("github.com/kurtosis-tech/eth-network-package/src/cl/lighthouse/lighthouse_launcher.star")
static_files = import_module("github.com/kurtosis-tech/eth-network-package/static_files/static_files.star")
genesis_data_generator = import_module("github.com/kurtosis-tech/eth-network-package/src/prelaunch_data_generator/cl_genesis/cl_genesis_data_generator.star")
validator_keystores = import_module("github.com/kurtosis-tech/eth-network-package/src/prelaunch_data_generator/cl_validator_keystores/cl_validator_keystore_generator.star")
input_parser = import_module("github.com/kurtosis-tech/eth-network-package/package_io/input_parser.star")

# Constants
CLIENT_SERVICE_NAME_PREFIX = "cl-client-"
CLIENT_CONTEXT_BOOTNODE = None
GLOBAL_LOG_LEVEL = ""
CLIENT_LOG_LEVEL = "debug"
CLIENT_IMAGE = input_parser.DEFAULT_CL_IMAGES["lighthouse"]


def run(plan, network_params, el_genesis_data, final_genesis_timestamp, el_context):
    num_participants = 1 # The number of participants in this setup is always 1
    # Prepare the genesis data
    genesis_generation_config_yml_template = read_file(static_files.CL_GENESIS_GENERATION_CONFIG_TEMPLATE_FILEPATH)
    genesis_generation_mnemonics_yml_template = read_file(static_files.CL_GENESIS_GENERATION_MNEMONICS_TEMPLATE_FILEPATH)
    total_number_of_validator_keys = network_params["num_validator_keys_per_node"] * num_participants
    cl_genesis_data = genesis_data_generator.generate_cl_genesis_data(
        plan,
        genesis_generation_config_yml_template,
        genesis_generation_mnemonics_yml_template,
        el_genesis_data,
        final_genesis_timestamp,
        network_params["network_id"],
        network_params["deposit_contract_address"],
        network_params["seconds_per_slot"],
        network_params["preregistered_validator_keys_mnemonic"],
        total_number_of_validator_keys,
        network_params["genesis_delay"],
        network_params["capella_fork_epoch"],
    )

    cl_validator_data = validator_keystores.generate_cl_validator_keystores(
        plan,
        network_params["preregistered_validator_keys_mnemonic"],
        num_participants,
        network_params["num_validator_keys_per_node"],
    )
    preregistered_validator_keys_for_nodes = cl_validator_data.per_node_keystores
    new_cl_node_validator_keystores = preregistered_validator_keys_for_nodes[0]

    # Launch the service
    service_name = "{0}{1}".format(CLIENT_SERVICE_NAME_PREFIX, 0)
    launcher = lighthouse.new_lighthouse_launcher(cl_genesis_data)
    lighthouse.launch(
        plan,
        launcher,
        service_name,
        CLIENT_IMAGE,
        CLIENT_LOG_LEVEL,
        GLOBAL_LOG_LEVEL,
        CLIENT_CONTEXT_BOOTNODE,
        el_context,  # <- if you have multiple nodes, include their contexts here
        new_cl_node_validator_keystores,
        [], # extra_beacon_params
        [], # extra_validator_params
    )

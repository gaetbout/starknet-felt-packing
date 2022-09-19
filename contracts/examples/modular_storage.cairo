%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from contracts.lib.bits_manipulation import actual_set_element_at, actual_get_element_at

const VERSION_SIZE = 4;
const TRAFFIC_CLASS_SIZE = 8;
const FLOW_LABEL_SIZE = 20;
const PAYLOAD_LENGTH_SIZE = 16;
const NEXT_HEADER_SIZE = 8;
const HOP_LIMIT_SIZE = 8;
// total bits used: 4 + 8 + 20 + 16 + 8 + 8 = 64

@view
func encode_packet_header{
    bitwise_ptr: BitwiseBuiltin*, syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(
    version: felt,
    traffic_class: felt,
    flow_label: felt,
    payload_length: felt,
    next_header: felt,
    hop_limit: felt,
) -> (response: felt) {
    // Instead of summing each index, you can also manually compute each index and hardcode them
    let (v1) = actual_set_element_at(0, 0, VERSION_SIZE, version);
    let (v2) = actual_set_element_at(v1, VERSION_SIZE, TRAFFIC_CLASS_SIZE, traffic_class);
    let (v3) = actual_set_element_at(
        v2, VERSION_SIZE + TRAFFIC_CLASS_SIZE, FLOW_LABEL_SIZE, flow_label
    );
    let (v4) = actual_set_element_at(
        v3, VERSION_SIZE + TRAFFIC_CLASS_SIZE + FLOW_LABEL_SIZE, PAYLOAD_LENGTH_SIZE, payload_length
    );
    let (v5) = actual_set_element_at(
        v4,
        VERSION_SIZE + TRAFFIC_CLASS_SIZE + FLOW_LABEL_SIZE + PAYLOAD_LENGTH_SIZE,
        NEXT_HEADER_SIZE,
        next_header,
    );
    let (v6) = actual_set_element_at(
        v5,
        VERSION_SIZE + TRAFFIC_CLASS_SIZE + FLOW_LABEL_SIZE + PAYLOAD_LENGTH_SIZE + NEXT_HEADER_SIZE,
        HOP_LIMIT_SIZE,
        hop_limit,
    );
    return (v6,);
}

@view
func decode_packet_header{
    bitwise_ptr: BitwiseBuiltin*, syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(input: felt) -> (
    version: felt,
    traffic_class: felt,
    flow_label: felt,
    payload_length: felt,
    next_header: felt,
    hop_limit: felt,
) {
    alloc_locals;
    // Instead of summing each index, you can also manually compute each index and hardcode them
    let (version) = actual_get_element_at(input, 0, VERSION_SIZE);
    let (traffic_class) = actual_get_element_at(input, VERSION_SIZE, TRAFFIC_CLASS_SIZE);
    let (flow_label) = actual_get_element_at(
        input, VERSION_SIZE + TRAFFIC_CLASS_SIZE, FLOW_LABEL_SIZE
    );
    let (payload_length) = actual_get_element_at(
        input, VERSION_SIZE + TRAFFIC_CLASS_SIZE + FLOW_LABEL_SIZE, PAYLOAD_LENGTH_SIZE
    );
    let (next_header) = actual_get_element_at(
        input,
        VERSION_SIZE + TRAFFIC_CLASS_SIZE + FLOW_LABEL_SIZE + PAYLOAD_LENGTH_SIZE,
        NEXT_HEADER_SIZE,
    );
    let (hop_limit) = actual_get_element_at(
        input,
        VERSION_SIZE + TRAFFIC_CLASS_SIZE + FLOW_LABEL_SIZE + PAYLOAD_LENGTH_SIZE + NEXT_HEADER_SIZE,
        HOP_LIMIT_SIZE,
    );
    return (version, traffic_class, flow_label, payload_length, next_header, hop_limit);
}

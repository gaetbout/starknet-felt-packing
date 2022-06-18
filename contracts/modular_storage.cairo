%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from contracts.bits_manipulation import external as bits_manipulation

const VERSION_SIZE = 4
const TRAFFIC_CLASS_SIZE = 8
const FLOW_LABEL_SIZE = 20
const PAYLOAD_LENGTH_SIZE = 16
const NEXT_HEADER_SIZE = 8
const HOP_LIMIT_SIZE = 8
# total bits used: 4 + 8 + 20 + 16 + 8 + 8 = 64

@view
func encode{
    bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(
    version : felt,
    traffic_class : felt,
    flow_label : felt,
    payload_length : felt,
    next_header : felt,
    hop_limit : felt,
) -> (response : felt):
    return bits_manipulation.actual_get_element_at(1, 0, 0)
end

@view
func decode{
    bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(input : felt, at : felt, element : felt) -> (response : felt):
    return bits_manipulation.actual_set_element_at(input, at, element, BITS_SIZE)
end

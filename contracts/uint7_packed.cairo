%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from contracts.torename import set_element_at, get_element_at, decomposee

const SIZE = 7
const MAX_PER_FELT = 35

@view
func view_get_element_at{
    bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(input : felt, at : felt) -> (response : felt):
    return get_element_at(input, at, SIZE)
end

@view
func view_set_element_at{
    bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(input : felt, at : felt, element : felt) -> (response : felt):
    return set_element_at(input, at, element, SIZE)
end

func decompose{
    bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(felt_to_decompose : felt) -> (arr_len : felt, arr : felt*):
    return decomposee(felt_to_decompose, SIZE, MAX_PER_FELT)
end

%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from contracts.bits_manipulation import external as bits_manipulation
from starkware.cairo.common.alloc import alloc

const BITS_SIZE = 7
const MAX_PER_FELT = 35  # 251 // 7 = qutotient=35

@view
func get_element_at{
    bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(input : felt, at : felt) -> (response : felt):
    return bits_manipulation.actual_get_element_at(input, at * BITS_SIZE, BITS_SIZE)
end

@view
func set_element_at{
    bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(input : felt, at : felt, element : felt) -> (response : felt):
    return bits_manipulation.actual_set_element_at(input, at * BITS_SIZE, BITS_SIZE, element)
end

@view
func decompose{
    bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(felt_to_decompose : felt) -> (arr_len : felt, arr : felt*):
    alloc_locals
    let (local arr : felt*) = alloc()
    return decompose_recursive(felt_to_decompose, 0, arr)
end

# @notice Is is the recursive part of the decompose method. It'll stop whenever it decompose element_number_max of items.
# @param felt_to_decompose: the felt from which every smaller felt needs to be extracted from
# @param arr_len: the number of decomposed felt at each step
# @param arr: the array containing all felt decomposed at each step
# @param number_of_bits: the number of bits on which each felt to extract is encoded
# @param element_number_max: the amount of felt to extract
# @return
func decompose_recursive{
    bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(felt_to_decompose, arr_len, arr : felt*) -> (arr_len : felt, arr : felt*):
    if arr_len == MAX_PER_FELT:
        return (arr_len, arr)
    end
    let (current_value) = bits_manipulation.actual_get_element_at(
        felt_to_decompose, arr_len * BITS_SIZE, BITS_SIZE
    )
    assert arr[arr_len] = current_value
    return decompose_recursive(felt_to_decompose, arr_len + 1, arr)
end

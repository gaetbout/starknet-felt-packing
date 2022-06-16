%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.bitwise import bitwise_and, bitwise_or
from starkware.cairo.common.math_cmp import is_le
from contracts.pow2 import pow2

const SIZE = 4
const ALL_ONES = 2 ** 251 - 1
const MAX = 252
const MAX_PER_FELT = 62

@view
func view_get_element_at{
        bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(input : felt, at : felt) -> (response : felt):
    let (mask) = generate_get_mask(at)
    let (masked_response) = bitwise_and(mask, input)
    let (divider) = pow2(at * SIZE)
    let response = masked_response / divider
    return (response)
end

@view
func view_set_element_at{
        bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(input : felt, at : felt, element : felt) -> (response : felt):
    assert_valid_felt(element)
    let (mask) = generate_set_mask(at)
    let (masked_intermediate_response) = bitwise_and(mask, input)
    let (multiplier) = pow2(at * SIZE)
    let multiplied_element = element * multiplier
    let (response) = bitwise_or(masked_intermediate_response, multiplied_element)
    return (response)
end

func generate_get_mask{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        at : felt) -> (mask : felt):
    assert_valid_at(at)
    let (pow_big) = pow2(SIZE * (at + 1))
    let (pow_small) = pow2(SIZE * at)
    let mask = (pow_big - 1) - (pow_small - 1)
    return (mask)
end

func generate_set_mask{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        at : felt) -> (mask : felt):
    assert_valid_at(at)
    let (pow_big) = pow2(SIZE * (at + 1))
    let (pow_small) = pow2(SIZE * at)
    let mask = ALL_ONES - (pow_big - 1) + (pow_small - 1)
    return (mask)
end

func assert_valid_felt{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        element : felt):
    let (max) = pow2(SIZE)
    let (is_bigger) = is_le(element, max - 1)
    with_attr error_message("Error felt too big"):
        assert is_bigger = TRUE
    end
    return ()
end

func assert_valid_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(at : felt):
    let max = at * SIZE
    let (is_bigger) = is_le(max, MAX - SIZE - 1)
    with_attr error_message("Error out of bound at: {at}"):
        assert is_bigger = TRUE
    end
    return ()
end

func decompose{
        bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(felt_to_decompose) -> (arr_len : felt, arr : felt*):
    alloc_locals
    let (local arr : felt*) = alloc()
    return decompose_recursive(felt_to_decompose, 0, arr)
end

func decompose_recursive{
        bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
        range_check_ptr}(felt_to_decompose, arr_len, arr : felt*) -> (arr_len : felt, arr : felt*):
    if arr_len == MAX_PER_FELT:
        return (arr_len, arr)
    end
    let (current_value) = view_get_element_at(felt_to_decompose, arr_len)
    assert arr[arr_len] = current_value
    return decompose_recursive(felt_to_decompose, arr_len + 1, arr)
end

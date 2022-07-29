%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from contracts.lib.bits_manipulation import external as bits_manipulation
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_le_felt
from contracts.lib.pow2 import pow2

# This contract could also be called "uint8_packed.cairo"
const CHARACTER_SIZE = 8
const MAX_PER_FELT = 31  # 251 // 8 = quotient=31

@view
func char_at{
    bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(input : felt, at : felt) -> (response : felt):
    return bits_manipulation.actual_get_element_at(input, at * CHARACTER_SIZE, CHARACTER_SIZE)
end

@view
func set_character_at{
    bitwise_ptr : BitwiseBuiltin*, syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(input : felt, at : felt, element : felt) -> (response : felt):
    return bits_manipulation.actual_set_element_at(
        input, at * CHARACTER_SIZE, CHARACTER_SIZE, element
    )
end

@view
func length{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(input : felt) -> (
    length : felt
):
    if input == 0:
        return (0)
    end
    return length_recursive(input, 1)
end

# I did a simple search, it could be further enhanced by doing a dichotomic search
func length_recursive{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    input : felt, step : felt
) -> (length : felt):
    if step == 31:
        return (step)
    end
    let (currentPow) = pow2(step * CHARACTER_SIZE)
    let (should_return) = is_le_felt(input, currentPow)
    if should_return == 1:
        return (step)
    end
    return length_recursive(input, step + 1)
end

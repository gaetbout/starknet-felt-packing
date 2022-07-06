%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.pow2 import pow2

@view
func mask_using_substraction{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    position : felt, number_of_bits : felt
) -> (mask : felt):
    let (pow_big) = pow2(number_of_bits + position)
    let (pow_small) = pow2(position)
    let mask = (pow_big - 1) - (pow_small - 1)
    return (mask)
end

@view
func mask_using_multiplication{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    position : felt, number_of_bits : felt
) -> (mask : felt):
    let (pow_number_of_bits) = pow2(number_of_bits)
    let (pow_position) = pow2(position)
    let mask = (pow_number_of_bits - 1) * pow_position
    return (mask)
end

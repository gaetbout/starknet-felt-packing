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

@view
func empty() -> ():
    return ()
end

@view
func empty_syscall_ptr{syscall_ptr : felt*}() -> ():
    return ()
end

@view
func empty_pedersen_ptr{pedersen_ptr : HashBuiltin*}() -> ():
    return ()
end

@view
func empty_range_check_ptr{range_check_ptr}() -> ():
    return ()
end

@view
func empty_all_simple_builtins{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> ():
    return ()
end

@view
func substraction{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    pow_big : felt, pow_small : felt
) -> (mask : felt):
    let mask = (pow_big - 1) - (pow_small - 1)
    return (mask)
end

@view
func multiplication{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    pow_number_of_bits : felt, pow_position : felt
) -> (mask : felt):
    let mask = (pow_number_of_bits - 1) * pow_position
    return (mask)
end

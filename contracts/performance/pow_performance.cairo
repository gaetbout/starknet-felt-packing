%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.pow import pow
from contracts.pow2 import pow2

@view
func simple_pow{range_check_ptr}(input : felt) -> (response : felt):
    return pow(2, input)
end

@view
func get_pow{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(input : felt) -> (
    response : felt
):
    let (res) = pow2(input)
    return (res)
end

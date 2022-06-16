%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address

#
# Storage vars
#
@storage_var
func value_storage(position : felt) -> (value : felt):
end

#
# Getters
#
@view
func view_get_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(at : felt) -> (
    value : felt
):
    let (value) = value_storage.read(at)
    return (value)
end

@view
func view_get_up_to{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    size : felt
) -> (arr_len : felt, arr : felt*):
    alloc_locals
    let (local arr : felt*) = alloc()
    return view_get_up_to_recursive(0, arr, size)
end

func view_get_up_to_recursive{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    arr_len : felt, arr : felt*, max_size : felt
) -> (arr_len : felt, arr : felt*):
    if arr_len == max_size:
        return (arr_len, arr)
    end
    let (value) = value_storage.read(arr_len)
    assert arr[arr_len] = value
    return view_get_up_to_recursive(arr_len + 1, arr, max_size)
end

#
# Externals
#
@external
func at_put{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    at : felt, value : felt
):
    # TODO Ensure caller is S_place logic
    # let (caller_address) = get_caller_address()
    value_storage.write(at, value)
    # TODO Emit an event
    return ()
end

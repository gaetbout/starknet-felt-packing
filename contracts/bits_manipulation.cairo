%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.bitwise import bitwise_and, bitwise_or, ALL_ONES
from starkware.cairo.common.math_cmp import is_le
from contracts.pow2 import pow2

#
# @title Bit Manipulation
# @notice Manipulate the bits to be able to encode and decode felts
#
namespace external:
    @view
    func actual_get_element_at{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(input : felt, at : felt, element_size : felt) -> (response : felt):
        let (mask) = internal.generate_get_mask(at, element_size)
        let (masked_response) = bitwise_and(mask, input)
        let (divider) = pow2(at * element_size)
        let response = masked_response / divider
        return (response)
    end

    @view
    func actual_set_element_at{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(input : felt, at : felt, element : felt, element_size : felt) -> (response : felt):
        internal.assert_valid_felt(element, element_size)
        let (mask) = internal.generate_set_mask(at, element_size)
        let (masked_intermediate_response) = bitwise_and(mask, input)
        let (multiplier) = pow2(at * element_size)
        let multiplied_element = element * multiplier
        let (response) = bitwise_or(masked_intermediate_response, multiplied_element)
        return (response)
    end
    @view
    func actual_decompose{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(felt_to_decompose : felt, element_size : felt, element_number_max : felt) -> (
        arr_len : felt, arr : felt*
    ):
        alloc_locals
        let (local arr : felt*) = alloc()
        return internal.decompose_recursive(
            felt_to_decompose, 0, arr, element_size, element_number_max
        )
    end
end

namespace internal:
    # @notice
    # @dev
    # @param
    # @param
    # @return
    func generate_get_mask{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        at : felt, element_size : felt
    ) -> (mask : felt):
        assert_valid_at(at, element_size)
        let (pow_big) = pow2(element_size * (at + 1))
        let (pow_small) = pow2(element_size * at)
        let mask = (pow_big - 1) - (pow_small - 1)
        return (mask)
    end

    # @notice
    # @dev
    # @param
    # @param
    # @return
    func generate_set_mask{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        at : felt, element_size : felt
    ) -> (mask : felt):
        assert_valid_at(at, element_size)
        let (pow_big) = pow2(element_size * (at + 1))
        let (pow_small) = pow2(element_size * at)
        let mask = ALL_ONES - (pow_big - 1) + (pow_small - 1)
        return (mask)
    end

    # @notice Will check that the given element isn't to big to be stored
    # @dev Will fail if the felt is too big
    # @param element: the element that needs to be checked
    # @param element_size: the number of bits on which the elements will have to be encoded
    func assert_valid_felt{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        element : felt, element_size : felt
    ):
        let (max) = pow2(element_size)
        let (is_bigger) = is_le(element, max - 1)
        with_attr error_message("Error felt too big"):
            assert is_bigger = TRUE
        end
        return ()
    end

    # @notice
    # @dev
    # @param
    # @param
    # @return
    func assert_valid_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        at : felt, element_size : felt
    ):
        let max = at * element_size
        let (is_bigger) = is_le(max, 251 - element_size)
        with_attr error_message("Error out of bound at: {at}"):
            assert is_bigger = TRUE
        end
        return ()
    end

    # @notice
    # @dev
    # @param
    # @param
    # @return
    func decompose_recursive{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(felt_to_decompose, arr_len, arr : felt*, element_size : felt, element_number_max : felt) -> (
        arr_len : felt, arr : felt*
    ):
        if arr_len == element_number_max:
            return (arr_len, arr)
        end
        let (current_value) = external.actual_get_element_at(
            felt_to_decompose, arr_len, element_size
        )
        assert arr[arr_len] = current_value
        return decompose_recursive(
            felt_to_decompose, arr_len + 1, arr, element_size, element_number_max
        )
    end
end

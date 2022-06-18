%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.bitwise import bitwise_and, bitwise_or, ALL_ONES
from starkware.cairo.common.math_cmp import is_le
from contracts.pow2 import pow2

#
# @title Bits Manipulation
# @notice Manipulate the bits to be able to encode and decode felts within another felt, for more info refer to the README
#
namespace external:
    @view
    func actual_get_element_at{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(input : felt, at : felt, number_of_bits : felt) -> (response : felt):
        let (mask) = internal.generate_get_mask(at, number_of_bits)
        let (masked_response) = bitwise_and(mask, input)
        let (divider) = pow2(at * number_of_bits)
        let response = masked_response / divider
        return (response)
    end

    @view
    func actual_set_element_at{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(input : felt, at : felt, element : felt, number_of_bits : felt) -> (response : felt):
        internal.assert_valid_felt(element, number_of_bits)
        let (mask) = internal.generate_set_mask(at, number_of_bits)
        let (masked_intermediate_response) = bitwise_and(mask, input)
        let (multiplier) = pow2(at * number_of_bits)
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
    }(felt_to_decompose : felt, number_of_bits : felt, element_number_max : felt) -> (
        arr_len : felt, arr : felt*
    ):
        alloc_locals
        let (local arr : felt*) = alloc()
        return internal.decompose_recursive(
            felt_to_decompose, 0, arr, number_of_bits, element_number_max
        )
    end
end

namespace internal:
    # @notice Will generate a bit mask to extract a felt within another felt
    # @dev Will fail if the position given would make it out of the 251 available bits
    # @param position: The position of the element that needs to be extracted, starts a 0
    # @param number_of_bits: The size of the element that needs to be extracted
    # @return mask: the "get" mask corresponding to the position and the number of bits
    func generate_get_mask{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position : felt, number_of_bits : felt
    ) -> (mask : felt):
        return internal.generate_mask(position, number_of_bits)
    end

    # @notice Will generate a bit mask to be able to insert a felt within another felt
    # @dev Will fail if the position given would make it out of the 251 available bits
    # @param position: The position of the element that needs to be inserted, starts a 0
    # @param number_of_bits: the max number of bits on which the element will have to be encoded
    # @return mask: the "set" mask corresponding to the position and the number of bits
    func generate_set_mask{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position : felt, number_of_bits : felt
    ) -> (mask : felt):
        let (intermediate_mask) = internal.generate_mask(position, number_of_bits)
        let mask = ALL_ONES - intermediate_mask
        return (mask)
    end

    # @notice Will generate the mask part that is common to set_mask and get_mask
    # @dev Will fail if the position given would make it out of the 251 available bits
    # @param position: The position of the element that needs to be inserted, starts a 0
    # @param number_of_bits: the max number of bits on which the element will have to be encoded
    # @return mask: the mask corresponding to the position and the number of bits
    func generate_mask{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position : felt, number_of_bits : felt
    ) -> (mask : felt):
        assert_valid_at(position, number_of_bits)
        let (pow_big) = pow2(number_of_bits * (position + 1))
        let (pow_small) = pow2(number_of_bits * position)
        let mask = (pow_big - 1) - (pow_small - 1)
        return (mask)
    end

    # @notice Will check that the given element isn't to big to be stored
    # @dev Will fail if the felt is too big, which is relative to number_of_bits
    # @param element: the element that needs to be checked
    # @param number_of_bits: the max number of bits on which the element will have to be encoded
    func assert_valid_felt{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        element : felt, number_of_bits : felt
    ):
        let (max) = pow2(number_of_bits)
        let (is_bigger) = is_le(element, max - 1)
        with_attr error_message("Error felt too big"):
            assert is_bigger = TRUE
        end
        return ()
    end

    # @notice Will check that the given position fits within the 251 bits available
    # @dev Will fail if the position is too big
    # @param position: The position of the element, starts a 0
    # @param number_of_bits: the max number of bits on which the element will have to be encoded
    func assert_valid_at{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        position : felt, number_of_bits : felt
    ):
        let max = position * number_of_bits
        let (is_bigger) = is_le(max, 251 - number_of_bits)
        with_attr error_message("Error out of bound at: {position}"):
            assert is_bigger = TRUE
        end
        return ()
    end

    # @notice Is is the recursive part of the decompose method. It'll stop whenever it decompose element_number_max of items.
    # @param felt_to_decompose: the felt from which every smaller felt needs to be extracted from
    # @param arr_len: the number of decomposed felt at each step
    # @param arr: the array containing all felt decomposed at each step
    # @param number_of_bits: the number of bits on which each felt to extract is encoded
    # @param element_number_max: the amount of felt to extract
    # @return
    func decompose_recursive{
        bitwise_ptr : BitwiseBuiltin*,
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
    }(
        felt_to_decompose, arr_len, arr : felt*, number_of_bits : felt, element_number_max : felt
    ) -> (arr_len : felt, arr : felt*):
        if arr_len == element_number_max:
            return (arr_len, arr)
        end
        let (current_value) = external.actual_get_element_at(
            felt_to_decompose, arr_len, number_of_bits
        )
        assert arr[arr_len] = current_value
        return decompose_recursive(
            felt_to_decompose, arr_len + 1, arr, number_of_bits, element_number_max
        )
    end
end

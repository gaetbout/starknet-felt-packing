import os

import pytest
from utils import assert_revert
# For bit calculations I used:
# https://www.exploringbinary.com/binary-converter/ 
# https://string-functions.com/length.aspx
CONTRACT_FILE = os.path.join("contracts", "examples", "modular_storage.cairo")

@pytest.fixture(scope="session")
async def contract(starknet):
    return await starknet.deploy(source=CONTRACT_FILE,)
  
  
# @pytest.mark.asyncio
# async def test_join_to_outside(contract):
#     await assert_revert(contract.set_element_at(0,0,128).invoke(), "Error felt too big")
    

@pytest.mark.asyncio
@pytest.mark.parametrize("version, traffic_class, flow_label, payload_length, next_header, hop_limit, result",[
    (10, 177, 654321, 33781, 32, 99, 7142854099979934490),
])
async def test_encode_packet_header(contract, version, traffic_class, flow_label, payload_length, next_header, hop_limit, result):
    execution_info = await contract.encode_packet_header(version, traffic_class, flow_label, payload_length, next_header, hop_limit).invoke()
    assert execution_info.result.response == result

@pytest.mark.asyncio
@pytest.mark.parametrize("input, version, traffic_class, flow_label, payload_length, next_header, hop_limit ",[
    (7142854099979934490, 10, 177, 654321, 33781, 32, 99),
])
async def test_decode_packet_header(contract, input, version, traffic_class, flow_label, payload_length, next_header, hop_limit):
    execution_info = await contract.decode_packet_header(input).invoke()
    assert execution_info.result == (version, traffic_class, flow_label, payload_length, next_header, hop_limit)


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
  
  
@pytest.mark.asyncio
async def test_encode_packet_version_too_big(contract):
    await assert_revert(contract.encode_packet_header(16, 1, 1, 1, 1, 1).invoke(), "Error felt too big")
  
@pytest.mark.asyncio
async def test_encode_packet_traffic_class_too_big(contract):
    await assert_revert(contract.encode_packet_header(1, 256, 1, 1, 1, 1).invoke(), "Error felt too big")
  
@pytest.mark.asyncio
async def test_encode_packet_flow_label_too_big(contract):
    await assert_revert(contract.encode_packet_header(1, 1, 1048576, 1, 1, 1).invoke(), "Error felt too big")
  
@pytest.mark.asyncio
async def test_encode_packet_payload_length_too_big(contract):
    await assert_revert(contract.encode_packet_header(1, 1, 1, 65536, 1, 1).invoke(), "Error felt too big")
  
@pytest.mark.asyncio
async def test_encode_packet_next_header_too_big(contract):
    await assert_revert(contract.encode_packet_header(1, 1, 1, 1, 256, 1).invoke(), "Error felt too big")
  
@pytest.mark.asyncio
async def test_encode_packet_hop_limit_too_big(contract):
    await assert_revert(contract.encode_packet_header(1, 1, 1, 1, 1, 256).invoke(), "Error felt too big")

@pytest.mark.asyncio
@pytest.mark.parametrize("version, traffic_class, flow_label, payload_length, next_header, hop_limit, result",[
    (1, 1, 1, 1, 1, 1, 72339073309610001),
    (10, 177, 654321, 33781, 32, 99, 7142854099979934490),
    (15, 255, 1048575, 65535, 255, 255, 18446744073709551615),
])
async def test_encode_packet_header(contract, version, traffic_class, flow_label, payload_length, next_header, hop_limit, result):
    execution_info = await contract.encode_packet_header(version, traffic_class, flow_label, payload_length, next_header, hop_limit).invoke()
    assert execution_info.result.response == result

@pytest.mark.asyncio
@pytest.mark.parametrize("input, version, traffic_class, flow_label, payload_length, next_header, hop_limit ",[
    (72339073309610001, 1, 1, 1, 1, 1, 1),
    (7142854099979934490, 10, 177, 654321, 33781, 32, 99),
    (18446744073709551615, 15, 255, 1048575, 65535, 255, 255),
])
async def test_decode_packet_header(contract, input, version, traffic_class, flow_label, payload_length, next_header, hop_limit):
    execution_info = await contract.decode_packet_header(input).invoke()
    assert execution_info.result == (version, traffic_class, flow_label, payload_length, next_header, hop_limit)


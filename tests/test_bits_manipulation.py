import os

import pytest
from utils import assert_revert
# For bit calculations I used:
# https://www.exploringbinary.com/binary-converter/ 
# https://string-functions.com/length.aspx
CONTRACT_FILE = os.path.join("contracts", "bits_manipulation.cairo")

@pytest.fixture(scope="session")
async def contract(starknet):
    return await starknet.deploy(source=CONTRACT_FILE,)
  
  
# @pytest.mark.asyncio
# async def test_join_to_outside(contract):
#     await assert_revert(contract.set_element_at(0,0,128).invoke(), "Error felt too big")
    


@pytest.mark.asyncio
@pytest.mark.parametrize("position, result",[
    (0,127),
    (1,16256),
    (5,4363686772736),
    (10,149935135831111235534848),
    (20,177012165013336821185939763789146369453719552),
    (30,208979078779793167353681086184783514132807454935464642645273346048),
    (34,56097394306713702464269695648587662877522613725800901920360996891040677888)
])
async def test_generate_get_mask(contract, position, result):
    execution_info = await contract.generate_get_mask(position).invoke()
    assert execution_info.result.mask == result


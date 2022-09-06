import os

import pytest
from utils import assert_revert
CONTRACT_FILE = os.path.join("contracts","performance", "mask_performance.cairo")

@pytest.fixture(scope="session")
async def contract(starknet):
    return await starknet.deploy(source=CONTRACT_FILE,)
  
  
@pytest.mark.asyncio
@pytest.mark.parametrize("position, size, result",[
    (0, 1, 1),
    (0, 2, 3),
    (0, 3, 7),
    (0, 4, 15),
    (0, 5, 31),
    (0, 10, 1023),
    (0, 20, 1048575),
    (0, 50, 1125899906842623),
    (0, 100, 1267650600228229401496703205375),
    (0, 200, 1606938044258990275541962092341162602522202993782792835301375),
    (0, 251, 3618502788666131106986593281521497120414687020801267626233049500247285301247),
])
async def test_mask_methods(contract, position, size, result):
    execution_info1 = await contract.mask_using_substraction(position, size).execute()
    execution_info2 = await contract.mask_using_multiplication(position, size).execute()
    assert execution_info1.result.mask == result
    assert execution_info2.result.mask == result

@pytest.mark.asyncio
@pytest.mark.parametrize("position, result",[
    (0,127),
    (7,16256),
    (35,4363686772736),
    (70,149935135831111235534848),
    (140,177012165013336821185939763789146369453719552),
    (210,208979078779793167353681086184783514132807454935464642645273346048),
    (238,56097394306713702464269695648587662877522613725800901920360996891040677888)
])
async def test_mask_methods_7(contract, position, result):
    execution_info1 = await contract.mask_using_substraction(position, 7).execute()
    execution_info2 = await contract.mask_using_multiplication(position, 7).execute()
    assert execution_info1.result.mask == result
    assert execution_info2.result.mask == result
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
  
  
@pytest.mark.asyncio
async def test_actual_set_element_at(contract):
    pow = 1
    for x in range(251):
        execution_info = await contract.actual_set_element_at(0,x,1,1).invoke()
        assert execution_info.result.response == pow
        pow = pow * 2 

@pytest.mark.asyncio
async def test_actual_get_element_at_1(contract):
    for x in range(251):
        execution_info = await contract.actual_get_element_at(3618502788666131106986593281521497120414687020801267626233049500247285301247,x, 1).invoke()
        assert execution_info.result.response == 1
    
@pytest.mark.asyncio
async def test_actual_get_element_at_0(contract):
    for x in range(251):
        execution_info = await contract.actual_get_element_at(0,x,1).invoke()
        assert execution_info.result.response == 0
    

# To run this test, please add the @view to generate_get_mask
# @pytest.mark.asyncio
# @pytest.mark.parametrize("position, size, result",[
#     (0, 1, 1),
#     (0, 2, 3),
#     (0, 3, 7),
#     (0, 4, 15),
#     (0, 5, 31),
#     (0, 10, 1023),
#     (0, 20, 1048575),
#     (0, 50, 1125899906842623),
#     (0, 100, 1267650600228229401496703205375),
#     (0, 200, 1606938044258990275541962092341162602522202993782792835301375),
#     (0, 251, 3618502788666131106986593281521497120414687020801267626233049500247285301247),
# ])
# async def test_generate_get_mask(contract, position, size, result):
#     execution_info = await contract.generate_get_mask(position, size).invoke()
#     assert execution_info.result.mask == result

# To run this test, please add the @view to generate_get_mask
# @pytest.mark.asyncio
# @pytest.mark.parametrize("position, result",[
#     (0,127),
#     (7,16256),
#     (35,4363686772736),
#     (70,149935135831111235534848),
#     (140,177012165013336821185939763789146369453719552),
#     (210,208979078779793167353681086184783514132807454935464642645273346048),
#     (238,56097394306713702464269695648587662877522613725800901920360996891040677888)
# ])
# async def test_generate_get_mask_7(contract, position, result):
#     execution_info = await contract.generate_get_mask(position, 7).invoke()
#     assert execution_info.result.mask == result



# To run this test, please add the @view to generate_set_mask
# @pytest.mark.asyncio
# @pytest.mark.parametrize("position, size, result",[
#     (0, 1, 3618502788666131106986593281521497120414687020801267626233049500247285301246),
#     (0, 2, 3618502788666131106986593281521497120414687020801267626233049500247285301244),
#     (0, 3, 3618502788666131106986593281521497120414687020801267626233049500247285301240),
#     (0, 4, 3618502788666131106986593281521497120414687020801267626233049500247285301232),
#     (0, 5, 3618502788666131106986593281521497120414687020801267626233049500247285301216),
#     (0, 10, 3618502788666131106986593281521497120414687020801267626233049500247285300224),
#     (0, 20, 3618502788666131106986593281521497120414687020801267626233049500247284252672),
#     (0, 50, 3618502788666131106986593281521497120414687020801267626233048374347378458624),
#     (0, 100, 3618502788666131106986593281521497120414687019533617026004820098750582095872),
#     (0, 200, 3618502788666129500048549022531221578452594679638665104030055717454449999872),
#     (0, 251, 0),
# ])
# async def test_generate_set_mask(contract, position, size, result):
#     execution_info = await contract.generate_set_mask(position, size).invoke()
#     assert execution_info.result.mask == result

# To run this test, please add the @view to generate_set_mask
# @pytest.mark.asyncio
# @pytest.mark.parametrize("position, result",[
#     (0,3618502788666131106986593281521497120414687020801267626233049500247285301120),
#     (7,3618502788666131106986593281521497120414687020801267626233049500247285284991),
#     (35,3618502788666131106986593281521497120414687020801267626233049495883598528511),
#     (70,3618502788666131106986593281521497120414687020801267476297913669136049766399),
#     (140,3618502788666131106986593281521320108249673683980081686469260353877831581695),
#     (210,3618502788457152028206800114167816034229903506668460171297584857602011955199),
#     (238,3562405394359417404522323585872909457537164407075466724312688503356244623359)
# ])
# async def test_generate_set_mask_7(contract, position, result):
#     execution_info = await contract.generate_set_mask(position, 7).invoke()
#     assert execution_info.result.mask == result

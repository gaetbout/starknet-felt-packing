import os

import pytest
# For bit calculations I used:
# https://www.exploringbinary.com/binary-converter/ 
# https://string-functions.com/length.aspx
CONTRACT_FILE = os.path.join("contracts", "examples", "string_manipulation.cairo")

@pytest.fixture(scope="session")
async def contract(starknet):
    return await starknet.deploy(source=CONTRACT_FILE,)

@pytest.mark.asyncio
@pytest.mark.parametrize("input, position, result",[
    ('Bonjour',0,'r'),
    ('Bonjour',1,'u'),
    ('Bonjour',2,'o'),
    ('Bonjour',3,'j'),
    ('Bonjour',4,'n'),
    ('Bonjour',5,'o'),
    ('Bonjour',6,'B'),
    ('Bonjour',7,''),
])
async def test_char_at(contract, input, position, result):
    execution_info = await contract.char_at(str_to_felt(input), position).execute()
    assert execution_info.result.response == str_to_felt(result)

@pytest.mark.asyncio
@pytest.mark.parametrize("input, position, element, response",[
    ('BonjouR',0,'r', 'Bonjour'),
    ('BonjoUr',1,'u', 'Bonjour'),
    ('BonjOur',2,'o', 'Bonjour'),
    ('BonJour',3,'j', 'Bonjour'),
    ('BoNjour',4,'n', 'Bonjour'),
    ('BOnjour',5,'o', 'Bonjour'),
    ('bonjour',6,'B', 'Bonjour'),
    ('Bonjour',7,'0', '0Bonjour'),
])
async def test_set_character_at(contract, input, position, element, response):
    execution_info = await contract.set_character_at(str_to_felt(input), position,str_to_felt(element)).execute()
    assert execution_info.result.response == str_to_felt(response)


@pytest.mark.asyncio
@pytest.mark.parametrize("input, length",[
    ('', 0),
    ('a', 1),
    ('ab', 2),
    ('abc', 3),
    ('abcd',4),
    ('abcdefghijklmnopq',17),
    ('abcdefghijklmnopqrstuvwxyz',26),
    ('abcdefghijklmnopqrstuvwxyz1234',30),
    ('abcdefghijklmnopqrstuvwxyz12345',31),
    
])
async def test_length(contract, input, length):
    execution_info = await contract.length(str_to_felt(input)).execute()
    assert execution_info.result.length == length

def str_to_felt(text):
    if len(text) > 31:
        raise Exception("Text length too long to convert to felt.")

    return int.from_bytes(text.encode(), "big")

# starknet-felt-packing
![Tests](https://github.com/gaetbout/starknet-felt-packing/actions/workflows/nile-tests.yml/badge.svg)

Uint128, Uint256, Uint1024. Ok I get it... We  can do big integers.  
But why not going smaller, what about uint8, uint16, ...  

The idea of this library is to be able to store multiple smaller felts into a 1 felt. As an example it is possible to store 62 felt of size 8 bits (0-255) into 1 felt that you'd store in a storage var. To show this is working, an example of such an application is existing [here](https://github.com/gaetbout/starknet-s-place) with a contract deployed on testnet and a webiste deployed on IPFS.

# Technical explanation
  
  + and system
  + pow 2 use
  + 251 useable bits
  + how to calculate how much we'll be able to store 251 // 8 = quotient, remainder
  + modular system?


# 🌡️ Test

*Prerequisite - Have a working cairo environment.*  
To run the test suite, copy this repository and put yourself at the root.  
Compile the contracts using `make build` or `nile compile`.  
Run the tests using `make test` or, for more details, `pytest -v`.   
For more  details check the Actions tab of this GitHub repository.


# 📄 License

**starknet-s-place** is released under the [MIT](LICENSE).





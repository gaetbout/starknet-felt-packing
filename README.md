![Tests](https://github.com/gaetbout/starknet-felt-packing/actions/workflows/cairo-format-action.yml/badge.svg)  [![Twitter URL](https://img.shields.io/twitter/url.svg?label=Follow%20%40gaetbout&style=social&url=https%3A%2F%2Ftwitter.com%2Fgaetbout)](https://twitter.com/gaetbout)

# starknet-felt-packing

Uint128, Uint256, Uint1024. Ok I get it... We  can do big integers.  
But why not going smaller, what about uint8, uint16, ...  

The idea of this library is to be able to store multiple smaller felts into one bigger felt. As an example it is possible to store 62 felt of size 8 bits (0-255) into one unique felt.  
Another use case could be to manipulate "strings" (understand a chain of character of length < 31 encoded on a single felt).  
To show that this is working, I made an application that exists [here](https://github.com/gaetbout/starknet-s-place) with a contract deployed on testnet and a webiste [deployed on IPFS](https://odd-art-7900.on.fleek.co/).  


### Technical explanation
The technical explanation is available [here](/contracts/lib/README.md)  

### How to use this lib
Please refer to [this file](/contracts/examples/README.md)  

### Performance
If you want to know more about the performance of this library click [here](/contracts/performance/README.md)


## 🌡️ Test

*Prerequisite - Have a working cairo environment.*  
To run the test suite, copy this repository and put yourself at the root.  
Compile the contracts using `make build` or `nile compile`.  
Run the tests using `make test` or, for more details, `pytest -v`.   
For more  details check the Actions tab of this GitHub repository. 


## 📄 License

**starknet-felt-packing** is released under the [MIT](LICENSE).





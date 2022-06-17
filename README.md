# starknet-felt-packing
![Tests](https://github.com/gaetbout/starknet-felt-packing/actions/workflows/nile-tests.yml/badge.svg)

Uint128, Uint256, Uint1024. Ok I get it... We  can do big integers.  
But why not going smaller, what about uint8, uint16, ...  

The idea of this library is to be able to store multiple smaller felts into a 1 felt. As an example it is possible to store 62 felt of size 8 bits (0-255) into 1 felt that you'd store in a storage var. To show this is working, an example of such an application is existing [here](https://github.com/gaetbout/starknet-s-place) with a contract deployed on testnet and a webiste deployed on IPFS.

# Technical explanation
## Bits available
Let's go a bit technical and explain how it works. As you probably know, a number is just a sequence of bits.
For example the bit representation of the number **420** is **110100100**. And we can say that this number has to be encoded on at least 9 bits. It can take more bits, but then they'll be equal to zero and they have to be apended before. If you apend zeros after it'll change the number.  
In [Cairo](https://www.cairo-lang.org/docs/) we only have access (so far) to felts. Those are encoded on 252 bits for which the biggest number is some prime number:  
P = 2<sup>251</sup> + 17 . 2<sup>192</sup> + 1  
And all the calculation are done using a module of this number (see [here](https://www.cairo-lang.org/docs/how_cairo_works/cairo_intro.html) for me info). From that we can't use all 252 bits as we would like because the moment we'll have a number bigger than this prime number it'll automatically be changed to fit within the range. so we effectively have 251 bits we can use.  

## Let's play
Ok, so now that we know how many bits we can use, how to use them?  
The whole trick is to use bitwise operations. And to do so we need to compute a mask andthen apply some bitwise operation.  
Before jumping into the actual logic, I have to spceify that at the moment, the steps for theses bitwise operations are quite high: 12.8 gas/application (see [here](https://docs.starknet.io/docs/Fees/fee-mechanism/)). So for the decompose case it can reach the max steps limit, but it'll be explain there.

## Encoding
  + https://docs.starknet.io/docs/Fees/fee-mechanism/
  + and system
  + pow 2 use

## Decoding

## Decompose
 + explain can hit the limit when trying to decompose 1k felts?

## Storage efficiency 
To know the efficiency of the storage we need to know only on thing which is the number of bits on which your numbers will be encoded. 
Let's say you want to store as much number as possible and each number can be as big as 999 (so 0 to 999) which makes 1000 numbers (yeah I know, I'm kinda good at math).  
First you need to know how much bits it'll take, you can look at [this](/contracts/pow2.cairo) to help you and in this case it'll need 10 bits.  
Now you need to do an euclidian division:  
251 // 10 = quotient=25, remainder=1.
Which means that you can store 25 of these numbers in one felt and 1 bit will stay unused. This makes an efficiency of:
((10*25) / 251) . 100 = 99.6016%  
So this storage will use 99.6016% of the entire felt.

# TODO
  + modular system?
  + doc
  + make an interface


# 🌡️ Test

*Prerequisite - Have a working cairo environment.*  
To run the test suite, copy this repository and put yourself at the root.  
Compile the contracts using `make build` or `nile compile`.  
Run the tests using `make test` or, for more details, `pytest -v`.   
For more  details check the Actions tab of this GitHub repository. 


# 📄 License

**starknet-s-place** is released under the [MIT](LICENSE).





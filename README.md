# starknet-felt-packing
![Tests](https://github.com/gaetbout/starknet-felt-packing/actions/workflows/nile-tests.yml/badge.svg)

Uint128, Uint256, Uint1024. Ok I get it... We  can do big integers.  
But why not going smaller, what about uint8, uint16, ...  

The idea of this library is to be able to store multiple smaller felts into a 1 felt. As an example it is possible to store 62 felt of size 8 bits (0-255) into 1 felt that you'd store in a storage var. To show that this is working, I made an application that is existing [here](https://github.com/gaetbout/starknet-s-place) with a contract deployed on testnet and a webiste deployed on IPFS.  
In the [examples folder](/contracts/examples) you have 2 examples on how this library can be used.  
One is simply to encode an arbitrary number of uint7 into a felt (max 35 in that case).  
The other file is done to show how to store multiple numbers not having all the same length of bits: modular storage. For that example, I picked the [IPV6 packet header](https://en.wikipedia.org/wiki/IPv6_packet). I removed the addresses because it was starting to be a lot of fields (also because a packet would then require to be encoded on two felts, see **Bits available**).

# Technical explanation
## Bits available
Let's go a bit technical and start by assessing how many bits we can actually use.  
As you probably know, a number is just a sequence of bits. For example the bit representation of the number **420** is **110100100**. And we can say that this number has to be encoded on at least 9 bits. It can be encoded on more bits but then they'll be appended before and set to zero. On the other hand, if you apend zeros after it'll change the number.  
In [Cairo](https://www.cairo-lang.org/docs/) we only have access (so far) to felts. Those are encoded on 252 bits for which the biggest number is some prime number:  
P = 2<sup>251</sup> + 17 . 2<sup>192</sup> + 1  
And all the calculation are done using a modulo of this number (see [here](https://www.cairo-lang.org/docs/how_cairo_works/cairo_intro.html) for more info).  
Starting from that fact, we can't use all 252 bits as we would like because the moment we'll have a number bigger than this prime number it'll automatically be changed to fit within the range. so we effectively have 251 bits we can use.  

## Some important notes
This whole library rests on using bitwise operations with the correct mask.  
Before jumping into the actual logic, it is important to note that at the moment the steps for the bitwise operations are quite high: 12.8 gas/application (see [here](https://docs.starknet.io/docs/Fees/fee-mechanism/)).  
In some cases, for example when trying to get all felt within another felt (decompose) it can reach the max steps limit, but it'll be explain there.  

It is also important to explain the reason of the [pow2.cairo file](/contracts/pow2.cairo). Since the algorithm often had to deal with power of 2 to create masks or compute multiplier and divider to do some bit shifting, it is more efficient to store them and access them in O(1) than computing them each time we need to. So this file is there to represent all power of 2 up to 251.  

## Encoding
Let's assume you have the 3 numbers 23 (10111), 4 (100) and 27 (11011). To make it simple let's also assume every numbers uses 5 bits so 100 (4) becomes 00100 (still 4). If you put all those numbers one after the other you obtain 10111 00100 11011 which when turn back into a number is **31899**. Now we need to change the value 4 to 24 (11000). To do that you first need to reset the bits allocated for the 4: 10111 **00100** 11011.
To achieve that you need a mask that will look like this 1111 0000 1111 and make a bitwise operation **and (&)**:

      10111 00100 11011  
    & 11111 00000 11111
      _________________
      10111 00000 11011
Now that we reset that part, we can proceed with setting the new number: 24 (11000). To do so we first need to do some math to add some zeros after and have: 11000 00000. To do so we just need to multiply 24 by 2 <sup>5</sup> (why 5? because it is the number of zeros we have to add).  
24 . (2<sup>5</sup>) = 24 . 32 = 768 (11000 00000). Once we have this number we can proceed to the last part and perform the bitwise operation **or (|)**:

      10111 00000 11011
    | 00000 11000 00000
      _________________
      10111 11000 11011
This result in the new felt that can be returned to the user: 24347 (10111 11000 11011) which encodes 23 (10111), 24 (11000) and 27 (11011).

### Encoding mask
If you are not interested into how to create that mask, you can skip to the next part.  
So how's the mask 11111 00000 11111 created?  
It will always start with the same base which is starting from a state where all bits are set to one:  

      11111 11111 11111  
Then there are two possibilities.  
One way would be to do:  

      2 ^ 5 = 32 (1 00000) # Since the number is encoded on 5 bits
      32 - 1 = 31 (11111) # Make minus 1 to have the 5 bits set all to one 
      31 . 32 = 992 (11111 00000) # We multiply 31 by 32 to add 5 zeros after.

The other way would avoid making that mutliplication would be to 

      2 ^ 10 = 1024 (1 00000 00000) # We do the power of 2 ^ (number of bits to skip= 5 + number of bits of the element=5)
      1024 - 1 = 1023 (11111 11111) # Make minus 1
      2 ^ 5 = 32 (1 00000) # We do the power of 2 ^ (number of bits to skip= 5)
      32 - 1 = 31 (11111) # Make minus 1
      1023 - 31 = 992 (11111 00000) # Remove the last 5 positive bits 

I chose to use the second option because I'm assuming it is less expensive to do 2 fetch in O(1) to pow2 and 1 substraction then to do 1 fetch to pow2 then a multiplication, knowing that this multiplication can be big if for example the user has to modify the bits going from 245 to 250.  
Now that we have the value 992 we can proceed to the last part which is substracting it from the all ones value:

      11111 11111 11111 - 11111 00000 = 11111 00000 11111

We now have the mask that we can return the user.

## Decoding
Let's start from the other bit of the problem here, but we keep the same assumption regarding the length of each number (encoded on 5 bits). Imagine you have the felt 24347 (10111 11000 11011) and you want to extract the number at starting at bit 5 with a length of 5 (11000). To extract that part you first need to clear all bits you don't need, to do that we use another mask 00000 11111 00000 and apply the bitwise operation **and (&)**:

      10111 11000 11011  
    & 00000 11111 00000
      _________________
      00000 11000 00000
We now have 00000 11000 00000 (for which the first 5 bits can be safely ignored). Now the idea is to do some bit shifting to the right (shift 5 bits) and to do so we'll do the exact opposite of the Encoding part. Instead of mutliply 24 by 32 to add 5 bits to the right, we will divide the number we have 11000 00000 (768) by 32 and we'll obtain 11000 (24) which we can return to the user.

### Decoding mask
If you are not interested into how to create that mask, you can skip to the next part.  
So how's the mask 00000 11111 00000 created?  
Since the first 5 bits aren't adding any value, we can remove them (0 10 is equal to 00 00 10, which is also equal to 10).  
Then there are two possibilities.  
One way would be to do:  

      2 ^ 5 = 32 (1 00000) # Since the number is encoded on 5 bits
      32 - 1 = 31 (11111) # Make minus 1 to have the 5 bits set all to one 
      31 . 32 = 992 (11111 00000) # We multiply 31 by 32 to add 5 zeros after.

The other way would avoid making that mutliplication would be to 

      2 ^ 10 = 1024 (1 00000 00000) # We do the power of 2 ^ (number of bits to skip= 5 + number of bits of the element=5)
      1024 - 1 = 1023 (11111 11111) # Make minus 1
      2 ^ 5 = 32 (1 00000) # We do the power of 2 ^ (number of bits to skip= 5)
      32 - 1 = 31 (11111) # Make minus 1
      1023 - 31 = 992 (11111 00000) # Remove the last 5 positive bits 

I chose to use the second option because I'm assuming it is less expensive to 2 fetch in O(1) to pow2 and 1 substraction then 1 fetch to pow2 then a multiplication, knowing that this multiplication can be big if for example the user has to modify the bits going from 245 to 250.  
We now have the value 992 (11111 00000) that can be returned to the user.

## Decompose
This function that exists on the [uint7_packed file](contracts/examples/uint7_packed.cairo) version of  has for purpose to decompose a felt into all the felts that compose it. To stay on the same example, if you give it 24347 and with a bit size of five, it'll return an array: [27, 24, 23]. It'll extract the value from right to left.  
Be careful also not to try and decompose too much felts as it can hit the steps limit. Atfer some tests, I found out that this limit can bit hit if you try and decompose ~8300 smaller felts.  
For the other project I did, I had to use some offset to and decompose the felts batch by batch and not hit that ceiling (and also to reduce the loading time). You can find such an implementation [here].(https://github.com/gaetbout/starknet-s-place/blob/main/contracts/s_place.cairo#L52)

## Storage efficiency 
To know the efficiency of the storage we need to know only on thing which is the number of bits on which your numbers will be encoded.  
Let's say you want to store as much number as possible and each number can be as big as 999 (so 0 to 999) which makes 1000 numbers (yeah I know, I'm kinda good at math).  
First you need to know how much bits it'll take, you can look at [this](/contracts/pow2.cairo) to help you and in this case it'll need 10 bits.  
Now you need to do an euclidian division:  
251 // 10 = quotient=25, remainder=1.
Which means that you can store 25 of these numbers in one felt and 1 bit will stay unused. This makes an efficiency of:
((10*25) / 251) . 100 = 99.6016%  
So this storage will use 99.6016% of the entire felt.


# 🌡️ Test

*Prerequisite - Have a working cairo environment.*  
To run the test suite, copy this repository and put yourself at the root.  
Compile the contracts using `make build` or `nile compile`.  
Run the tests using `make test` or, for more details, `pytest -v`.   
For more  details check the Actions tab of this GitHub repository. 


# 📄 License

**starknet-felt-packing** is released under the [MIT](LICENSE).





# Examples 
## uint7_packed
This is an example that shows how to encode a certain number of integer of a certain size in one felt.  
In this case every integer is encoded on 7 bits which provides a range going from 0 to 127: [0,127].  
Knowing that every felt can take 35 of these integers.
### Decompose
This function has for purpose to decompose a felt into all the felts that compose it. To stay on the same example, if you give it 24347 and with a bit size of five, it'll return an array: [27, 24, 23]. It'll extract the value from right to left.  
Be careful also not to try and decompose too much felts as it can hit the steps limit. Atfer some tests, I found out that this limit can bit hit if you try and decompose ~8300 smaller felts.  
For the other project I did, I had to use some offset to and decompose the felts batch by batch and not hit that ceiling (and also to reduce the loading time). You can find such an implementation [here](https://github.com/gaetbout/starknet-s-place/blob/main/contracts/s_place.cairo#L52).

## string_manipulation

This file allows you to do very simple string manipulation such as char_at to know which character is at which position (check the tests for more information).  
It also allows to update a string encoded on a single felt.  
Last but not least, it can also tell the size of a "string".  
I kept this file limited to show that it is possible to handle strings in Cairo, it just needs to be built.

## modular_storage
This is done to show how to store multiple integers not having all the same length of bits.  
For that example, I picked the [IPV6 packet header](https://en.wikipedia.org/wiki/IPv6_packet). I removed the addresses because it was starting to be a lot of fields and would then have to be encoded on two felts.  


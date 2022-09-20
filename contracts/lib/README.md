
# Technical explanation
## Bits available
Let's go a bit technical and start by assessing how many bits we can actually use.  
As you probably know, a number is just a sequence of bits. For example the bit representation of the number **420** is **110100100**. And we can say that this number has to be encoded on at least 9 bits. It can be encoded on more bits but then they'll be appended before and set to zero. On the other hand, if you apend zeros after it'll change the number.  
In [Cairo](https://www.cairo-lang.org/docs/) we only have access (so far) to felts. Those are encoded on 252 bits for which the biggest number is some prime number:  
P = 2<sup>251</sup> + 17 . 2<sup>192</sup> + 1  
And all the calculation are done using a modulo of this number (see [here](https://www.cairo-lang.org/docs/how_cairo_works/cairo_intro.html) for more info).  
Starting from that fact, we can't use all 252 bits as we would like because the moment we'll have a number bigger than this prime number it'll automatically be changed to fit within the range. so we effectively have 251 bits we can use.  

## Important note
This whole library rests on using bitwise operations with the correct mask.  
Before jumping into the actual logic, it is important to note that at the moment the steps for the bitwise operations are quite high: 12.8 gas/application (see [here](https://docs.starknet.io/docs/Fees/fee-mechanism/)).  
In some cases, for example when trying to get all felt within another felt (decompose) it can reach the max steps limit, but it'll be explain when required.  


## Encoding
Let's assume you have the 3 numbers 23 (10111), 4 (100) and 27 (11011). To make it simple let's also assume every numbers uses 5 bits so 100 (4) becomes 00100 (still 4). If you put all those numbers one after the other you obtain 10111 00100 11011 which when turn back into a number is **31899**. Now we need to change the value 4 to 24 (11000). To do that you first need to reset the bits allocated for the 4: 10111 **00100** 11011.
To achieve that you need a mask that will look like this 1111 0000 1111 and make a bitwise operation **and (&)**:

      10111 00100 11011  
    & 11111 00000 11111
      _________________
      10111 00000 11011
Now that we reset that part, we can proceed with setting the new number: 24 (11000). To do so we first need to do some math to add some zeros after and have: 11000 00000. To do so we just need to multiply 24 by 2 <sup>5</sup> (why 5? because it is the number of zeros we have to add).  
24 . (2<sup>5</sup>) = 24 . 32 = 768 (11000 00000). Once we have this number we can proceed to the last part and add this number to the previous number obtained (the one of the & the bitwise operation).

      10111 00000 11011
    + 00000 11000 00000
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
      2 ^ 5 = 32 (1 00000) # We do the power of 2 ^ (number of bits to skip= 5)
      31 . 32 = 992 (11111 00000) # We multiply 31 by 32 to add 5 zeros after.

The other way would avoid making that mutliplication would be to 

      2 ^ 10 = 1024 (1 00000 00000) # We do the power of 2 ^ (number of bits to skip= 5 + number of bits of the element=5)
      1024 - 1 = 1023 (11111 11111) # Make minus 1
      2 ^ 5 = 32 (1 00000) # We do the power of 2 ^ (number of bits to skip= 5)
      32 - 1 = 31 (11111) # Make minus 1
      1023 - 31 = 992 (11111 00000) # Remove the last 5 positive bits 

I chose to use the second option. See the Performance part for more insights. 
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
      2 ^ 5 = 32 (1 00000) # We do the power of 2 ^ (number of bits to skip= 5)
      31 . 32 = 992 (11111 00000) # We multiply 31 by 32 to add 5 zeros after.

The other way would avoid making that mutliplication would be to 

      2 ^ 10 = 1024 (1 00000 00000) # We do the power of 2 ^ (number of bits to skip= 5 + number of bits of the element=5)
      1024 - 1 = 1023 (11111 11111) # Make minus 1
      2 ^ 5 = 32 (1 00000) # We do the power of 2 ^ (number of bits to skip= 5)
      32 - 1 = 31 (11111) # Make minus 1
      1023 - 31 = 992 (11111 00000) # Remove the last 5 positive bits 


I chose to use the second option. See the Performance part for more insights.
We now have the value 992 (11111 00000) that can be returned to the user
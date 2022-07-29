# Performance

Each contract of the current folder is deployed and made some transactions to fetch their steps using:

      $ starknet invoke --address ${CONTRACT_ADDRESS} --abi ${contract_abi.json} -function ${function_name} -inputs 10
      $ starknet get_transaction_receipt --hash ${TRANSACTION_HASH}
Then there is a section saying the number of steps used (execution_resources.n_steps).  
All the choices described in this section lead to the way this library is done.  
More info about starknet fee mechanism [here](https://docs.starknet.io/docs/Fees/fee-mechanism/).
## Pow2 file
Contract address: [0x07a3995ebf3785128978d2cfeff173c9f0aaa06116d292a51166108dab55734e](https://goerli.voyager.online/contract/0x07a3995ebf3785128978d2cfeff173c9f0aaa06116d292a51166108dab55734e#readContract).  
This contract is there to avoid some more complexity in the calculation of power of 2. Since the algorithm often has to deal with power of 2 to create masks or compute multiplier and divider to do some bit shifting, it is more efficient to store them and access them in O(1) than computing them each time we need it is required.  
Using the [pow function](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/pow.cairo) of starkware will increase the number of steps per calculation:
 - 2<sup>10</sup>: 316 steps
 - 2<sup>20</sup>: 321 steps
 - 2<sup>100</sup>: 332 steps
 - 2<sup>200</sup>: 337 steps

As we can see the costs aren't linear but we can do better. Getting any power of two from the [pow2.cairo file](/contracts/pow2.cairo) is always 281 steps.  

## Mask creation
Contract address: [0x014cceed3a4723314d2e26e45072898691c59f22f83865c84f1721406c66b5f1](https://goerli.voyager.online/contract/0x014cceed3a4723314d2e26e45072898691c59f22f83865c84f1721406c66b5f1#readContract).  
As explained above, there are two possibilities to compute the mask one is by doing 

Empty with 3 builtins: 250 steps
Simple substract: 272
Simple multiplication: 271 ==> more opti same amout of pow fetch but 1 operation less (one minus gone)
Substract 0 1: 296 steps
Substract 0 7: 296 steps
Substract 7 7: 296 steps
Multiplication 0-1: 296 steps
Multiplication 0-7: 296 steps
Multiplication 7-7: 296 steps

ONGOING SECTION 

## Storage efficiency 
To know the efficiency of the storage we need to know only on thing which is the number of bits on which your numbers will be encoded.  
Let's say you want to store as much number as possible and each number can be as big as 999 (so 0 to 999) which makes 1000 numbers (yeah I know, I'm kinda good at math).  
First you need to know how much bits it'll take, you can look at [this](/contracts/pow2.cairo) to help you and in this case it'll need 10 bits.  
Now you need to do an euclidian division:  
251 // 10 = quotient=25, remainder=1.
Which means that you can store 25 of these numbers in one felt and 1 bit will stay unused. This makes an efficiency of:
((10*25) / 251) . 100 = 99.6016%  
So this storage will use 99.6016% of the entire felt.
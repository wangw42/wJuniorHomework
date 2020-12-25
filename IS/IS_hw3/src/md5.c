//
//  md5.c
//  IS
//
//  Created by Yqi on 2020/11/9.
//  Copyright © 2020 Yqi. All rights reserved.
//
#include <memory.h>
#include "md5.h"
 

void MD5_init(MD5 *md5){
    md5->count[0] = 0;
    md5->count[1] = 0;
    // A B C D
    md5->reg[0] = 0x67452301;
    md5->reg[1] = 0xEFCDAB89;
    md5->reg[2] = 0x98BADCFE;
    md5->reg[3] = 0x10325476;
}

static void MD5_memcpy(unsigned char * output, unsigned char * input, UINT4 len){
    for (UINT4 i = 0; i < len; i++)
        output[i] = input[i];
}

static void MD5_memset(unsigned char * output, int value, UINT4 len){
    for (UINT4 i = 0; i < len; i++)
      ((char *)output)[i] = (char)value;
}

void MD5_update(MD5 *md5, unsigned char *input, UINT4 len_in){
    UINT4 i = 0, index = 0, partlen = 0;
    index = (md5->count[0] >> 3) & 0x3F;
    partlen = 64 - index;
    md5->count[0] += len_in << 3;
    if(md5->count[0] < (len_in << 3))
       md5->count[1]++;
    md5->count[1] += len_in >> 29;
    
    if(len_in >= partlen){
       MD5_memcpy(&md5->buffer[index],input,partlen);
       MD5_transform(md5->reg,md5->buffer);
       for(i = partlen;i+64 <= len_in;i+=64)
           MD5_transform(md5->reg,&input[i]);
       index = 0;
    }
    else
        i = 0;
    
    MD5_memcpy(&md5->buffer[index],&input[i],len_in-i);
}


void MD5_final(MD5 *md5,unsigned char digest[16]){
    unsigned char padding[]={0x80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    UINT4 index = 0,padlen = 0;
    unsigned char bits[8];
    index = (md5->count[0] >> 3) & 0x3F;
    padlen = (index < 56)?(56-index):(120-index);
    MD5_encode(bits,md5->count,8);
    MD5_update(md5,padding,padlen);
    MD5_update(md5,bits,8);
    MD5_encode(digest,md5->reg,16);
    MD5_memset ((unsigned char *)md5, 0, sizeof (*md5));
}



void MD5_transform(UINT4 state[4], unsigned char block[64]){
    UINT4 a = state[0];
    UINT4 b = state[1];
    UINT4 c = state[2];
    UINT4 d = state[3];
    UINT4 x[64];
    MD5_decode(x,block,64);
    
    // Round 1
    FF (a, b, c, d, x[ 0], S11, 0xd76aa478); // 1
    FF (d, a, b, c, x[ 1], S12, 0xe8c7b756); // 2
    FF (c, d, a, b, x[ 2], S13, 0x242070db); // 3
    FF (b, c, d, a, x[ 3], S14, 0xc1bdceee); // 4
    FF (a, b, c, d, x[ 4], S11, 0xf57c0faf); // 5
    FF (d, a, b, c, x[ 5], S12, 0x4787c62a); // 6
    FF (c, d, a, b, x[ 6], S13, 0xa8304613); // 7
    FF (b, c, d, a, x[ 7], S14, 0xfd469501); // 8
    FF (a, b, c, d, x[ 8], S11, 0x698098d8); // 9
    FF (d, a, b, c, x[ 9], S12, 0x8b44f7af); // 10
    FF (c, d, a, b, x[10], S13, 0xffff5bb1); // 11
    FF (b, c, d, a, x[11], S14, 0x895cd7be); // 12
    FF (a, b, c, d, x[12], S11, 0x6b901122); // 13
    FF (d, a, b, c, x[13], S12, 0xfd987193); // 14
    FF (c, d, a, b, x[14], S13, 0xa679438e); // 15
    FF (b, c, d, a, x[15], S14, 0x49b40821); // 16

    // Round 2
    GG (a, b, c, d, x[ 1], S21, 0xf61e2562); // 17
    GG (d, a, b, c, x[ 6], S22, 0xc040b340); // 18
    GG (c, d, a, b, x[11], S23, 0x265e5a51); // 19
    GG (b, c, d, a, x[ 0], S24, 0xe9b6c7aa); // 20
    GG (a, b, c, d, x[ 5], S21, 0xd62f105d); // 21
    GG (d, a, b, c, x[10], S22,  0x2441453); // 22
    GG (c, d, a, b, x[15], S23, 0xd8a1e681); // 23
    GG (b, c, d, a, x[ 4], S24, 0xe7d3fbc8); // 24
    GG (a, b, c, d, x[ 9], S21, 0x21e1cde6); // 25
    GG (d, a, b, c, x[14], S22, 0xc33707d6); // 26
    GG (c, d, a, b, x[ 3], S23, 0xf4d50d87); // 27
    GG (b, c, d, a, x[ 8], S24, 0x455a14ed); // 28
    GG (a, b, c, d, x[13], S21, 0xa9e3e905); // 29
    GG (d, a, b, c, x[ 2], S22, 0xfcefa3f8); // 30
    GG (c, d, a, b, x[ 7], S23, 0x676f02d9); // 31
    GG (b, c, d, a, x[12], S24, 0x8d2a4c8a); // 32

    // Round 3
    HH (a, b, c, d, x[ 5], S31, 0xfffa3942); // 33
    HH (d, a, b, c, x[ 8], S32, 0x8771f681); // 34
    HH (c, d, a, b, x[11], S33, 0x6d9d6122); // 35
    HH (b, c, d, a, x[14], S34, 0xfde5380c); // 36
    HH (a, b, c, d, x[ 1], S31, 0xa4beea44); // 37
    HH (d, a, b, c, x[ 4], S32, 0x4bdecfa9); // 38
    HH (c, d, a, b, x[ 7], S33, 0xf6bb4b60); // 39
    HH (b, c, d, a, x[10], S34, 0xbebfbc70); // 40
    HH (a, b, c, d, x[13], S31, 0x289b7ec6); // 41
    HH (d, a, b, c, x[ 0], S32, 0xeaa127fa); // 42
    HH (c, d, a, b, x[ 3], S33, 0xd4ef3085); // 43
    HH (b, c, d, a, x[ 6], S34,  0x4881d05); // 44
    HH (a, b, c, d, x[ 9], S31, 0xd9d4d039); // 45
    HH (d, a, b, c, x[12], S32, 0xe6db99e5); // 46
    HH (c, d, a, b, x[15], S33, 0x1fa27cf8); // 47
    HH (b, c, d, a, x[ 2], S34, 0xc4ac5665); // 48

    // Round 4
    II (a, b, c, d, x[ 0], S41, 0xf4292244); // 49
    II (d, a, b, c, x[ 7], S42, 0x432aff97); // 50
    II (c, d, a, b, x[14], S43, 0xab9423a7); // 51
    II (b, c, d, a, x[ 5], S44, 0xfc93a039); // 52
    II (a, b, c, d, x[12], S41, 0x655b59c3); // 53
    II (d, a, b, c, x[ 3], S42, 0x8f0ccc92); // 54
    II (c, d, a, b, x[10], S43, 0xffeff47d); // 55
    II (b, c, d, a, x[ 1], S44, 0x85845dd1); // 56
    II (a, b, c, d, x[ 8], S41, 0x6fa87e4f); // 57
    II (d, a, b, c, x[15], S42, 0xfe2ce6e0); // 58
    II (c, d, a, b, x[ 6], S43, 0xa3014314); // 59
    II (b, c, d, a, x[13], S44, 0x4e0811a1); // 60
    II (a, b, c, d, x[ 4], S41, 0xf7537e82); // 61
    II (d, a, b, c, x[11], S42, 0xbd3af235); // 62
    II (c, d, a, b, x[ 2], S43, 0x2ad7d2bb); // 63
    II (b, c, d, a, x[ 9], S44, 0xeb86d391); // 64
    
    state[0] += a;
    state[1] += b;
    state[2] += c;
    state[3] += d;
    MD5_memset ((unsigned char*)x, 0, sizeof (x));
}


void MD5_encode(unsigned char *output, UINT4 *input, UINT4 len){
    for (UINT4 i = 0, j = 0; j < len; i++, j += 4) {
      output[j] = (unsigned char)(input[i] & 0xff);
      output[j+1] = (unsigned char)((input[i] >> 8) & 0xff);
      output[j+2] = (unsigned char)((input[i] >> 16) & 0xff);
      output[j+3] = (unsigned char)((input[i] >> 24) & 0xff);
    }
}

void MD5_decode(UINT4 *output,unsigned char *input, UINT4 len){
     for (UINT4 i = 0, j = 0; j < len; i++, j += 4)
       output[i] = ((UINT4)input[j]) | (((UINT4)input[j+1]) << 8) |
         (((UINT4)input[j+2]) << 16) | (((UINT4)input[j+3]) << 24);
}

//
//  md5.h
//  IS
//
//  Created by Yqi on 2020/11/9.
//  Copyright © 2020 Yqi. All rights reserved.
//

#ifndef md5_h
#define md5_h

typedef unsigned int UINT4;

typedef struct{
    UINT4 count[2];  // number of bits, modulo 2^64 (lsb first)
    UINT4 reg[4];   // ABCD
    unsigned char buffer[64];   // input buffer
}MD5;
 
/* 四个基础线性函数
 */
#define F(x, y, z) (((x) & (y)) | ((~x) & (z)))
#define G(x, y, z) (((x) & (z)) | ((y) & (~z)))
#define H(x, y, z) ((x) ^ (y) ^ (z))
#define I(x, y, z) ((y) ^ ((x) | (~z)))

/* ROTATE_LEFT 将x左移n个bits
 */
#define ROTATE_LEFT(x, n) (((x) << (n)) | ((x) >> (32-(n))))

/* 四个数据处理函数 FF, GG, HH, II , xj表示第j个数
 */
#define FF(a, b, c, d, xj, s, ac) { \
 (a) += F ((b), (c), (d)) + (xj) + (UINT4)(ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
  }
#define GG(a, b, c, d, xj, s, ac) { \
 (a) += G ((b), (c), (d)) + (xj) + (UINT4)(ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
  }
#define HH(a, b, c, d, xj, s, ac) { \
 (a) += H ((b), (c), (d)) + (xj) + (UINT4)(ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
  }
#define II(a, b, c, d, xj, s, ac) { \
 (a) += I ((b), (c), (d)) + (xj) + (UINT4)(ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
  }

/* Constants for MD5Transform routine.
 */

#define S11 7
#define S12 12
#define S13 17
#define S14 22
#define S21 5
#define S22 9
#define S23 14
#define S24 20
#define S31 4
#define S32 11
#define S33 16
#define S34 23
#define S41 6
#define S42 10
#define S43 15
#define S44 21

void MD5_init(MD5 *);

void MD5_update(MD5 * , unsigned char *, UINT4 );

void MD5_final(MD5 *, unsigned char [16]);

void MD5_transform(unsigned int [4],unsigned char [64]);

void MD5_encode(unsigned char *, UINT4 *, UINT4 );

void MD5_decode(UINT4 *, unsigned char *, UINT4 );
 

#endif /* md5_h */

//
//  main.c
//  IS
//
//  Created by Yqi on 2020/11/9.
//  Copyright © 2020 Yqi. All rights reserved.
//

#include "hmac_md5.h"

void test1(void );
void test2(void );
void test3(void );
 
int main(int argc, char *argv[]){
    test1();
    test2();
    test3();
    return 0;
}

void test1(){
    printf("------- Test1 -------\n");
    char  * msg = "Hello world";
    char  * key = "key";
    
    unsigned char * out = (unsigned char *)malloc(16);
    out = hmac_md5( (unsigned char *)msg , (unsigned char *)key );
    int i;
    printf("Msg: %s \nKey: %s \nHMAC_MD5: ", msg, key);
    for ( i = 0; i < 16; i++)
        printf("%02x", out[i]);
    printf("\n");
    
}

void test2(){
    printf("\n------- Test2 -------\n");
    char  * msg = "QWERTYUIOPASDFGHJKLZXCVBNMQWERTYUIOPSDFGHJKZXVBNMASDFGHJKLqwertyui";
    char  * key = "12345678901234567890123456789012345678901234567890123456789012345678901234567890";
    
    unsigned char * out = (unsigned char *)malloc(16);
    out = hmac_md5( (unsigned char *)msg , (unsigned char *)key );
    int i;
    printf("Msg: %s \nKey: %s \nHMAC_MD5: ", msg, key);
    for ( i = 0; i < 16; i++)
        printf("%02x", out[i]);
    printf("\n");
}

void test3(){
    printf("\n------- Test3 -------\n");
    char  * msg = "12345678901234567890123456789012345678901234567890123456789012345678901234567890";
    char  * key = "QWERTYUIOPASDFGHJKLZXCVBNMQWERTYUIOPSDFGHJKZXVBNMASDFGHJKLqwertyui";
    
    unsigned char * out = (unsigned char *)malloc(16);
    out = hmac_md5( (unsigned char *)msg , (unsigned char *)key );
    int i;
    printf("Msg: %s \nKey: %s \nHMAC_MD5: ", msg, key);
    for ( i = 0; i < 16; i++)
        printf("%02x", out[i]);
    printf("\n");
}

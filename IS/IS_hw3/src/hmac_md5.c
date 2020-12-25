//
//  hmac_md5.c
//  IS
//
//  Created by Yqi on 2020/11/12.
//  Copyright © 2020 Yqi. All rights reserved.
//

#include "hmac_md5.h"

unsigned char* hmac_md5( unsigned char* message, unsigned char* key){
    UINT4 msg_len = (UINT4)strlen(message);
    UINT4 key_len = (UINT4)strlen(key);
    unsigned char * ret = (unsigned char *)malloc(16);
    
    char ipad = 0x36;;
    char opad = 0x5c;;
    MD5 md5;
    
    unsigned char _key[64];
    for (int i = 0; i < 64; i++)
        _key[i] = 0;
    
    unsigned char tmp_key[16];
    if ( key_len > 64){
        MD5_init(&md5);
        MD5_update(&md5, key, key_len);
        MD5_final(&md5,tmp_key);
        for (int i = 0; i < 16; i++)
            _key[i] = tmp_key[i];
    } else{
        for (int i = 0; i < key_len; i++)
            _key[i] = key[i] ;
    }
    
    // ipad opad
    unsigned char* tmp1 = (unsigned char* )malloc(64+msg_len+1);
    for (int i = 0; i < 64; i++)
        tmp1[i] = _key[i] ^ ipad;
    
    for(int i = 64; i < 64+msg_len; i++)
        tmp1[i] = message[i-64];
    
    unsigned char* tmp2 = (unsigned char* )malloc(64+16+1);
    for (int i = 0 ; i < 64; i++ )
        tmp2[i] = _key[i] ^ opad;
    
    unsigned char tmp3[16];
    MD5_init(&md5);
    MD5_update( &md5, tmp1, 64 + msg_len);
    MD5_final(&md5, tmp3);
    
    for (int i = 64 ; i < (64 + 16); i++)
        tmp2[i] = tmp3[i - 64];
    
    MD5_init(&md5);
    MD5_update( &md5, tmp2, 64 + 16);
    MD5_final(&md5,ret);
    
    free(tmp1);
    free(tmp2);
    
    return ret;
}

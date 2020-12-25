//
//  hmac_md5.h
//  IS
//
//  Created by Yqi on 2020/11/12.
//  Copyright © 2020 Yqi. All rights reserved.
//

#ifndef hmac_md5_h
#define hmac_md5_h


#include "md5.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


unsigned char* hmac_md5( unsigned char* message, unsigned char* key);


#endif /* hmac_md5_h */

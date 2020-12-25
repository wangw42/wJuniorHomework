# 信息安全Assignment 2

选择一对大素数p, q，用C语言实现一个实际可用的RSAES-PKCS1-v1_5体系，包括：

- 原理描述，数据结构设计，密钥生成，加密，解密，编解码
- C语言源码，编译运行结果，验证用例



*src文件夹为源代码文件夹，里面包含test.c、rsa.h、rsa.c*

### 原理描述

* 共钥和私钥的产生

  * 选择两个不同的大素数$p$和$q$，计算$N=pq$

  * 引用欧拉$\phi$函数，小于$N$且与$N$互素的正整数个数为：$\phi (N) = \phi(pq) = \phi(p)\phi(q) = (p-1)(q-1)$

  * 选择一个整数$e$，$1<e<\phi(N)$且$gcd(e,\phi(N)) = 1$

  * 求一个满足下列同余式的$d$

    $ed \equiv 1(mod\phi(N))$

    * $d$是$e$的模$\phi(N)$逆元，可以应用**扩展欧几里得算法**得到
    * $d$必须是一个足够大的正整数

  * 将$p$和$q$的记录销毁

  * 以$(e,N)$作为共钥，$(d,N)$作为私钥

* 加密消息

  * B给A送一个消息$M$，他知道A的共钥$(e,N)$
  * B使用事先与A约好的格式将M转换为一个小于$N$的整数$n$
  * B引用共钥$(e,N)$，利用下面的公式将$n$加密为$c$：$c=n^emodN$
  * B算出$c$后可以将它经过公开媒体传给A

* 解密消息

  * A得到B的消息$c$后利用他的私钥$(d,N)$解码
  * A用以下公式将$c$转换为$n'$：$n'=c^dmodN$
  * A得到的$n'$就是B的$n$，因此可以将原来的信息$M$准确复原

* 解码原理

  **欧拉定理**：对互素的$a$和$m$，有 $a^{\phi(m)} \equiv 1(mod \ m)$

  推论：给定满足$N=pq$的两个不同素数 $p$和 $q$ 以及满足 $0<n<N$的整数 $n$， $k$是正整数，有 $n^{k\phi(N)+1} \equiv n(mod \ N)$



### 数据结构设计

密钥数据结构：

```c
struct Key{
	// two big primes
    long long p, q;
    // public exponent
    long long e;
    //public modulus
    long long n;
    //private exponent
    long long d;
};
```

其他如信息message、加密解密后的密文，都用数组结构来存储。



### 密钥生成

```c
void generate_key(long long INI_P, long long INI_Q, struct Key *key){
    long long p = INI_P;
    long long q = INI_Q;
    long long e = 0;
    long long d = 0;
    long long n = p*q;
    long long phi = (p-1)*(q-1);
    
    srand((unsigned)time(NULL));
    while(1){
        e = rand()%n;
        if(e == 0) continue;
        if(gcd(phi, e) == 1) break;
    }
    
    d = ext_euclid(phi, e);
    while(d < 0)
        d += phi;
    
    key->p = p;
    key->q = q;
    key->n = n;
    key->e = e;
    key->d = d;
}

//对应使用的gcd函数及扩展欧几里得算法函数如下
long long gcd(long long a, long long b){
    long long  c;
    while ( a != 0 ) {
        c = a; a = b%a;  b = c;
    }
    return b;
}

long long ext_euclid(long long a, long long b){
    long long x = 0, y = 1, u = 1, v = 0, gcd = b, m, n, q, r;
    while (a!=0) {
        q = gcd/a;
        r = gcd % a;
        m = x-u*q;
        n = y-v*q;
        gcd = a;
        a = r;
        x = u;
        y = v;
        u = m;
        v = n;
   }
   return y;
}
```



### 加密和解密

加密和解密的实现比较简单，对每个字符进行指数和求模操作就可以，注意传入对应的共钥私钥

```c
long long * rsa_encrypt(const char* message, const unsigned long message_size,
                        const struct Key * key){
    long long* ret = malloc(sizeof(long long)*message_size);
    
    for(long long i = 0; i < message_size; i++)
        ret[i] = mod_exp(message[i], key->e, key->n);
    
    return ret;
}

char *rsa_decrypt(const long long* message, const unsigned long message_size,const struct Key * key){
    char * ret = malloc(message_size*sizeof(char));
    
    for(long long i = 0; i < message_size; i++)
        ret[i] = mod_exp(message[i], key->d, key->n);
    
    return ret;
}

//加密解密过程中使用的指数及mod操作函数如下
long long mod_exp(long long b, long long e, long long n){
    long long ret = 1;
    e = e + 1;
    
    while(e != 1){
        ret *= b;
        ret %= n;
        e--;
    }
    
    return ret;
}
```



### 编译运行结果

![](./images/is2_1.png)

* 验证用例

  在test.c里主要做了三个测试：小素数pq、大素数pq、用户输入随机pq，同时每一部分给了不同的message，也包含了比较长且有各种字符的message。

  其他测试也可以通过直接修改test.c函数来完成测试。
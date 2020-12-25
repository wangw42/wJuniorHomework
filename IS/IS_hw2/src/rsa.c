#include "rsa.h"

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

void display(struct Key *key){
      printf("Key: p = %lld, q = %lld, e = %lld, n = %lld, d = %lld\n", key->p, key->q, key->e, key->n, key->d);
}

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

#ifndef rsa_h
#define rsa_h

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>

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

long long gcd(long long a, long long b);
long long ext_euclid(long long a, long long b);
void generate_key(long long INI_P, long long INI_Q, struct Key *key);
void display(struct Key *key);

long long mod_exp(long long b, long long e, long long n);
long long * rsa_encrypt(const char* message, const unsigned long message_size,
const struct Key * key);
char *rsa_decrypt(const long long* message, const unsigned long message_size,const struct Key * key);

#endif /* rsa_h */

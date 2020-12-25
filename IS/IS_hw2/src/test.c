
#include "rsa.h"

void templates(long long p, long long q, char* message, struct Key *key);
void test1_littlePrimes(void);
void test2_bigPrimes(void);
void test3_input(void);

int main(){
    test1_littlePrimes();
    test2_bigPrimes();
    test3_input();
    
    return 0;
}
void templates(long long p, long long q, char* message, struct Key *key){
    printf("The messages is: %s \n", message);
    
    printf("Its corresponding code is: \n");
    for(int i=0; i < strlen(message); i++){
      printf("%lld ", (long long)message[i]);
    }
    printf("\n");
    
    printf("After RSA encrypt: \n");
    long long *encry = rsa_encrypt(message, strlen(message), key);
    for(int i=0; i < strlen(message); i++){
      printf("%lld ", (long long)encry[i]);
    }
    printf("\n");
    
    printf("After RSA decrypt: \n");
    char* decry = rsa_decrypt(encry, strlen(message), key);
    for(int i=0; i < strlen(message); i++){
      printf("%lld ", (long long)decry[i]);
    }
    printf("\n");
    for(int i=0; i < strlen(message); i++){
      printf("%c", decry[i]);
    }
    printf("\n");
}

void test1_littlePrimes(void){
    printf("---------- Test1: little primes ----------\n");
    struct Key *key = (struct Key*)malloc(sizeof(struct Key));
    long long p = 17, q = 19;
    generate_key(p,q,key);
    display(key);
    
    char message[] = "helloworld!#Helloworld!*helloWorld!_helloworld! HELLOWORLD!";
    templates(p, q, message, key);
}

void test2_bigPrimes(void){
    printf("---------- Test2: big primes ----------\n");
    struct Key *key = (struct Key*)malloc(sizeof(struct Key));
    long long p = 10007, q = 10009;
    generate_key(p,q,key);
    display(key);
    
    char message[] = "test2bigprimes!";
    templates(p, q, message, key);
}

void test3_input(void){
    printf("---------- Test3: input primes----------\n");
    struct Key *key = (struct Key*)malloc(sizeof(struct Key));
    long long p, q;
    printf("Please input p and q: \n");
    scanf("%lld%lld", &p, &q);
    generate_key(p,q,key);
    display(key);
    
    char message[] = "Test 3";
    templates(p, q, message, key);
};

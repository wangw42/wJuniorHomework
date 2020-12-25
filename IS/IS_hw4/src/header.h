#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include <openssl/sha.h>
#include <openssl/des.h>
#include <time.h>
#include <fcntl.h>
#include <netdb.h>
#include <sys/utsname.h>
#include <arpa/inet.h>  
#include <stdlib.h>    
#include <string.h>     
#include <unistd.h>    
#include <openssl/conf.h>
#include <openssl/evp.h>
#include <openssl/err.h>


#define AS_REQ          1
#define AS_REP          2	
#define AS_ERR          3	
#define S_REQ           4	
#define S_REP           5
#define S_ERR           6
#define PKT             7
#define APP_DATA_REQ    14
#define APP_DATA        15

#define ERR             -1
#define LIFETIME        3600	
#define TICKET_SIZE     144	
#define CRED_SIZE       240	


struct ticket{
	unsigned char AES_key[32];      
    unsigned char client_name[40];	
    unsigned char server_name[40];	
    time_t time_stamp;			
    int life_time;				
};


struct credential {
	unsigned char AES_key[32];     
    unsigned char server_name[40];	
    time_t time_stamp;			
    int life_time2;		
    int ticket_length;			
    unsigned char ticket_enc[TICKET_SIZE];
};

struct as_req {
    short type;			
    unsigned char client_name[40];	
    unsigned char server_name[40];	
    time_t time_stamp1;
};

struct as_rep {
    short type;			
    short cred_length;		
    unsigned char cred[CRED_SIZE];	
};

struct as_err{
	short type;			
	unsigned char client_name[40];	
};

struct auth{
    unsigned char client_name[40];		
    time_t time_stamp3;				
};

struct s_req{
    short type;				
    short ticket_length;			
    short auth_length;			
    unsigned char ticket_enc[TICKET_SIZE];	
    unsigned char auth[64];		
};

struct s_rep{
    short type;			
    short nonce_length;		
    unsigned char nonce[16];	
};


struct s_err{
	short type;			
	unsigned char client_name[40];
};

struct pkt {
    short type;			
    short pkt_length;		
    unsigned char pkt_enc[976];	
};

struct pdata {
    short     type;			
    short     packet_length;		
    short     pid;			
    unsigned char    data[960];	
};

int encrypt(unsigned char *plaintext, int plaintext_len, unsigned char *key,
            unsigned char *iv, unsigned char *ciphertext);

int decrypt(unsigned char *ciphertext, int ciphertext_len, unsigned char *key,
            unsigned char *iv, unsigned char *plaintext);
            
void printError(char *errorMessage) ;


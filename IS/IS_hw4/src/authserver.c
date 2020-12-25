#include "header.h"


int main(int argc, char *argv[]){
                           
    if (argc != 6) exit(1);
    
    unsigned short server_port = atoi(argv[1]);  
    unsigned char *server_name = argv[2];      
    unsigned char *server_key = argv[3];      
    unsigned char *client_name = (argv[4]);   
    unsigned char *client_key = argv[5];    
        
    int sock; 
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0)
        printError("socket() failed");

    // 构造地址
    struct sockaddr_in auth_addr; 
    memset(&auth_addr, 0, sizeof(auth_addr));   
    auth_addr.sin_family = AF_INET;               
    auth_addr.sin_addr.s_addr = htonl(INADDR_ANY); 
    auth_addr.sin_port = htons(server_port);    

    struct sockaddr_in client_addr; 
    memset(&client_addr, 0, sizeof(client_addr));  
    client_addr.sin_family = AF_INET;               
    client_addr.sin_addr.s_addr = htonl(INADDR_ANY); 
    client_addr.sin_port = htons(server_port);      

    // bind to auth
    if (bind(sock, (struct sockaddr *) &auth_addr, sizeof(auth_addr)) < 0)
        printError("bind() failed");
    
    struct as_req auth_req;
    memset(&auth_req, 0, sizeof(auth_req));

    // 从client接收请求
    unsigned int recv_msg_len; 
    unsigned int client_addr_len = sizeof(client_addr);
    if ((recv_msg_len = recvfrom(sock, &auth_req, sizeof(struct as_req), 0,
            (struct sockaddr *) &client_addr, &client_addr_len)) < 0){
                   printError("recvfrom() failed");
    } else printf("recvfrom() succeed, from client.\n");
	
    // 处理并返回
    if (auth_req.type != AS_REQ) {
        struct as_err failure;
        failure.type = AS_ERR;
        memset(&failure.client_name, 0, 40);
        memcpy(&failure.client_name, client_name, sizeof(client_name));
        if (sendto(sock, (struct as_rep*)&failure, sizeof(failure), 0, (struct sockaddr *)&client_addr, sizeof(client_addr)) != sizeof(failure)){
            printError("sendto() failed");
        } else{
		    printf("sendto() succeed, to client.\n");
		}  
        printError("Incorrect Packet Type.");
    }
    
    struct ticket t2;
    memset(&t2, 0, sizeof(t2));
    int t2_len;
    t2_len = sizeof(struct ticket);
    unsigned char secret_key[32];
    memset(&secret_key, 0, 32);
    memcpy(&secret_key, "abcdefghijklmnopqrstuvwxyzabcdef", 32);
    memcpy(t2.AES_key, secret_key, sizeof(secret_key)); 
    memcpy(&t2.client_name, auth_req.client_name, strlen(auth_req.client_name)); 
    memcpy(&t2.server_name, auth_req.server_name, strlen(auth_req.server_name));

    t2.time_stamp = time(NULL);
    t2.life_time = LIFETIME;
    unsigned char key[32];
    memset(key, 0, 32);
    strcpy(key, client_key);
    unsigned char skey[32];
    memset(skey, 0, 32);
    strcpy(skey, server_key);

    fflush(stdout);
    
    unsigned char t2_cipher[TICKET_SIZE];
    unsigned char iv[16];
    memset(iv, 0, 16);
    int ciphertext_t2_len = encrypt((unsigned char *)&t2, sizeof(struct ticket), skey, iv, t2_cipher);

    //credential
    struct credential cred;
    memset(&cred, 0, sizeof(cred));
    memcpy(&cred.AES_key, secret_key, strlen(cred.AES_key+1));
    memcpy(&cred.server_name, server_name, strlen(cred.server_name));
    cred.time_stamp = time(NULL);
    cred.life_time2 = LIFETIME;
    cred.ticket_length = ciphertext_t2_len;
    memcpy(&cred.ticket_enc, t2_cipher, ciphertext_t2_len);
    
    // 加密credential
    unsigned char credential_cipher[CRED_SIZE];
    int ciphertext_cred_len = encrypt((unsigned char *)&cred, sizeof(struct credential), key, iv, credential_cipher);
    

    // response
    struct as_rep auth_rep;
    memset(&auth_rep, 0, sizeof(auth_rep));
    auth_rep.type = AS_REP;
    auth_rep.cred_length = ciphertext_cred_len;
    memcpy(&auth_rep.cred, credential_cipher , ciphertext_cred_len);
   

    if (sendto(sock, (struct as_rep*)&auth_rep, sizeof(auth_rep), 0, (struct sockaddr *)&client_addr, sizeof(client_addr)) != sizeof(auth_rep)){
        printError("sendto() failed"); 
    } else {
        printf("sendto() succeed, to client.\n"); 
    }
   
    printf("Mission succeed.\n");
    exit(0);  
   
}



#include "header.h"

int main(int argc, char *argv[]) {
    if (argc != 3) exit(1);
    unsigned short server_port = atoi(argv[1]);  
    char * server_key = argv[2]; 

    // 创建socket
    int sock;
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0)
        printError("socket() failed");

    // 构造server完整地址
    struct sockaddr_in server_addr; 
    struct sockaddr_in client_addr; 
    memset(&server_addr, 0, sizeof(server_addr));   
    server_addr.sin_family = AF_INET;                
    server_addr.sin_addr.s_addr = htonl(INADDR_ANY); 
    server_addr.sin_port = htons(server_port);      

    // bind
    struct s_req s_request;
    if (bind(sock, (const struct sockaddr *) &server_addr, sizeof(server_addr)) < 0)
        printError("bind() failed");

    // 接收client请求
    unsigned int client_addr_len = sizeof(client_addr);
    int recv_msg_size;  
    if ((recv_msg_size = recvfrom(sock, &s_request, sizeof(struct s_req), 0, (struct sockaddr *) &client_addr, &client_addr_len)) < 0){
        printError("recvfrom() failed");
    }else{
        printf("recvfrom() succeed, from client.\n");
    }


    // 解密client请求
    unsigned char area_decrypted[1024];
    struct ticket v2;
    int decryptsize;
    unsigned char iv[16];
    memset(iv, 0, 16);
    unsigned char secret_key[32];
    memset(&secret_key, 0, 32);
    memcpy(&secret_key, "abcdefghijklmnopqrstuvwxyzabcdef", 32);
    unsigned char key[32];
    memset(key, 0, 32);
    strcpy(key, server_key);
    decryptsize = decrypt(s_request.ticket_enc, s_request.ticket_length, key, iv, (unsigned char*)area_decrypted);
    
    memcpy(&v2, area_decrypted, decryptsize);
    memcpy(&v2.AES_key, secret_key, 32);


    unsigned char auth_decrypted[1024]; 
    memset(auth_decrypted, 0, 1024);
    struct auth v3; 
    int autn_dec_size; 
    
    // 解密auth
    autn_dec_size = decrypt(s_request.auth,  s_request.auth_length, secret_key, iv, (unsigned char*)auth_decrypted);
    memcpy(&v3, auth_decrypted, autn_dec_size);
    v3.time_stamp3 = v2.time_stamp+1;

    // 回复client
    unsigned char ticket_id[40];
    unsigned char autn_id[40];
    strcpy(ticket_id, v2.client_name);
    strcpy(autn_id, v3.client_name);
    if (*ticket_id != *autn_id) {
        struct s_err failure;
        failure.type = S_ERR;
        memset(&failure.client_name, 0, 40);
        memcpy(&failure.client_name, v3.client_name, sizeof(v3.client_name));
        if (sendto(sock, (struct s_err*)&failure, sizeof(failure), 0, (struct sockaddr *) &client_addr, sizeof(client_addr)) != sizeof(failure)){
            printError("sendto() failed");
        }else{
           	printf("sento() succeed, to client.\n");
       	}
        printError("Client ID is not Authenticated");

    }
    unsigned char nonce_cipher[16];
    memset(&nonce_cipher, 0, sizeof(long int));
    int nonce_ciphertext_len = encrypt((unsigned char *) &v3.time_stamp3, sizeof(long int), secret_key, iv, nonce_cipher);
    

    struct s_rep s_response;
    memset(&s_response, 0, sizeof(s_response));
    s_response.type = S_REP;
    s_response.nonce_length = sizeof((v2.time_stamp+1));
    memcpy(&s_response.nonce, (unsigned char *) &nonce_cipher, sizeof(nonce_cipher));
    if (sendto(sock, (struct s_rep*)&s_response, (sizeof(s_response)), 0, (struct sockaddr *) &client_addr, client_addr_len) != sizeof(s_response)){
        printError("sendto() sent a different number of bytes than expected");
    }else{
         printf("sento() succeed, to client.\n");
    }

    struct pkt client_msg;
    if ((recv_msg_size = recvfrom(sock, &client_msg, sizeof(struct pkt), 0,(struct sockaddr *) &client_addr, &client_addr_len)) < 0){
        printError("recvfrom() failed");
    }else{
        printf("recvfrom() succeed, from client.\n");
    }

    if (client_msg.type != PKT) {
        struct s_err failure;
        failure.type = S_ERR;
        memset(&failure.client_name, 0, 40);
        memcpy(&failure.client_name, v3.client_name, sizeof(v3.client_name));
        if (sendto(sock, (struct s_err*)&failure, sizeof(failure), 0, (struct sockaddr *)&client_addr, sizeof(client_addr)) != sizeof(failure)){
            printError("sendto() failed");
        }else{
           	printf("sento() succeed, to client.\n");
       	}
        printError("Time stamp was not authenticated");
    }
    struct pdata s_pdata;
    memset(&s_pdata, 0, sizeof(s_pdata));
    int decrypted_s_pdata_len = decrypt(client_msg.pkt_enc, client_msg.pkt_length, secret_key, iv, (unsigned char *) &s_pdata);
    struct pdata s_pdata2;
    memset(&s_pdata2, 0, sizeof(s_pdata2));
    s_pdata2.type = APP_DATA;
    unsigned char* str = "Message send from server to client.";
    s_pdata2.packet_length = strlen(str);  
                                            
    s_pdata2.pid = s_pdata.pid + 1;	
    memcpy(s_pdata2.data, str, strlen(str));

    unsigned char s_pdata2_cipher[960];
    memset(&s_pdata2_cipher, 0, sizeof(s_pdata2_cipher));
    int s_pdata2_ciphertext_len = encrypt((unsigned char *) &s_pdata2, sizeof(struct ticket), secret_key, iv, s_pdata2_cipher);

    struct pkt msg_back;
    memset(&msg_back, 0, sizeof(msg_back));
    msg_back.type = PKT;
    msg_back.pkt_length = s_pdata2_ciphertext_len;     
    memcpy(msg_back.pkt_enc, s_pdata2_cipher, s_pdata2_ciphertext_len); 
    if (sendto(sock, (struct s_rep*)&msg_back, (sizeof(msg_back)), 0, (struct sockaddr *) &client_addr, client_addr_len) != sizeof(msg_back)){
        printError("sendto() sent a different number of bytes than expected");
    } else{
	    printf("sento() succeed, to client.\n");
    }

    printf("Mission succeed.\n");
    exit(0);
}
    



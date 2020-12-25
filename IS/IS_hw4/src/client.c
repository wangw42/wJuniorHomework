#include "header.h"


int main(int argc, char *argv[]){  
    if ((argc > 9) || (argc < 7)) exit(1);
    
    char *auth_ip = argv[1];        
    unsigned short auth_port = atoi(argv[2]);             
    char* server_ip = argv[3];   
    unsigned short server_port = atoi(argv[4]); 
    char *server_name = argv[5]; 
    char *clent_name = argv[6];          
    unsigned char* clent_key = argv[7];     
 
    int sock;
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0)
        printError("socket() failed");

    struct sockaddr_in server_addr; 
    memset(&server_addr, 0, sizeof(server_addr));    
    server_addr.sin_family = AF_INET;                 
    server_addr.sin_addr.s_addr = inet_addr(server_ip);  
    server_addr.sin_port   = htons(server_port);    

    struct sockaddr_in auth_addr;
    memset(&auth_addr, 0, sizeof(auth_addr));    
    auth_addr.sin_family = AF_INET;                
    auth_addr.sin_addr.s_addr = inet_addr(auth_ip);  
    auth_addr.sin_port   = htons(auth_port);    

    struct as_req auth_req;
    memset(&auth_req, 0, sizeof(auth_req));    
    auth_req.type = AS_REQ;              
    memcpy(&auth_req.client_name, clent_name, strlen(clent_name));
    memcpy(&auth_req.server_name, server_name, strlen(server_name));
    auth_req.time_stamp1 = time(NULL);
   
    // 向auth发送请求
    if (sendto(sock, (struct as_req*)&auth_req, sizeof(auth_req), 0, (struct sockaddr *) &auth_addr, sizeof(auth_addr)) != sizeof(auth_req)){
        printError("sendto() sent a different number of bytes than expected");
    }else{
		printf("sento() succeed, to auth.\n");
	}
        
   
    // 接收auth消息
    struct as_rep auth_rep;
    struct sockaddr_in client_addr;
    int client_name_len = sizeof(client_addr);
    client_name_len = sizeof(auth_addr);
    int rep_len; 
    if ((rep_len = recvfrom(sock, &auth_rep, sizeof(struct as_rep), 0, (struct sockaddr *) &auth_addr, &client_name_len)) < 0) {
        printError("recvfrom() failed");
    }else{
		printf("recvfrom() succeed, from auth.\n");	
	}
    if(auth_rep.type != AS_REP) {
        printError("Client sent incorrect message");
    }
           
    unsigned char key[32];
    memset(key, 0, 32);
    strcpy(key, clent_key);

    unsigned char area_decrypted[1024];
    struct credential cred;

    int decryptsize;
    unsigned char iv[16];
    memset(iv, 0, 16);

    decryptsize = decrypt(auth_rep.cred, auth_rep.cred_length, key, iv, area_decrypted);
    
    memcpy(&cred, area_decrypted, decryptsize);
    
    struct auth Authenticator;
    memcpy(&Authenticator.client_name, clent_name, client_name_len);
    Authenticator.time_stamp3 = time(NULL);

    struct s_req s_request;
    s_request.type = S_REQ;
    memcpy(s_request.ticket_enc, cred.ticket_enc, cred.ticket_length);
    s_request.ticket_length = cred.ticket_length;
    
    unsigned char AuthEncrypted[64];
    unsigned char secret_key[32];
    memset(&secret_key, 0, 32);
    memcpy(&secret_key, "abcdefghijklmnopqrstuvwxyzabcdef", 32);
    int AuthLength = encrypt((unsigned char*)&Authenticator, sizeof(struct auth), secret_key, iv, AuthEncrypted);
    memcpy(&s_request.auth, AuthEncrypted, AuthLength);
    s_request.auth_length = AuthLength;

    if (sendto(sock, (struct s_req*)&s_request, sizeof(s_request), 0, (struct sockaddr *) &server_addr, sizeof(server_addr)) != sizeof(s_request)){
        printError("sendto() sent a different number of bytes than expected");
    }else{
        printf("sendto() succeed, to server.\n");
    }


    struct s_rep s_response;
    memset(&s_response, 0, sizeof(s_response));
    int echoServLength = sizeof(server_addr);
    if ((rep_len = recvfrom(sock, &s_response , sizeof(struct s_rep), 0,(struct sockaddr *) &server_addr, &echoServLength)) < 0){
        printError("recvfrom() failed");
    } else{
        printf("recvfrom() succeed, from server.\n");
    }
    if (s_response.type != S_REP) {
        printError("Client was not Authenticated");
    }


    char* send_str = "Hello world!";
    struct pdata pkt_data1;
    memset(&pkt_data1, 0, sizeof(pkt_data1));
    pkt_data1.type = APP_DATA_REQ;
    pkt_data1.packet_length = strlen("One Sentence");
    pkt_data1.pid = 1;
    memcpy(pkt_data1.data, send_str, sizeof(send_str));

    unsigned char pkt_data1_CT[960];
    memset(&pkt_data1_CT, 0, sizeof(pkt_data1_CT));
    int pkt_data1_CT_len = encrypt((unsigned char *) &pkt_data1, sizeof(struct ticket), secret_key, iv, pkt_data1_CT);

    struct pkt msg_to_server;
    memset(&msg_to_server, 0, sizeof(msg_to_server));
    msg_to_server.type = PKT;
    msg_to_server.pkt_length = pkt_data1_CT_len;
    memcpy(msg_to_server.pkt_enc, pkt_data1_CT, pkt_data1_CT_len);

    // 向server发送
    if (sendto(sock, (struct pkt*)&msg_to_server, sizeof(msg_to_server), 0, (struct sockaddr*) &server_addr, sizeof(server_addr)) != sizeof(msg_to_server)){
        printError("sendto() sent a different number of bytes than expected");
        }else {
		printf("sendto() succeed, send message to server.\n");
	}
 

    // 从server接收
    struct pkt msg_from_server;
    memset(&msg_from_server, 0, sizeof(msg_from_server));
    echoServLength = sizeof(server_addr);
    if((rep_len = recvfrom(sock, &msg_from_server, sizeof(struct pkt), 0, (struct sockaddr *) &server_addr, &echoServLength)) < 0){
        printError("recvfrom() failed");
    }else {
        printf("recvfrom() succeed, from server.\n");
    }
        
    printf("Ciphertext: \n");
    printf("%s\n", msg_from_server.pkt_enc);
    
    struct pdata pkt_data2;
    memset(&pkt_data2, 0, sizeof(pkt_data2));
    int decrypted_pkt_data2_len = decrypt(msg_from_server.pkt_enc, msg_from_server.pkt_length, secret_key, iv, (unsigned char *) &pkt_data2);

    printf("%s\n",pkt_data2.data);
    printf("Mission succeed!\n");
    close(sock);
    exit(0);
}


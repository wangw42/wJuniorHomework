
all: client server authserver

client: client.c header.o
	gcc -g -o client client.c header.o -lcrypto

server: server.c header.o
	gcc -g -o server server.c header.o -lcrypto

authserver: authserver.c header.o
	gcc -g -o authserver authserver.c header.o -lcrypto

header.o: header.c
	gcc -g -c header.c

clean:
	rm client server authserver header.o

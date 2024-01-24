#!/bin/bash

function ctrl_c(){
	echo -e "\n\n[!] Saliendo ..."
	exit 1 
}

# Ctrl+C
trap ctrl_c INT


for port in $(seq 1 65535); do
	#Si se envía un texto vacio a un puerto en especifico y se recibe, retorna ejecución 0, sinó un 1 
	(echo '' > /dev/tcp/127.0.0.1/$port) 2>/dev/null && echo "[+] $port - OPEN" || echo "[+] $port - CERRADO"
done


#!/bin/bash

function ctrl_c(){
	echo -e "\n\n[!] Saliendo...\n"
	tput cnorm;exit 1
}

# Ctrl+C
trap ctrl_c INT

#Ocultar el cursor
tput civis

for i in $(seq 1 254); do
	timeout 1 bash -c "ping -c 192.168.1.$i &>/dev/null" && echo "[+] Host 192.168.1.$i - ACTIVE"

#hilos para que ejecute  secuencialmente sin esperar la respuesta del comando anterior
done; wait

#Recuperar el cursos
tput cnorm

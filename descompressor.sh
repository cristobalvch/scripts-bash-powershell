#!/bin/bash


#Funcion que avisa cuando se sale del script
function ctrl_c(){
	echo -e "\n\n[!] Saliendo...\n"
	exit 1
}
# Ctrl+c
trap ctrl_c INT

first_file_name="data.gz"
decompressed_file_name="$(7z l data.gz | tail -n 3 | head -n 1 | awk 'NF{print $NF}')"

#Descomprimir el archivo recursivamente
7x x $first_file_name &>/dev/null

#mientras exista un valor en decompressed_file_name
while [ $decompressed_file_name ];do
	echo -e "\n[+] Nuevo archivo descomprimido: $decompressed_file_name"
        7x x $decompressed_file_name &>/dev/null
	decompressed_file_name="$(7z l $decompressed_file_name 2>/dev/null | tail -n 3 | head -n 1 | awk 'NF{print $NF}')"
done

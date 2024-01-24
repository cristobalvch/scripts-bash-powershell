#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
	echo -e "\n\n${redColour}[!] Saliendo...\n"
        exit 1
}
# Ctrl+c
trap ctrl_c INT

#VARIABLES GLOBALES
main_url="https://htbmachines.github.io/bundle.js"


#FUNCIONES DEL SCRIPT

#Funcion de ayuda
function helpPanel(){
	echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
	echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de maquina${endColour}"
	echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por dirección ip${endColour}"
	echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por nivel de dificultad${endColour}"
	echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por sistema operativo${endColour}"
	echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
	echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar panel de ayuda${endColour}\n"
	
}

#Funcion de busqueda de maquina
function searchMachine()
{
	machineName="$1"
	machineDetails=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')
	
	if [ "$machineDetails" ]; then
		echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la máquina${endColour}${blueColour} $machineName${endColour}:\n"
		cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
	else
		echo -e "\n${redColour}[!]${endColour}${grayColour} No existen  maquína con el nombre${endColour}${blueColour} $machineName${endColour}\n"
	fi
}

#Funcion para actualizar archivos
function updateFiles(){

	if [ ! -f bundle.js ]; then
		tput civis #quitar el cursos
		echo -e "\n${yellowColour}[+]${endColour}${grayColour}Descargando archivos necesarios${endColour}"
		curl -s $main_url > bundle.js
		js-beautify bundle.js | sponge bundle.js
		echo -e "\n${yellowColour}[+]${endColour}${grayColour}Archivos actualizados${endColour}"
		tput cnorm #poner el cursor		
	else
		tput civis
		curl -s $main_url > bundle_temp.js
		js-beautify bundle_temp.js | sponge bundle_temp.js
		md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}') #convertir archivo en md5 para comparar hashes y ver si hay algun cambio entre ellos	
		md5_original_value=$(md5sum bundle.js | awk '{print $1}') #convertir archivo en md5 para comparar hashes y ver si hay algun cambio entre ellos
		tput cnorm

		if [ "$md5_temp_value" == "$md5_original_value" ]; then
			echo -e "\n${yellowColour}[+]${endColour}${grayColour}No hay actualizaciones${endColour}"
			rm bundle_temp.js
		else
			rm bundle.js && mv bundle_temp.js bundle.js
		fi
	fi
}

#Funcion para buscar por IP
function searchIP(){
	ipAddress="$1"
	machineName=$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')
	
	if [ "$machineName" ]; then
		searchMachine $machineName
	else
		echo -e "\n${redColour}[!]${endColour}${grayColour} No existen  maquínas con la ip${endColour}${blueColour} $ipAddress${endColour}\n"
	fi
}


#Funcion para buscar por dificultad
function searchDifficulty(){
	difficulty="$1"

	difficultyResults="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$difficultyResults" ]; then
		cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${redColour}[!]${endColour}${grayColour} La dificultad indicada no existe${endColour}${blueColour} $ipAddress${endColour}\n"
	fi
}

function getOSMachines(){
	osSystem="$1"
	osResults="$(cat bundle.js | grep "so: \"$osSystem\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ','| column)"
	
	if [ "$osResults" ]; then
		cat bundle.js | grep "so: \"$osSystem\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ','| column
	else
		echo -e "\n${redColour}[!]${endColour}${grayColour} El sistema operativo indicado no existe${endColour}${blueColour} $ipAddress${endColour}\n"
	fi
}


function getOSDifficulty(){
	difficulty="$1"
	osSystem="$2"

	osDifficulty=$(cat bundle.js | grep "so: \"$osSystem\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"'| tr -d ',' | column) 

	if [ "$osDifficulty" ]; then
		cat bundle.js | grep "so: \"$osSystem\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"'| tr -d ',' | column
	else		
		echo -e "\n${redColour}[!]${endColour}${grayColour} Se ha indicado una dificultad o sistema operativo incorrecto${endColour}${blueColour} $ipAddress${endColour}\n"
	fi
}


#Indicadores para identificar los parametros
declare -i parameter_counter=0
declare -i chivato_os=0
declare -i chivato_difficulty=0


while getopts "m:ui:d:o:h" arg; do
	case $arg in
		m) machineName=$OPTARG; let parameter_counter+=1;;
		u) let parameter_counter+=2;;
		i) ipAddress=$OPTARG; let parameter_counter+=3;;
		d) difficulty=$OPTARG; chivato_difficulty=1; let parameter_counter+=4;;
		o) osSystem=$OPTARG; chivato_os=1; let parameter_counter+=5;;
		h) ;;
	esac
done 


#eq aplica para valores numericos (condicionales)
if [ $parameter_counter -eq 1 ]; then
	#Pasar argumento a una funcion
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
	searchDifficulty $difficulty
elif [ $parameter_counter -eq 5 ]; then
	getOSMachines $osSystem
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
	getOSDifficulty $difficulty $osSystem #Filtros dobles

	
else

	helpPanel
fi











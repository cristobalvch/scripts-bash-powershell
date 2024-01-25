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
trap ctrl_c INT

#Funcion de ayuda
function helpPanel(){
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Use:${endColour} $0"
	echo -e "\t${purpleColour}s)${endColour}${grayColour} Search Famous Person by name (Firstname_Lastname)${endColour}"
	echo -e "\t${purpleColour}h)${endColour}${grayColour} Display Help Panel${endColour}"
       
}



URL="https://api.pantheon.world"


function searchPerson(){
query=$1

	curl -s "$URL/person?slug=eq.$query" | jq 'map(with_entries(select(.value != null)))'	

}



#Indicadores para identificar los parametros
declare -i parameter_counter=0



while getopts "hs:" arg; do
        case $arg in
                s) personName=$OPTARG; let parameter_counter+=1;;
                h) ;;
        esac
done




if [ $parameter_counter -eq 1 ]; then
	searchPerson $personName
else
	helpPanel
fi



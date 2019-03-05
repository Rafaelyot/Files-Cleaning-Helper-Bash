#! /bin/bash
#variaveis Globais---------------------------------------------------------
declare -A argumentos=( ["-n"]=-1 ["-d"]=-1 ["-l"]=-1 ["-L"]=-1 ["-r"]=-1 ["-a"]=-1 ["-e"]=-1 )
declare -A filesList
data=0;
re='^[0-9]+$'
declare -a diretorios=()
declare -A output
declare -a filesNR
#----------------------------------------------------------------------
function tratarArgumentos() {
userArgumentos=("$@")
i=0
while [[ "$i" -ne "${#userArgumentos[@]}"   ]]; do
    arg1="${userArgumentos["$i"]}"
    case "$arg1" in 
        "-a")
            counter=0
            echo "Opcao -a"
            argumentos["$arg1"]=0;
        ;;
        "-r")
            counter=0
            echo "Opcao -r"
            argumentos["$arg1"]=0;
        ;;
        "-n")
            counter=0
            echo "Opcao -n"
            i=$(( $i +1 ))
            nextElement="${userArgumentos["$i"]}"
            argumentos["$arg1"]="$nextElement"
        ;;
        "-d")
            counter=0
            echo "Opcao -d"
            i=$(( $i +1 ))
            nextElement="${userArgumentos["$i"]}"
            argumentos["$arg1"]="$nextElement"
        ;;
        "-l")
            counter=0
            echo "Opcao -l"
            i=$(( $i + 1 ))
            nextElement="${userArgumentos["$i"]}"
            if   ! [[  "$nextElement" =~ $re ]] || (( "$nextElement" < 1 ));then 
                echo "Erro!Opcao -l invalida deverá aceitar um numero inteiro positivo"
                exit 1;
            fi
            argumentos["$arg1"]="$nextElement"
        ;;
        "-L")
            counter=0
            echo "Opcao -L"
            i=$(( $i +1 ))
            nextElement="${userArgumentos["$i"]}"
            if  ! [[   "$nextElement" =~ $re ]] || (("$nextElement" < 1 ));then
                echo "Erro!Opcao -L invalida deverá aceitar um numero inteiro positivo"
                exit 1;
            fi
            argumentos["$arg1"]="$nextElement" 
        ;;
        "-e")
            echo "Opcao -e"
            counter=0
            i=$(( $i +1 ))
            nextElement="${userArgumentos["$i"]}"
            if [[ ! -f "$nextElement" ]];then
                echo "Erro.Opçao -e invalida"
                exit 1
            fi
            readarray filesNR < "$nextElement" 
            argumentos["$arg1"]="$nextElement" 
            
        ;;
        *)  
            if [[ -d "$arg1" ]];then
                diretorios+=("$arg1")
                counter=$(( $counter + 1 ))
            else
                echo "Erro. Opçoes invalidas"
                exit 1
            fi
        ;;
        esac
    i=$(( $i + 1 ))
done
    if (( "${#diretorios[@]}" == 0 ));then  #checka a existencia de pelo menos uma diretoria
        echo "Erro. Nao foram introduzidas diretorias"
        exit 1
    fi

    if (( $counter != ${#diretorios[@]} )) ; then #checkar se n existem diretorias perdidas no meio das opçoes
        echo "Erro.Diretorias devem ser introduzidas no fim"
        exit 1
    fi

    if (( "${argumentos["-l"]}" != "-1" )) && (( "${argumentos["-L"]}" != "-1")) ;then #checka se o -l e -L estao ativas simultaneamente
        echo "Erro. Opçoes -l e -L nao podem estar ativas simultaneamente"
        exit 1
    fi
    #-------------Ver se o formato do -d é correto
    if [ "${argumentos["-d"]}" != "-1" ];then   
        data="$( date -d "${argumentos["-d"]}" +%s 2>&1 >/dev/null )" 
        if [[ "$?" -eq 1 ]];then
            echo "Formato da data da opçao -d invalida"
            exit
        else 
            data="$( date -d "${argumentos["-d"]}" +%s )" 
        fi
    fi
    #------------------------------
    output=()
    for f in "${diretorios[@]}";do
        getDirectory "$f"
    done
        chooseSort
        if [ "${argumentos["-L"]}" != "-1" ];then
        if (( "${#filesList[@]}" == 0 ));then
            echo "Nao foi possivel imprimir nenhum ficheiro"
        else
        if (( "${#filesList[@]}" < "${argumentos["-L"]}" ));then
            echo "Nao foi possivel imprimir todos os "${argumentos["-L"]}" ficheiros , uma vez que so foram capturados "${#filesList[@]}" ficheiros"
        fi
        for i in "${!filesList[@]}";do
            printf "%-15s %-s\n" "${filesList["$i"]}" "${i}"
        done | sort  -g  | tail -"${argumentos["-L"]}" | sort ${c} ${a} ${b}
        fi
        else
        for i in "${!output[@]}";do
            printf "%-15s %-s\n" "${output["$i"]}" "${i}"
        done | sort  ${c} ${a} ${b}
       fi
}
function chooseSort() {
    if [ "${argumentos["-r"]}" == "-1" ] && [ "${argumentos["-a"]}" == "-1" ] ;then #Tamanho decresecente
            a="-g"
            b="-r"
            c=""
    fi
    if [ "${argumentos["-r"]}" != "-1" ] && [ "${argumentos["-a"]}" == "-1" ];then #Tamanho crescente
            a="-g"
            b=""
            c=""
    fi
    if [ "${argumentos["-r"]}" == "-1" ] && [ "${argumentos["-a"]}" != "-1" ];then #Diretoria crescente

            a=""
            b=""
            c="-k2"
    fi
     if [ "${argumentos["-r"]}" != "-1" ] && [ "${argumentos["-a"]}" != "-1" ];then #Diretoria decrescente
            a=""
            b="-r"
            c="-k2"
    fi
}
function getDirectory() {
valor=0;
local diretoria="$1";
local er=0;
local BOOLEANO=0
declare -a local arrayl=()
for file in "$diretoria"/*
do
    if [ ! -d "${file}" ] ; then
    #se n for diretoria tem que ser file, se n for passa para o proximo
   if [ ! -f "${file}" ];then  #Verificar isto!!
        #   echo "RIP---------->>>>${file}"
        continue
    fi
    erroFileSize="$(stat --printf="%s" "${file}" 2>&1 >/dev/null)"
        if [[ "$?" -ne 0 ]];then
            output["${diretoria##./}"]="NA"
            er=1
            continue;
        fi
        fileSize="$(stat --printf="%s" "${file}")" 
        if [ "${argumentos["-n"]}" == "-1" ] || [[ ${file##*/} =~ ^${argumentos["-n"]}$ ]] ;  then # echo "${file##*/}" | grep -q ".*${argumentos["-n"]}.*" ; then   #  #    ; then
            if [ "${argumentos["-d"]}" == "-1" ]  || (( " $(date -d  "$( stat --printf="%y" "${file}" )" +%s)" <   ${data} ));then
            if [[ "${argumentos["-e"]}" != "-1" ]];then
                for fileEssential in "${filesNR[@]}";do
                case "$file" in 
                    /*)
                        fileabs="${file}" ;;
                    *)
                        fileabs="$(pwd)/${file}" ;;
                esac
                 case "$fileEssential" in 
                    /*)
                        abs="${fileEssential}" ;;
                    *)
                        abs="$(pwd)/${fileEssential}" ;;
                esac
                erro2="$(realpath "$abs" 2>&1 >/dev/null )"
                if [[ $? -ne 0 ]];then
                    echo "Erro! Introduza ficheiros validos no ficheiro "${argumentos["-e"]}" "
                    exit 1
                fi
                fileabs2="$(realpath "${fileabs}")"
                abs2="$(realpath "$abs")"
                    if [[ "${fileabs2}" == "${abs2}" ]];then 
                        echo "Cant count --> "${file}" "
                        BOOLEANO=1
                        break
                    fi
                done
                if  (( $BOOLEANO == 1 ));then
                    BOOLEANO=0;
                    continue;
                fi
            fi
            if [ "${argumentos["-L"]}" != "-1" ] ;then
                filesList["${file##./}"]="${fileSize}"
            else
            if [ "${argumentos["-l"]}" != "-1" ] ;then
                arrayl+=(${fileSize})
            else
                valor="$(( $valor +  $fileSize ))"
            fi
            fi
        fi
        fi
    else
       erro="$( ls "${file}" 2>&1 >/dev/null) "
       #----------------Se der erro em alguma cena
       if [[ "$?" -ne 0 ]];then
           output["${file##./}"]="NA"
           er=1
        #--------------------------
       else
        if [[ ! -z "$(ls "${file}")" ]];then
            local soma="$valor"
            getDirectory "${file}"
            if [[ "$?" -eq "1" ]];then
                er=1
            fi
            valor="$(( $valor + $soma ))"
        else 
            output["${file##./}"]=0
        fi
        fi
    fi
done
if [[ "$er" -eq "1" ]];then
    output["${diretoria##./}"]="NA"
    return 1;
fi
if [ "${argumentos["-l"]}" != "-1" ];then
    IFS=$'\n' sorted=($(sort -g -r <<<"${arrayl[*]}"))
    unset IFS 
    index=0;
    while [ "${index}" -ne "${argumentos["-l"]}" ] ; do
         if [ "${#sorted[@]}" -eq "${index}" ];then
                break;
        fi
        valor=$(( $valor + ${sorted["$index"]} ))
        index=$(( $index + 1 ))
    done
fi
    output["${diretoria##./}"]="${valor}"
} 
time tratarArgumentos "$@"

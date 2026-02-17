#!/bin/bash

# ====================================================
#        GHOSTSCAN V1.22 - STEALTH & SECURITY
# ====================================================

ROJO='\e[31m'
VERDE='\e[32m'
AMARILLO='\e[33m'
CIAN='\e[36m'
RESET='\e[0m'
USUARIO_REAL=${SUDO_USER:-$USER}

mostrar_spinner() {
	local caracteres="/-\|"
	while true; do
		for ((i = 0; i < ${#caracteres}; i++)); do
			# Se usa -en para evitar el salto de linea y se asegura el retorno de carro limpio
			printf "\r${CIAN}[%c] Ejecutando análisis táctico (Modo Silencioso)...${RESET}" "${caracteres:$i:1}"
			sleep 0.1
		done
	done
}

if [ "$EUID" -ne 0 ]; then
	echo -e "${ROJO}Error: Privilegios de root necesarios (sudo).${RESET}"
	exit
fi

INTERFAZ=$(ip route | grep default | awk '{print $5}')
GATEWAY=$(ip route | grep default | awk '{print $3}')
IP_LOCAL=$(ip addr show $INTERFAZ | grep "inet " | awk '{print $2}' | cut -d/ -f1)
RANGO=$(echo $IP_LOCAL | cut -d. -f1-3).0/24
REPORTE_ACUMULADO=""
C_PRINT=0
C_SERV=0
C_NET=0
C_UNK=0

clear
echo -e "${CIAN}      .---.      ${RESET}"
echo -e "${CIAN}     /     \     ${AMARILLO} GHOSTSCAN V1.22${RESET}"
echo -e "${CIAN}    | (O) (O) |    ${AMARILLO} Especialista: Máximo Sigilo & Evasión${RESET}"
echo -e "${CIAN}     \  ---  /     ${RESET}"
echo -e "${CIAN}      '---'      ${RESET}\n"

# --- SELECCIÓN DE PERFIL (ENFOQUE SEGURIDAD) ---
echo -e "${AMARILLO}SELECCIÓN DE ESTRATEGIA DE SIGILO:${RESET}"
echo -e "------------------------------------------------------------------------"
echo -e "1) ${VERDE}RED DOMÉSTICA / PERSONAL${RESET}"
echo -e "   Enfoque: Evitar alertas en dispositivos del hogar y routers básicos."
echo -e "   Técnica: Escaneo ARP pausado (-T2) + Randomización."
echo ""
echo -e "2) ${ROJO}RED EMPRESARIAL / AVANZADA${RESET}"
echo -e "   Enfoque: Evasión de IDS/IPS y Firewalls corporativos."
echo -e "   Técnica: Fragmentación extrema + Señuelos + Timing mínimo (-T1)."
echo -e "------------------------------------------------------------------------"
read -p "Seleccione perfil [1-2]: " PERFIL

# --- LÓGICA DE OFUSCAMIENTO (PARA AMBOS PERFILES) ---
echo -e "\n${AMARILLO}[?] Configuración de Identidad:${RESET}"
if iwconfig $INTERFAZ 2>&1 | grep -q "IEEE 802.11"; then
	echo -e "${ROJO}[!] ADVERTENCIA: Usas WIFI.${RESET} Cambiar la MAC puede desconectarte en entornos virtuales."
else
	echo -e "${VERDE}[i] Usas CABLE.${RESET} El cambio de MAC es seguro y recomendado."
fi

read -p "¿Deseas ofuscar la dirección MAC ahora? (s/n): " opt_mac
if [[ "$opt_mac" =~ ^[sS]$ ]]; then
	echo -e "${CIAN}[*] Modificando identidad de hardware...${RESET}"
	ip link set dev $INTERFAZ down
	macchanger -r $INTERFAZ >/dev/null
	ip link set dev $INTERFAZ up
	dhclient $INTERFAZ >/dev/null 2>&1
	sleep 3
	echo -e "${VERDE}[✔] MAC cambiada y conexión restablecida.${RESET}"
fi

# Configuración de comandos según perfil (Priorizando Sigilo)
if [ "$PERFIL" == "2" ]; then
	PERFIL_DESC="Corporativo (Sigilo Máximo)"
	# T1 (Muy lento), -f (Fragmentación), -D (Señuelos), --data-length (Añade ruido al paquete)
	OPCIONES_RECON="-Pn -sS -T1 -f -D RND:10 --data-length 24 --randomize-hosts"
else
	PERFIL_DESC="Doméstico (Sigilo Estándar)"
	# T2 (Lento), -sn (Usa ARP en red local, lo más natural)
	OPCIONES_RECON="-sn -T2 --randomize-hosts"
fi

# --- FASE 1: DESCUBRIMIENTO ---
echo -e "\n${CIAN}[*] Iniciando rastreo silencioso en $RANGO...${RESET}"
mostrar_spinner &
PID_S=$!

if [ "$PERFIL" == "2" ]; then
	nmap $OPCIONES_RECON -p80,443,445,139 --open $RANGO -oG - | grep "Host:" | awk '{print $2}' >hosts.tmp
else
	nmap $OPCIONES_RECON $RANGO -oG - | grep "Up" | awk '{print $2}' >hosts.tmp
fi

kill $PID_S >/dev/null 2>&1
printf "\r\033[K"

TOTAL=$(wc -l <hosts.tmp)
echo -e "${VERDE}[✔] $TOTAL objetivos localizados sin alertar a la red:${RESET}"
cat hosts.tmp | sed 's/^/   ↳ /'

# --- FASE 2: AUDITORÍA PROFUNDA ---
if [ "$TOTAL" -gt 0 ]; then
	echo -e "\n${AMARILLO}¿Proceder con el análisis de servicios (vulnerabilidades)? (s/n)${RESET}"
	read -n 1 ans
	echo ""
	if [[ "$ans" =~ ^[sS]$ ]]; then
		while read ip; do
			[ "$ip" == "$IP_LOCAL" ] && continue
			echo -e "\n${CIAN}>>> ANALIZANDO CON DISCRECIÓN: $ip${RESET}"
			mostrar_spinner &
			PID_A=$!

			# Auditoría pausada para no saturar el host
			RES=$(sudo nmap -sS -sV -T2 -Pn --top-ports 20 --script=http-title,vuln $ip)

			kill $PID_A >/dev/null 2>&1
			printf "\r\033[K"

			INFO_LIMPIA=$(echo "$RES" | grep -E "PORT|STATE|SERVICE|VERSION|VULNERABLE|http-title|_VULN")

			CATEGORIA="GENÉRICO"
			[[ "$RES" =~ "80" || "$RES" =~ "443" ]] && CATEGORIA="SERVIDOR WEB"
			[[ "$RES" =~ "9100" || "$RES" =~ "printer" ]] && CATEGORIA="IMPRESORA"
			[[ "$RES" =~ "Router" || "$RES" =~ "Gateway" ]] && CATEGORIA="EQUIPO DE RED"

			case $CATEGORIA in
			"SERVIDOR WEB") ((C_SERV++)) ;;
			"IMPRESORA") ((C_PRINT++)) ;;
			"EQUIPO DE RED") ((C_NET++)) ;;
			*) ((C_UNK++)) ;;
			esac

			echo -e "${VERDE}Clasificación: $CATEGORIA${RESET}"
			echo -e "$INFO_LIMPIA"

			REPORTE_ACUMULADO+="\n[+] IDENTIFICADOR: $ip ($CATEGORIA)\n"
			REPORTE_ACUMULADO+="    -------------------------------------------------------\n"
			REPORTE_ACUMULADO+="$(echo "$INFO_LIMPIA" | sed 's/^/    /')\n"
			REPORTE_ACUMULADO+="    -------------------------------------------------------\n"
		done <hosts.tmp
	fi
fi

# --- FASE 3: REPORTE FINAL ---
echo -e "\n${VERDE}[✔] Auditoría finalizada correctamente.${RESET}"
read -p "¿Generar informe técnico de seguridad? (s/n): " save
if [[ "$save" =~ ^[sS]$ ]]; then
	NOMBRE="GHOSTSCAN_SECURE_$(date '+%H%M').txt"
	DIR="/home/$USUARIO_REAL/Descargas"
	[ ! -d "$DIR" ] && DIR="/home/$USUARIO_REAL/Downloads"
	[ ! -d "$DIR" ] && DIR="/home/$USUARIO_REAL"

	{
		echo "###########################################################"
		echo "#            INFORME DE SEGURIDAD GHOSTSCAN V1.22          #"
		echo "###########################################################"
		echo "  PERFIL: $PERFIL_DESC"
		echo "  RED: $RANGO | OPERADOR: $USUARIO_REAL"
		echo "  FECHA: $(date)"
		echo "-----------------------------------------------------------"
		echo "RESUMEN DE DISPOSITIVOS:"
		echo "Total: $TOTAL | Web: $C_SERV | Impresoras: $C_PRINT | Red: $C_NET"
		echo "-----------------------------------------------------------"
		echo -e "\nHALLAZGOS TÉCNICOS:\n$REPORTE_ACUMULADO"
		echo "-----------------------------------------------------------"
		echo "NOTAS SOBRE SIGILO APLICADO:"
		echo "* Timing (T1/T2): Se enviaron paquetes con intervalos largos"
		echo "  para evitar disparar alarmas por exceso de tráfico."
		echo "* Randomize Hosts: Los objetivos no se escanearon en orden,"
		echo "  dificultando la detección de un patrón de ataque."
		echo "* Data-Length: Se añadió basura aleatoria a los paquetes"
		echo "  para que no parezcan escaneos típicos de Nmap."
		echo "###########################################################"
	} | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" >"$DIR/$NOMBRE"

	chown "$USUARIO_REAL:$USUARIO_REAL" "$DIR/$NOMBRE"
	echo -e "${VERDE}✔ Informe de seguridad guardado en: $DIR/$NOMBRE${RESET}"
fi

rm hosts.tmp 2>/dev/null
echo -e "\n${VERDE}>>> OPERACIÓN FANTASMA FINALIZADA <<<${RESET}"

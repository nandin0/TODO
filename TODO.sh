#!/bin/bash

####################################################################
#Autor: nandin0
#Fecha: 27-03-2020 
#Actualizado: 14-08-2020
#Actualizado: 09-09-2021
#Localizacion: MINIORG.COM
#Motivo: Instalación de software para VPN, No-ip y Home Assistant en un sistema RaspberryPI
#Actualización: Creación de menú de script.
#Actualización: Comprobación de errores y mensajes de estado para los usuarios.
#Posteriormente se ejecuta como cualquier bash: ./TODO.sh


DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0
tareaCRON="*/1 * * * * /usr/bin/flock -n /tmp/ipupdate.lck /usr/local/bin/domain-connect-dyndns update --all --config /root/dyndns/settings.txt"

## PRESCRIPTS
# Scripts que se ejecutarán antes de arrancar el menú
function comprobarDialog() {
tieneDialog=$(which dialog)
if [[ -z "$tieneDialog" ]]; then
	apt install dialog -y
	if [[ $? == 0 ]]; then
		echo -e "\e[3;32mSe instaló dialog correctamente.\e[0m"
	else
		echo -e "\e[3;31mNo se ha podido instalar DIALOG\e[0m" 
	fi
else
	echo -e "\e[3;32mDialog ya se encuentra instalado en el equipo, procedo a continuar...\e[0m"
fi
}
function comprobarCurl() {
tieneCurl=$(which curl)
if [[ -z "$tieneCurl" ]]; then
	apt install curl -y
	if [[ $? == 0 ]]; then
		echo -e "\e[3;32mSe instaló curl correctamente.\e[0m"
	else
		echo -e "\e[3;31mNo se ha podido instalar CURL\e[0m" 
	fi
else
	echo -e "\e[3;32mCURL ya se encuentra instalado en el equipo, procedo a continuar...\e[0m"
fi
}
function comprobarDocker() {
tieneDocker=$(which docker)
	if [[ -z "$tieneDocker" ]]; then
		instalacionDocker
		if [[ $? == 0 ]]; then
			echo -e "\e[3;32mSe instaló docker correctamente.\e[0m"
		else
			echo -e "\e[3;31mNo se ha podido instalar DOCKER\e[0m" 
		fi
	else
		echo -e "\e[3;32mDocker ya se encuentra instalado en el equipo, procedo a continuar con la instalación...\e[0m"
	fi
}

comprobarDialog
comprobarCurl
display_result() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result" 15 15
}

while true; do
  exec 3>&1
  selection=$(dialog \
    --backtitle "Instalación del sistema básico" \
    --title "Menu" \
    --clear \
    --cancel-label "Exit" \
    --menu "Por favor, seleccione una opción:" $HEIGHT $WIDTH 4 \
    "1" "Crear usuario del sistema" \
    "2" "Actualizar sistema (Solo Raspberry)" \
    "3" "Actualizar dependencias" \
    "4" "Instalar aplicaciones básicas" \
    "5" "Instalar/reparar Cliente NOIP" \
    "6" "Instalar/reparar Servidor OpenVPN" \
    "7" "Crear usuario OpenVPN" \
    "8" "Instalar DYNDNS-IONOS" \
	"9" "Instalar Home Assistant (DOCKER)" \
	"A" "Actualizar Kernel Raspberry" \
	"D" "Instalar DOCKER" \
	"P" "Instalar Portainer (DOCKER)" \
	"N" "Instalar NtopNG (DOCKER)" \
    2>&1 1>&3)
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL)
      clear
      echo "Script finalizado."
      exit
      ;;
    $DIALOG_ESC)
      clear
      echo "Instalación cancelada por el usuario (ESC)." >&2
      exit 1
      ;;
  esac
  case $selection in
    0 )
      clear
      echo "Programa terminado."
      ;;
	1)
	#Creamos usuario nuevo 
	nuevoUser=$(dialog --title "Usuario" \
	--stdout \
	--inputbox "Inserte el nuevo usuario:" 0 0)
	# echo -e "\e[97;96mInserte el nuevo usuario:\e[0m"
	# read nuevoUser
		if [[ $? == 0 ]]; then
			useradd $nuevoUser
			dialog --title "Éxito" \
			--msgbox "Se ha creado el usuario $nuevoUser" 0 0
			# echo -e "\e[3;32mEl usuario $nuevoUser se ha creado correctamente.\e[0m"
		else 
			dialog --title "ERROR" \
			--msgbox "No se ha creado el usuario $nuevoUser" 0 0
			# echo -e "\e[3;31mNo se ha creado el usuario $nuevoUser\e[0m" 
		fi
	sleep 2;
	;;

 	2)
	#Actualizamos raspberry
		echo -e "\e[97;96mVamos a realizar la actualización y configuración del sistema \e[0m"
	raspi-config
		if [[ $? == 0 ]]; then
			whiptail --title "Éxito" \
			--msgbox "Se ha ejecutado correctamente el script de actualización" 0 0
			# echo -e "\e[3;32mSe ha ejecutado correctamente el script de actualización.\e[0m"
		else 
			whiptail --title "ERROR" \
			--msgbox "No se ha podido ejecutar correctamente el script de actualización" 0 0
			# echo -e "\e[3;31mNo se ha podido ejecutar correctamente el script de actualización.\e[0m" 
		fi
	sleep 2;
	;;

	3)
	#Actualizamos las depedencias.
		echo -e "\e[97;96mActualizamos dependencias del sistema.\e[0m"
	apt-get update
		if [[ $? == 0 ]]; then
			dialog --title "Éxito" \
			--msgbox "Se han actualizado las dependencias correctamente" 0 0
			# echo -e "\e[3;32mSe han actualizado las dependencias correctamente.\e[0m"
		else 
			dialog --title "ERROR" \
			--msgbox "No se han actualizado las dependencias correctamente" 0 0
			# echo -e "\e[3;31mNo se han actualizado las dependencias correctamente\e[0m" 
		fi
	apt upgrade -y
		if [[ $? == 0 ]]; then
			dialog --title "Éxito" \
			--msgbox "Se han actualizado las dependencias correctamente" 0 0
			# echo -e "\e[3;32mSe han actualizado las dependencias correctamente.\e[0m"
		else 
			dialog --title "ERROR" \
			--msgbox "No se han actualizado las dependencias correctamente" 0 0
			# echo -e "\e[3;31mNo se han actualizado las dependencias correctamente\e[0m" 
		fi
	sleep 2;
	;;

	4)
	#Se instalan algunas apps.
		echo "Vamos a instalar algunas aplicaciones"
	apt install kate gedit gparted terminator vlc openssh-server openssh-client curl -y
		if [[ $? == 0 ]]; then
			dialog --title "Éxito" \
			--msgbox "Se han instalado las aplicaciones básicas correctamente." 0 0
			# echo -e "\e[3;32mSe han instalado las aplicaciones básicas correctamente.\e[0m"
		else 
			dialog --title "ERROR" \
			--msgbox "No se han instalado las aplicaciones básicas" 0 0
			# echo -e "\e[3;31mNo se han instalado las aplicaciones básicas\e[0m" 
		fi
	sleep 2;
	;;

	5)
	#Comienzo con la instalación de no-ip
		echo -e "\e[97;96mVoy a instalar No-IP (durante el proceso, se solicitará actuación del usuario)\e[0m"
	cd /usr/local/src/

		echo -e "\e[97;96mDescargamos el cliente NO-IP\e[0m"
	wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
		if [[ $? == 0 ]]; then
			dialog --title "Éxito" \
			--msgbox "Se ha descargado correctamente el instalador." 0 0
			# echo -e "\e[3;32mSe ha descargado correctamente el instalador.\e[0m"
		else 
			dialog --title "ERROR" \
			--msgbox "No se ha descargado correctamente el instalador." 0 0
			# echo -e "\e[3;31mNo se ha descargado el instalador\e[0m" 
		fi
	
	if [[ noip-duc-linux.tar.gz != \-d ]]; then
        echo -e "\e[3;32mEl archivo se encuentra en la carpeta en la que nos encontramos, procedo a descomprimir...\e[0m"
		tar -xzvf noip-duc-linux.tar.gz
		if [[ $? == 0 ]]; then
			dialog --title "Éxito" \
			--msgbox "Se ha descomprimido correctamente el instalador." 0 0
			# echo -e "\e[3;32mSe ha descomprimido correctamente el instalador.\e[0m"
		else 
			dialog --title "ERROR" \
			--msgbox "No se ha descomprimido correctamente el instalador." 0 0
			# echo -e "\e[3;31mNo se ha descomprimido el instalador\e[0m"
		fi
		cd /usr/local/src/noip-2.1.9-1/
		make 
		make install
		if [[ $? == 0 ]]; then
			dialog --title "Éxito" \
			--msgbox "Se ha instalado correctamente NO-IP" 0 0
			# echo -e "\e[3;32mSe ha instalado correctamente NO-IP.\e[0m"
		else 
			dialog --title "ERROR" \
			--msgbox "No se ha instalado correctamente NO-IP" 0 0
			# echo -e "\e[3;31mNo ha instalado NO-IP\e[0m" 
		fi
	else 
		dialog --title "ERROR" \
		--msgbox "No se ha encontrado el archivo del instalador, intente volver a descargarlo" 0 0
		# echo -e "\e[3;31mNo se ha encontrado el archivo del instalador, intente volver a descargarlo.\e[0m" 
		exit
	fi

		echo -e "\e[97;96mTras instalar NO-IP, procedemos a configurarlo.\e[0m"
	cd /usr/local/bin/noip-2.1.9-1
	/usr/local/bin/noip2 -C
		if [[ $? == 0 ]]; then
			dialog --title "Éxito" \
			--msgbox "Se ha configurado correctamente NO-IP" 0 0
			# echo -e "\e[3;32mSe ha configurado correctamente NO-IP.\e[0m"
			/usr/local/bin/noip
			/usr/local/bin/noip2 -S
			if [[ $? == 0 ]]; then
				dialog --title "Éxito" \
				--msgbox "Se ha iniciado correctamente NO-IP" 0 0
				# echo -e "\e[3;32mSe ha iniciado correctamente NO-IP.\e[0m"
			else 
				dialog --title "ERROR" \
				--msgbox "No se ha iniciado correctamente NO-IP" 0 0
				# echo -e "\e[3;31mNo ha iniciado NO-IP\e[0m" 
			fi
		else 
			dialog --title "ERROR" \
			--msgbox "No se ha configurado correctamente NO-IP, proceda a realizar correctamente la configuración" 0 0
			# echo -e "\e[3;31mNo ha configurado correctamente NO-IP, proceda a realizar correctamente la configuración.\e[0m" 
			/usr/local/bin/noip2 -C
		fi
	sleep 2;
	;;

	6)
	#Procedemos a instalar el software de la VPN
		echo -e "\e[97;96mProcedo a instalar la VPN (durante el proceso, se solicitará actuación del usuario)\e[0m"
		echo " "
	curl -L https://install.pivpn.io | bash
		if [[ $? == 0 ]]; then
			dialog --title "Éxito" \
			--msgbox "Se ha instalado correctamente la VPN" 0 0
			# echo -e "\e[3;32mSe ha instalado correctamente la VPN\e[0m"
		else 
			dialog --title "ERROR" \
			--msgbox "NO ha instalado correctamente la VPN" 0 0
			# echo -e "\e[3;31mNo ha instalado correctamente la VPN\e[0m" 
		fi
	sleep 2;
	;;
	
	7)
	#añadimos usuario a la vpn 
		echo -e "\e[97;96mVamos a añadir un usuario a la VPN\e[0m"
		echo " "
	nombreUsuario=$(dialog --title "Usuario" \
	--stdout \
	--inputbox "Indica un nombre para el usuario:" 0 0)
	# echo -e "\e[97;96mIndica un nombre para el usuario:\e[0m"
	# read nombreUsuario
		if [[ $? == 0 ]]; then
			pivpn add -n $nombreUsuario
			dialog --title "Éxito" \
			--msgbox "Se ha creado correctamente el usuario $nombreUsuario" 0 0
			# echo -e "\e[3;32mSe ha creado correctamente el usuario $nombreUsuario\e[0m"
		else 
			dialog --title "ERROR" \
			--msgbox "No ha creado el usuario $nombreUsuario" 0 0
			# echo -e "\e[3;31mNo ha creado el usuario $nombreUsuario\e[0m" 
		fi
	sleep 2;
	;;

	8)
		echo -e "\e[97;96mInstalo dependencias para instalar DYNDNS-IONOS\e[0m"
		echo " "
	apt upgrade sudo
		if [[ $? == 0 ]]; then
			echo -e "\e[3;32mSe ha actualizado correctamente SUDO\e[0m"
		else 
			echo -e "\e[3;31mNo se ha actualizado correctamente SUDO\e[0m" 
		fi
	apt install software-properties-common sudo -y
		if [[ $? == 0 ]]; then
			echo -e "\e[3;32mSe ha instalado correctamente software-properties-common sudo\e[0m"
		else 
			echo -e "\e[3;31mNo se ha instalado correctamente software-properties-common sudo\e[0m" 
		fi
	apt-get install python3 -y
		if [[ $? == 0 ]]; then
			echo -e "\e[3;32mSe ha instalado correctamente Python3\e[0m"
		else 
			echo -e "\e[3;31mNo se ha instalado correctamente Python3\e[0m" 
		fi
	apt install python3-pip -y
		if [[ $? == 0 ]]; then
			echo -e "\e[3;32mSe ha instalado correctamente Python3-pip\e[0m"
		else 
			echo -e "\e[3;31mNo se ha instalado correctamente Python3-pip\e[0m" 
		fi
		echo -e "\e[97;96mProcedo a instalar el ejecutable\e[0m"
		echo " "
	pip3 install domain-connect-dyndns
		if [[ $? == 0 ]]; then
			dialog --title "Éxito" \
			--msgbox "Se ha instalado correctamente domain-connect-dyndns" 0 0
			# echo -e "\e[3;32mSe ha instalado correctamente domain-connect-dyndns\e[0m"
		else 
			dialog --title "ERROR" \
			--msgbox "No se ha instalado correctamente domain-connect-dyndns" 0 0
			# echo -e "\e[3;31mNo se ha instalado correctamente domain-connect-dyndns\e[0m" 
		fi
	
	nombreDominio=$(dialog --title "Domain" \
	--stdout \
	--inputbox "Indica el dominio al que conectar:" 0 0)
	# echo "Indica el dominio al que conectar:"
	# read nombreDominio
	domain-connect-dyndns setup --domain $nombreDominio
		if [[ $? == 0 ]]; then
			dialog --title "Éxito" \
			--msgbox "Se ha configurado correctamente domain-connect-dyndns" 0 0
			# echo -e "\e[3;32mSe ha configurado correctamente domain-connect-dyndns\e[0m"
		else 
			dialog --title "ERROR" \
			--msgbox "No se ha configurado correctamente domain-connect-dyndns" 0 0
			# echo -e "\e[3;31mNo se ha configurado correctamente domain-connect-dyndns\e[0m" 
		fi
		echo -e "\e[97;96mInicio el servicio....\e[0m"
	domain-connect-dyndns update --all
		echo " "
	
		echo -e "\e[97;96mProcedo a crear la tarea en CRON para que se actualice autómaticamente\e[0m"
		echo " "
	cat $tareaCRON >> /var/spool/cron/crontabs/root
		if [[ $? == 0 ]]; then
			dialog --title "Éxito" \
			--msgbox "Se ha añadido la tarea a CRON correctamente" 0 0
		else 
			dialog --title "ERROR" \
			--msgbox "No se ha añadido la tarea a CRON correctamente" 0 0
		fi
	sleep 2;
	;;

	9)
	#Instalamos el contenedor de Home Assistant Supervisor
	echo -e "\e[97;96mProcedemos a realizar la instalación del contenedor de Home Assistant\e[0m"
	sudo apt update && sudo apt upgrade
		if [[ $? == 0 ]]; then
			echo -e "\e[3;32mSe han actualizado las dependencias del sistema\e[0m"
		else 
			echo -e "\e[3;31mFallo al actualizar las dependencias\e[0m" 
		fi
	sudo apt install -y software-properties-common apparmor-utils avahi-daemon dbus jq network-manager
		if [[ $? == 0 ]]; then
			echo -e "\e[3;32mSe ha instalado el software necesario para la instalación de docker Supervisor\e[0m"
		else 
			echo -e "\e[3;31mError en la instalación del software para docker Supervisor. \e[0m" 
		fi	
	curl -sL "https://raw.githubusercontent.com/Kanga-Who/home-assistant/master/supervised-installer.sh" > supervised-installer.sh
		if [[ $? == 0 ]]; then
			echo -e "\e[3;32mSe ha descargado el instalador de Docker Supervisor\e[0m"
		else 
			echo -e "\e[3;31mError en la instalación del software para docker Supervisor. \e[0m" 
		fi
	if [[ supervised-installer.sh != \-d ]]; then
		dialog --title "Éxito" \
		--msgbox "El archivo se ha descargado correctamente" 0 0
		chmod 777 supervised-installer.sh
		echo -e "\e[3;32mSe cambian los permisos del docker supervised\e[0m"
		# ojo, el comando -m raspberry4 depende de tu equipo
		dialog --title "Éxito" \
		--msgbox "Se cambian los permisos del docker supervised y procedemos a instalarlo" 0 0
		./supervised-installer.sh  -m raspberrypi3 -d /docker/hassio/
			if [[ $? == 0 ]]; then
				dialog --title "Éxito" \
				--msgbox "Se ha realizado la instalación del contenedor del supervisor" 0 0
			else 
				dialog --title "ERROR" \
				--msgbox "Error en la instalación del software para docker Supervisor." 0 0
			fi
		clear
	else
		dialog --title "ERROR" \
		--msgbox "El ejecutable no se encuentra en la ubicación." 0 0
	fi
	sleep 2;
	;;
	
	a|A)
	sudo apt update && sudo apt upgrade -y
	sudo rpi-update
		if [[ $? == 0 ]]; then
			dialog --title "Éxito" \
			--msgbox "Se ha realizado la actualización correctamente" 0 0
			# echo -e "\e[3;32mSe ha realizado la actualización correctamente\e[0m"
		else 
			whiptail --title "ERROR" \
			--msgbox "Error en la actualización del equipo" 0 0
			# echo -e "\e[3;31mError en la actualización de la raspberrypi\e[0m" 
		fi
	sleep 2;
	;;

	d|D)
		function instalacionDocker() {
			echo -e "\e[97;96mInstalo dependencias para instalar DOCKER\e[0m"
			echo " "
				sudo apt-get install -y \
				apt-transport-https \
				ca-certificates \
				curl \
				gnupg-agent \
				software-properties-common
			if [[ $? == 0 ]]; then
				dialog --title "Éxito" \
				--msgbox "Se ha realizad Correctamente Correctamente" 0 0
					echo -e "\e[97;96mAñadimos claves para descargar\e[0m"
					curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
					if [[ $? == 0 ]]; then
						dialog --title "Éxito" \
						--msgbox "Se han exportado las claves correctamente" 0 0
							sudo add-apt-repository \
							"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
							$(lsb_release -cs) \
							stable"
							if [[ $? == 0 ]]; then
								dialog --title "Éxito" \
								--msgbox "Se ha añadido la info al repositorio" 0 0
							else 
								whiptail --title "ERROR" \
								--msgbox "Error no se ha podido añadir la info al repositorio" 0 0
							fi
					else 
						whiptail --title "ERROR" \
						--msgbox "Error en la exportación de claves" 0 0
					fi
					echo -e "\e[97;96mactualizamos sistema y procedemos a instalar DOCKER\e[0m"
					sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io 
					if [[ $? == 0 ]]; then
						dialog --title "Éxito" \
						--msgbox "Se ha realizado la instalación de DOCKER Correctamente" 0 0
					else 
						whiptail --title "ERROR" \
						--msgbox "Error durante la instalación de docker, no se ha podido instalar correctamente" 0 0
					fi
			else 
				whiptail --title "ERROR" \
				--msgbox "Error en la instalación de DOCKER" 0 0
			fi
	}
		instalacionDocker
	;;

	p|P)
	comprobarDocker
	docker run -d --name Portainer -p 9000:9000  --restart=always  -e "TZ=Europe/Madrid"  -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer
		if [[ $? == 0 ]]; then
			dialog --title "Éxito" \
			--msgbox "Se ha realizado la instalación del contenedor PORTAINER Correctamente" 0 0
			# echo -e "\e[3;32mSe ha realizado la actualización correctamente\e[0m"
		else 
			whiptail --title "ERROR" \
			--msgbox "Error en la actualización de la instalación del contenedor PORTAINER" 0 0
			# echo -e "\e[3;31mError en la actualización de la raspberrypi\e[0m" 
		fi
	;;

	n|N)
	comprobarDocker
	docker run -d --name NtopNG -p 3000:3000  --restart=always  -e "TZ=Europe/Madrid" -v /var/run/ntopng.license:/etc/ntopng.license:ro --net=host ntop/ntopng:stable -i eth0
		if [[ $? == 0 ]]; then
			dialog --title "Éxito" \
			--msgbox "Se ha realizado la instalación del contenedor NTOPNG Correctamente" 0 0
		else 
			whiptail --title "ERROR" \
			--msgbox "Error en la actualización de la instalación del contenedor NTOPNG" 0 0
		fi
	;;
  esac
done
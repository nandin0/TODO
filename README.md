# TODO
Este archivo incluye lo necesario para funcionar con un sistema RaspberryPI 3B+ para un uso avanzado.
Para ejecutar el archivo tenemos que ejecutar el bash TODO.sh con privilegios de superusuario.

Las opciones que nos ofrece el script son las siguientes:

  "1" "Crear usuario del sistema" 
    Podremos crear un usuario del sistema (adduser)
  "2" "Actualizar sistema (Solo Raspberry)" 
    Utilizamos el script raspi-config
  "3" "Actualizar dependencias" 
    Actualizamos librerías y dependencias del sistema a la última versión.
  "4" "Instalar aplicaciones básicas" 
    Instalamos el siguiente software: kate gedit gparted terminator vlc openssh-server openssh-client curl
  "5" "Instalar/reparar Cliente NOIP" 
    Instalaremos un cliente NOIP (que debemos configurar previamente en la página oficial).
  "6" "Instalar/reparar Servidor OpenVPN" 
    Instalamos el servidor PiVPN que nos permitirá mediante un menú, realizar la configuraición del servidor OpenVPN o Wireshark
  "7" "Crear usuario OpenVPN" 
    Crear un usuario OpenVPN con la configuración que previamente crearemos en el paso 6
  "8" "Instalar DYNDNS-IONOS" 
    Instalar cliente DYNDNS-IONOS para DynDNS 
  "9" "Instalar Home Assistant (DOCKER)" 
    Instalamos home assistant con supervisor mediante DOCKER
  "A" "Actualizar Kernel Raspberry" 
    Actualización del kernel a la última versión
  "D" "Instalar DOCKER" 
    Necesario para poder mover tus contenedores (IMPRESCINDIBLE PARA EL PASO 9)
  "P" "Instalar Portainer (DOCKER)" 
    Monitor gráfico para docker.
  "N" "Instalar NtopNG (DOCKER)" 
    Monitor web para escanear tus redes.
    
 Está creado con paciencia y probablemente se pueda mejorar, pero hasta ahora me ha servido de ayuda muchísimas veces. 
 Que lo disfrutes.

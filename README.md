# es_ES - Sonidos para SVXLINK en Español
Sonidos en Español, para SVXLINK realizados por el amigo Joaquin EA5GVK.<p>
Para configurarlo, en Español nuestro SVXLINK-TETRA o cualquier otra rama, hay que modificar en el archivo <p>
/etc/svxlink.conf el lenguaje a es_ES <p>
Tambien debemos de meter nuestro idioma en la carpeta /usr/share/svxlink/sounds/ <p>
crear o añadir carpeta es_ES con el contenido de este github.<p>

Tambien podemos situarnos en la dirección /usr/share/svxlink/sounds/ en terminal y teclear:<p>
sudo git clone https://github.com/ea5gvk/es_ES <p>

y cambiar en /usr/share/svxlink/events.tcl <p>

sudo nano /usr/share/svxlink/events.tcl

donde aparezca la linea de la configuracion del lenguajes configuraremos español quedando asi<p>
  set lang "es_ES"<p>
   
pulsamos tecla Ctrl + X y guardamos con "y" los cambios <p>
  
con esto ya tendriamos nuestro svxlink con voces Españolas y para que surtan efectos reiniciamos el servicio con<p>

sudo service restart svxlink.service <p>

Listo nuestro Svxlink en Español.

# Actualización 24-11-2025, script que automatiza la instalacion del idioma Español en tu Svxlink, gracias a la colaboracion de Fran EA7KLE

# Install

 apt-get update

 apt-get install curl sudo -y

 bash -c "$(curl -fsSL https://github.com/ea5gvk/es_ES/raw/main/audio_es.sh)"

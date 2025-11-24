#!/usr/bin/env bash
# Configura SvxLink para usar el idioma es_ES automáticamente

set -e

CONF_FILE="/etc/svxlink/svxlink.conf"
SOUNDS_DIR="/usr/share/svxlink/sounds"
EVENTS_FILE="/usr/share/svxlink/events.tcl"
GIT_REPO="https://github.com/ea5gvk/es_ES"
LANG_CODE="es_ES"

# 1. Comprobar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root (por ejemplo: sudo $0)"
  exit 1
fi

echo "==> Configurando SvxLink para usar el idioma ${LANG_CODE}"

# 2. Copias de seguridad
timestamp="$(date +%F_%H%M%S)"

if [ -f "$CONF_FILE" ]; then
  cp "$CONF_FILE" "${CONF_FILE}.bak_${timestamp}"
  echo "   Copia de seguridad creada: ${CONF_FILE}.bak_${timestamp}"
else
  echo "   [ADVERTENCIA] No se ha encontrado $CONF_FILE"
fi

if [ -f "$EVENTS_FILE" ]; then
  cp "$EVENTS_FILE" "${EVENTS_FILE}.bak_${timestamp}"
  echo "   Copia de seguridad creada: ${EVENTS_FILE}.bak_${timestamp}"
else
  echo "   [ADVERTENCIA] No se ha encontrado $EVENTS_FILE"
fi

# 3. Modificar svxlink.conf para usar es_ES
if [ -f "$CONF_FILE" ]; then
  echo "==> Ajustando idioma en $CONF_FILE"

  # Intentamos varios nombres de parámetro típicos
  if grep -qE '^\s*DEFAULT_LANG\s*=' "$CONF_FILE"; then
    sed -ri 's/^\s*DEFAULT_LANG\s*=.*/DEFAULT_LANG=es_ES/' "$CONF_FILE"
  fi

  if grep -qE '^\s*LANGUAGE\s*=' "$CONF_FILE"; then
    sed -ri 's/^\s*LANGUAGE\s*=.*/LANGUAGE=es_ES/' "$CONF_FILE"
  fi

  if grep -qE '^\s*LANG\s*=' "$CONF_FILE"; then
    sed -ri 's/^\s*LANG\s*=.*/LANG=es_ES/' "$CONF_FILE"
  fi

  # Si no existe ninguna de las anteriores, añadimos DEFAULT_LANG
  if ! grep -qE '^\s*(DEFAULT_LANG|LANGUAGE|LANG)\s*=' "$CONF_FILE"; then
    echo "DEFAULT_LANG=es_ES" >> "$CONF_FILE"
  fi
else
  echo "   [ERROR] No se puede modificar $CONF_FILE porque no existe."
fi

# 4. Clonar o actualizar el idioma en /usr/share/svxlink/sounds/
echo "==> Comprobando directorio de sonidos en $SOUNDS_DIR"

mkdir -p "$SOUNDS_DIR"
cd "$SOUNDS_DIR"

if [ -d "${SOUNDS_DIR}/${LANG_CODE}" ]; then
  echo "   El directorio ${LANG_CODE} ya existe; no se vuelve a clonar."
else
  if ! command -v git >/dev/null 2>&1; then
    echo "[ERROR] git no está instalado. Instálalo e inténtalo de nuevo."
    exit 1
  fi
  echo "   Clonando repositorio de sonidos: $GIT_REPO"
  git clone "$GIT_REPO"
fi

# 5. Modificar events.tcl para set lang "es_ES"
if [ -f "$EVENTS_FILE" ]; then
  echo "==> Configurando idioma en $EVENTS_FILE"

  if grep -qE '^set lang ' "$EVENTS_FILE"; then
    sed -ri 's/^set lang .*/set lang "es_ES"/' "$EVENTS_FILE"
  else
    echo 'set lang "es_ES"' >> "$EVENTS_FILE"
  fi
else
  echo "   [ERROR] No se ha encontrado $EVENTS_FILE para modificar set lang."
fi

# 6. Reiniciar servicio con systemctl (corrección respecto a 'service')
echo "==> Reiniciando servicio SvxLink"
if systemctl restart svxlink.service; then
  echo "   SvxLink se ha reiniciado correctamente."
else
  echo "   [ERROR] No se pudo reiniciar svxlink.service. Revisa el estado con:"
  echo "          systemctl status svxlink.service"
  exit 1
fi

echo "==> Proceso completado. SvxLink debería estar ahora en español (${LANG_CODE})."

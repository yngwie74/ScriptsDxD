#!/bin/bash

curdir="`pwd`"

ls -1 *-*.??g | grep -Eo '^[A-Za-z ]+' | sort -u | while IFS='' read -r line || [[ -n "$line" ]]; do
    # creamos un directorio para los archivos
    mkdir -p "${line}"

    # movemos los archivos coincidentes al directorio
    find . -maxdepth 1 -type f -name "${line}-*.??g" -exec mv "{}" "${curdir}/${line}/" \;

    # si no hubo archivos coincidentes, borramos el directorio vacio
    rmdir "${line}" 2>/dev/null
done

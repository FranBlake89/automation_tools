# Función Principal de Bash + Google Apps Script
google() {

    # Verificar si hay un argumentos
    if [[ -z "$1" ]]; then
        echo 'Error: No se ha especificado ninguna opción. Opciones Disponibles:'
        echo 'google ct: Crea una Cotización Automátizada en Google Docs con Descarga en PDF'
        return 1
    fi

    case "$1" in

        ct)

            # Verificar si se han proporcionado todos los argumentos necesarios
        if [[ $# -lt 6 ]]; then
            echo "Error: Faltan argumentos."
            echo "Uso: ./google.sh ct <RUT> <SKU> <CANTIDAD> <SOLICITANTE> <CORREO> <ACCION>"
            return 1
        fi

        # Asignación de variables a partir de los argumentos
        rut="$2"
        sku="$3"
        cantidad="$4"
        nombre_solicitante="$5"
        correo_de_envio="$6"
        accion="$7"

        # Consulta al SII
        data_sii=$(http --body --follow POST $API_RUT \
        RUT=$rut)

        echo $data_sii | jq

        if echo "$data_sii" | jq empty > /dev/null 2>&1; then
            name=$(echo "$data_sii" | jq -r '.["Razon Social"]')
            email=$(echo "$data_sii" | jq -r '.Email')
            telefono=$(echo "$data_sii" | jq -r '.Telefono')
            address=$(echo "$data_sii" | jq -r '.Direccion')
            district=$(echo "$data_sii" | jq -r '.Comuna')
        else
            echo "Error: Received invalid JSON data from SII"
            return 1
        fi


        # Enviar los datos como JSON mediante POST al endpoint Macro de Google Apps Script ( El que estamos creando en la función doPost() del Script de Google )
        # Recuerda que del URL de Script de Google debemos cambiarlo. Antes implementamos el que les preparé yo. Debemos remplazarlo por la implementación que hicimos recién
        response=$(http --body --follow POST $URL_GOOGLE_APPS_POST \
        rut="$rut" sku="$sku" cantidad="$cantidad" nombre_solicitante="$nombre_solicitante" correo_de_envio="$correo_de_envio" accion="$accion" \
        razon_social="$name" email="$email" telefono="$telefono" address="$address" district="$district" )


        # Mostramos la Respuesta que programaremos en Google Apps Script
        echo $response | jq

        ;;

        *)

        # Validación + Ejemplo de Ejecución
        echo 'Opción No Válida'
        echo 'Opciones Disponibles:'
        echo 'Cotización: google ct 76111111-0 SPPE001 x8 "Juan Aravena" info@company.com [--pdf | --email]'
        ;;

    esac
}

google "$@"
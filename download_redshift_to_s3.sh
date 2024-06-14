#!/bin/bash

# Configuración
REDSHIFT_HOST=""
REDSHIFT_PORT=""
REDSHIFT_USER="-"
REDSHIFT_PASSWORD="-"
REDSHIFT_DB=""
BACKUP_DIR="" #Local backup dir
S3_BUCKET=""  #S3 Bucket
IAM_ROLE="arn:aws:iam::codeid:role/rolename"  #Iam role

# Establecer la variable de entorno para la contraseña
export PGPASSWORD="$REDSHIFT_PASSWORD"

# Crear directorio de respaldo local
mkdir -p "$BACKUP_DIR"

# Obtener lista de esquemas
echo "Obteniendo lista de esquemas..."
schemas=$(psql -h $REDSHIFT_HOST -U $REDSHIFT_USER -d $REDSHIFT_DB -p $REDSHIFT_PORT -t -A -c \
"SELECT schema_name FROM information_schema.schemata WHERE catalog_name = '$REDSHIFT_DB' AND schema_name NOT IN ('information_schema', 'pg_catalog');")

# Convertir la lista de esquemas en un array
IFS=$'\n' read -rd '' -a schemas_array <<<"$schemas"

# Verificar si se han obtenido esquemas
if [ -z "$schemas" ]; then
    echo "Error: No se encontraron esquemas o fallo en la conexión. Verifique las credenciales y el endpoint."
    exit 1
fi

# Exportar cada tabla en cada esquema a CSV en S3
for schema in "${schemas_array[@]}"; do
    schema=$(echo "$schema" | xargs) # Eliminar espacios en blanco
    echo "Obteniendo tablas del esquema $schema..."
    tables=$(psql -h $REDSHIFT_HOST -U $REDSHIFT_USER -d $REDSHIFT_DB -p $REDSHIFT_PORT -t -A -c \
    "SELECT table_name FROM information_schema.tables WHERE table_catalog = '$REDSHIFT_DB' AND table_schema = '$schema';")

    # Verificar si se han obtenido tablas
    if [ -z "$tables" ]; then
        echo "Advertencia: No se encontraron tablas en el esquema $schema."
        continue
    fi

    # Convertir la lista de tablas en un array
    IFS=$'\n' read -rd '' -a tables_array <<<"$tables"

    for table in "${tables_array[@]}"; do
        table=$(echo "$table" | xargs) # Eliminar espacios en blanco
        echo "Respaldando tabla $schema.$table"
        psql -h $REDSHIFT_HOST -U $REDSHIFT_USER -d $REDSHIFT_DB -p $REDSHIFT_PORT -c \
        "UNLOAD ('SELECT * FROM $schema.$table') TO '$S3_BUCKET/$schema/$table/' 
        IAM_ROLE '$IAM_ROLE' 
        DELIMITER ',' 
        ALLOWOVERWRITE 
        PARALLEL OFF;"
    done
done

echo "Exportación de datos a S3 completada."
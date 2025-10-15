#!/bin/bash

# Termina el script inmediatamente si un comando falla
set -e

echo "--- Limpiando entorno anterior (si existe)... ---"
# Borra el directorio temporal para asegurar una construcción limpia
rm -rf tempdir

echo "--- Preparando archivos para la construcción de Docker... ---"
mkdir tempdir
mkdir tempdir/templates
mkdir tempdir/static

cp sample_app.py tempdir/.
cp -r templates/* tempdir/templates/.
cp -r static/* tempdir/static/.

echo "--- Creando el Dockerfile... ---"
# Usamos > en la primera línea para crear/sobrescribir el archivo
echo "FROM python" > tempdir/Dockerfile
# Corregimos el comando de pip para evitar el error de 'thread'
echo "RUN pip install --no-cache-dir --progress-bar off flask" >> tempdir/Dockerfile
echo "COPY ./static /home/myapp/static/" >> tempdir/Dockerfile
echo "COPY ./templates /home/myapp/templates/" >> tempdir/Dockerfile
echo "COPY sample_app.py /home/myapp/" >> tempdir/Dockerfile
echo "EXPOSE 5050" >> tempdir/Dockerfile
echo "CMD python /home/myapp/sample_app.py" >> tempdir/Dockerfile

echo "--- Construyendo la imagen de Docker 'sampleapp'... ---"
cd tempdir
docker build -t sampleapp .

# Detiene y elimina un contenedor anterior con el mismo nombre, si existe
if [ "$(docker ps -aq -f name=samplerunning)" ]; then
    echo "--- Deteniendo y eliminando contenedor antiguo... ---"
    docker stop samplerunning
    docker rm samplerunning
fi

echo "--- Ejecutando el nuevo contenedor... ---"
# Corregimos el mapeo de puertos a 8080:5050
docker run -t -d -p 8080:5050 --name samplerunning sampleapp

echo "--- Verificando los contenedores en ejecución... ---"
docker ps -a

echo "--- ¡Listo! La aplicación debería estar corriendo en http://localhost:8080 ---"

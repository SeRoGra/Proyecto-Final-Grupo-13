#!/bin/bash

# Actualizar el sistema y preparar las dependencias
sudo apt-get update -y
sudo apt-get upgrade -y

# Instalar dependencias necesarias
sudo apt-get install -y \
  curl \
  git \
  unzip \
  wget \
  awscli \
  jq \
  helm \
  kubectl \
  openjdk-11-jdk

# Instalar eksctl (si no está instalado)
if ! command -v eksctl &> /dev/null
then
    echo "eksctl no encontrado, instalando..."
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
    echo "eksctl instalado."
else
    echo "eksctl ya está instalado."
fi

# Instalar Helm (si no está instalado)
if ! command -v helm &> /dev/null
then
    echo "Helm no encontrado, instalando..."
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    echo "Helm instalado."
else
    echo "Helm ya está instalado."
fi

# Configurar AWS CLI con las credenciales de IAM que se pasen como variables de entorno
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set region $AWS_REGION

# Crear el clúster de EKS usando eksctl (puedes cambiar esto según sea necesario)
eksctl create cluster --name eks-mundos-e --region $AWS_REGION --nodegroup-name eks-node-group --node-type t3.medium --nodes 3 --nodes-min 1 --nodes-max 4 --managed

# Esperar a que el clúster esté listo
echo "Esperando a que el clúster de EKS esté listo..."
sleep 60

# Configurar kubectl para interactuar con el clúster EKS
aws eks update-kubeconfig --name eks-mundos-e --region $AWS_REGION

# Desplegar un pod de Nginx en el clúster de EKS
kubectl run nginx --image=nginx --restart=Never

# Verificar que el pod nginx esté corriendo
kubectl get pods -l run=nginx

# Instalar Prometheus usando Helm en el namespace prometheus
kubectl create namespace prometheus || echo "Namespace prometheus ya existe"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus --namespace prometheus --set alertmanager.persistentVolume.storageClass="gp2" --set server.persistentVolume.storageClass="gp2"

# Instalar Grafana usando Helm en el namespace grafana
kubectl create namespace grafana || echo "Namespace grafana ya existe"
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana --namespace grafana \
  --set persistence.storageClassName="gp2" \
  --set persistence.enabled=true \
  --set adminPassword='EKS!sAWSome' \
  --values /home/ubuntu/04_monitoreo/grafana.yaml \
  --set service.type=LoadBalancer

# Obtener la URL de Grafana
kubectl get svc -n grafana
# 🔐 GCP Private GKE Infrastructure with Terraform & Demo App

This project provisions a **private and secure infrastructure on Google Cloud Platform (GCP)** using Terraform, including:

- Custom VPC with two subnets: Management and Restricted
- NAT Gateway for controlled internet access
- Private Compute VM in Management subnet
- Private GKE cluster sin Restricted subnet
- Custom node service account with restricted access
- Artifact Registry to store Docker images privately
- Public HTTP Load Balancer (via GKE Ingress)
- Demo Python app connected to Redis, deployed on GKE

---

## ⚙️ Tools & Tech

- Terraform
- GKE (Google Kubernetes Engine)
- Google Artifact Registry
- GCP Load Balancer (Ingress)
- Kubernetes
- Redis
- Python demo app

---

## 🚀 1. Initialize & Apply Terraform

```bash
terraform init
terraform apply
```
## 📦 2. Build & Push Docker Images to Artifact Registry
### ✅ Authenticate Docker to Artifact Registry
```bash
gcloud auth configure-docker asia-southeast1-docker.pkg.dev
```
### 📥 Clone Demo App Source, build its image and Push to Artifact Registry 
note: You should add your Dockerfile
```bash
git clone https://github.com/ahmedzak7/GCP-2025.git
cd GCP-2025/DevOps-Challenge-Demo-Code-master

# Build and push demo app image
docker build -t asia-southeast1-docker.pkg.dev/<your-project-id>/<your-repo>/nayra-image:latest .

docker push asia-southeast1-docker.pkg.dev/<your-project-id>/<your-repo>/nayra-image:latest

```
### 🧊 Pull Redis and Push to Artifact Registry
```bash
# Pull Redis image from Docker Hub
docker pull redis:7-alpine

# Tag it for your private GAR
docker tag redis:7-alpine asia-southeast1-docker.pkg.dev/<your-project-id>/<your-repo>/redis:7-alpine

# Push it to your Artifact Registry
docker push asia-southeast1-docker.pkg.dev/<your-project-id>/<your-repo>/redis:7-alpine
```
## 🖥️ 3. Connect to Private VM & Access GKE
Since the GKE cluster and VM are both private, use IAP tunneling to connect and manage the cluster.
### 🔐 SSH into Private VM
```bash
gcloud compute ssh nayra-vm \
  --zone=asia-southeast1-a \
  --tunnel-through-iap
```
### 🛠️ Install Required Tools (on the VM)
```bash
# Update package index
sudo apt-get update

# Install kubectl
sudo apt-get install -y kubectl

# Install GKE Auth Plugin
sudo apt-get install -y google-cloud-sdk-gke-gcloud-auth-plugin
```
### 🔗 Connect to GKE Cluster
```bash
gcloud container clusters get-credentials nayra-private-gke-cluster \
  --region=asia-southeast1
```
### ✅ Verify Access
```bash
kubectl get nodes
kubectl get pods -A
```
## 📦 4. Deploy Application on GKE
Once you've created your Kubernetes manifests (redis.yaml, app-deployment.yaml, ingress.yaml), apply them using:
```bash
kubectl apply -f redis.yaml
kubectl apply -f app-deployment.yaml
kubectl apply -f ingress.yaml
```
## 🧪 Testing
After deploying the ingress, wait for an external IP:
```bash
kubectl get ingress
```
Access the app via http://<EXTERNAL_IP>

### Note
## You do not need to pull redix image from public registry like DockerHub and push it again to your private Artifact on goole because Google Cloud mirrors some popular public Docker images (like Redis, NGINX, MySQL, etc.) in its own infrastructure under the domain: gcr.io/google-containers/ These are hosted within Google's network, and accessible to GKE clusters in private subnets that have private_ip_google_access = true, even if those clusters have no public IPs or NAT.


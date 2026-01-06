# Spring PetClinic Microservices - Kubernetes Deployment

This repository contains the Kubernetes manifests for deploying the **Spring PetClinic Microservices** architecture on **Minikube**.  
It includes services such as `api-gateway`, `config-server`, `discovery-server`, `admin-server`, and multiple business microservices.

---

## Deploy on Minikube

### 1. Start Minikube
```bash
minikube start --driver=docker --cpus=6 --memory=8192 --disk-size=30g
```

### 2. Apply the Minikube Overlay
Run the provided automated script:
```bash
cd overlays/minikube
./apply-minikube.sh
```

This script will:
- Delete any old `petclinic` namespace  
- Recreate it cleanly  
- Apply all manifests from the `minikube` overlay  

---

## Check Deployment Status

Monitor pods:
```bash
kubectl get pods -n petclinic -w
```

Check services:
```bash
kubectl get svc -n petclinic
```

---

## Access the Application

After all pods are `Running`, start the tunnel:
```bash
minikube tunnel
```

Then add the following entries to your **hosts file** (Windows):
```
127.0.0.1 tienphatng237.it.com
127.0.0.1 admin.tienphatng237.it.com
```

### URLs:
- **Main Application:** http://tienphatng237.it.com  
- **Spring Boot Admin (Monitoring):** http://admin.tienphatng237.it.com  

---

## Notes
- Probes and init containers are optimized for local startup delays.
- Config Server waits for Git repo initialization before marking readiness.
- Spring Boot Admin may show “offline” for a few seconds after startup — this is normal during service registration.

---

## Cleanup
To remove all components:
```bash
kubectl delete namespace petclinic --grace-period=0 --force
```

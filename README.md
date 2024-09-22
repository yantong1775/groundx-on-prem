# EyeLevel Kubernetes IAC Code

## PRE-REQUISITES

1. Copy env.tfvars.example to env.tfvars
2. Change 

## DEPLOYING

```
./deploy.sh <environment> <cloud_provider>
```

### SELF-SIGNED CERTS
```
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt -subj "/CN=self-signed-ca"
openssl req -new -key tls.key -out tls.csr -subj "/CN={PUT YOUR CLUSTER NAME HERE}.{PUT YOUR NAMESPACE HERE}.svc"
openssl x509 -req -in tls.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out tls.crt -days 3650 -sha256
```
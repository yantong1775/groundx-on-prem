# EyeLevel Kubernetes IAC Code

## PRE-REQUISITES

1. Copy env.tfvars.example to env.tfvars
2. Change 

## DEPLOYING

```
./operator.sh <helm-release> -c -t
```

1. `./operator.sh init`
2. `./operator.sh services`
3. `./operator.sh app`

Use groundx libraries / apis.

`kubectl -n eyelevel get routes`

To get API URL.

```
from groundx import Groundx
from groundx.configuration import Configuration

groundx = Groundx(
    configuration=Configuration(
        host="{RESULT FROM GET ROUTES}/api",
        api_key="5c49be10-d228-4dd8-bbb0-d59300698ef6",
    )
)
```

### SELF-SIGNED CERTS
```
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt -subj "/CN=self-signed-ca"
openssl req -new -key tls.key -out tls.csr -subj "/CN={PUT YOUR CLUSTER NAME HERE}.{PUT YOUR NAMESPACE HERE}.svc"
openssl x509 -req -in tls.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out tls.crt -days 3650 -sha256
```
# Azure Deployment Guide – Domain Server with JuiceFS

This document explains how to deploy the required Azure resources and configure a Domain Server to use **JuiceFS backed by Azure Blob Storage**.

## 1. Create Azure Resources

### 1.1 Storage Account (Azure Blob Storage)

1. In the Azure Portal, search for **Storage Account**.
2. Create a new account:

    * **Kind**: `StorageV2`
    * **Preferred type**: Azure Blob Storage
3. Once created, open the account and go to **Security + networking → Access keys**.

Collect the following values:

* **`accessKey`** → *Storage account name*
* **`secretKey`** → *Access key*
* **`bucket`** → `https://<storage-account>.core.windows.net`

    * For China: `https://<storage-account>.core.chinacloudapi.cn`
* **`AZURE_STORAGE_CONNECTION_STRING`** → *Connection string*


### 1.2 Azure Cache for Redis

1. In the Azure Portal, search for **Azure Cache for Redis**.
2. Create a new instance:

    * **SKU**: `Standard` (or higher)
    * **Size**: `C4` (or larger)

      > JuiceFS requires \~300 bytes per file.
      > Example: 100M files ≈ 30GB.
3. Once provisioned:

    * Under **Overview**, copy the **Host name** (`<redisName>.redis.cache.windows.net`)
    * Under **Settings → Authentication → Access keys**, copy the **Primary key**

Your `metaurl` should be formatted like:

```
rediss://:<Primary key>@<redisName>.redis.cache.windows.net:6380/0
```

* `rediss` → TLS
* Empty username after `://`
* `/0` → database index

## 2. Configure JuiceFS S3 Gateway

Example Helm values for the JuiceFS S3 Gateway:

```yaml
juicefs-s3-gateway:
  enabled: true
  replicaCount: 3
  image:
    # Use ce-vX.X.X tags for JuiceFS CE
    # Latest images: https://hub.docker.com/r/juicedata/mount
    tag: "ce-v1.2.4"

  envs:
    - name: AZURE_STORAGE_CONNECTION_STRING
      value: "<Connection string>"

  secret:
    enabled: true
    name: "<your-bucket-name>" # We recommend same as storage account
    metaurl: "rediss://:<Primary key>@<Redis name>.redis.cache.windows.net:6380/0"
    storage: "wasb"
    accessKey: "<Storage account name>"
    secretKey: "<Storage key>"
    bucket: "https://<storage-account>.core.windows.net"
```

## 3. JuiceFS Gateway Service DNS

The service is exposed within Kubernetes as:

* `http://juicefs-s3-gateway.<namespace>.svc.cluster.local:9000`

For the `default` namespace:

* `http://juicefs-s3-gateway.default.svc.cluster.local:9000`

## 4. Domain Server Configuration

Set the following environment variables for your Domain Server:

* `DS_STORAGE_TYPE=s3`
* `DS_STORAGE_S3_BASE_ENDPOINT=http://juicefs-s3-gateway.<namespace>.svc.cluster.local:9000`
* `DS_STORAGE_S3_BUCKET=<your-bucket-name>` (e.g. `domain-data`)
* `DS_STORAGE_S3_REGION=us-east-1` *(recommended default)*
* `DS_STORAGE_S3_ACCESS_KEY=<Storage account name>`
* `DS_STORAGE_S3_SECRET_KEY=<Storage key>`

## 5. Production Example Deployment

Below is an example configuration for deploying the Domain Server with JuiceFS S3 Gateway:

```yaml
applicationName: domain-server-s3
replicaCount: 3 # horizontal scaling supported
# other configuration ...

secrets:
   # other secrets ...
  juicefs-secret: # inject DS storage credentials from juicefs-secret
    as: environment
    items:
      access-key:
        envVarName: DS_STORAGE_S3_ACCESS_KEY
      secret-key:
        envVarName: DS_STORAGE_S3_SECRET_KEY

juicefs-s3-gateway:
  enabled: true
  replicaCount: 3 # horizontal scaling recommended
  secret:
    enabled: false # create manually in production (helm chart hardcodes secret name to `juicefs-secret`)

envVars:
   # other env vars ...
  DS_STORAGE_TYPE: "s3"
  DS_STORAGE_S3_BUCKET: "<your-bucket-name>"
  DS_STORAGE_S3_REGION: "us-east-1"
  DS_STORAGE_S3_BASE_ENDPOINT: "http://juicefs-s3-gateway:9000" # service DNS short name within same namespace
```

### Create the JuiceFS Secret

Run this one-liner to create the required Kubernetes secret (replace placeholders with your actual values):

```shell
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: juicefs-secret
  namespace: default
type: Opaque
stringData:
  access-key: <Storage account name>
  secret-key: <Storage access key>
  bucket: https://<storage-account>.core.windows.net
  metaurl: rediss://:<Primary key>@<Redis name>.redis.cache.windows.net:6380/0
  name: <your-bucket-name>
  storage: wasb
  AZURE_STORAGE_CONNECTION_STRING: <Connection string>
EOF
```

**note:** You must respect key names as shown above case sensitively, as the JuiceFS S3 Gateway Helm chart expects these exact keys.

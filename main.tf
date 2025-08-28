# MySQL
resource "helm_release" "mysql" {
  name       = "mysql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mysql"
  namespace  = "default"
  version    = "10.0.0"

  values = [
    <<EOF
auth:
  rootPassword: "rootpassword"
  database: "myapp"
  username: "myuser"
  password: "mypassword"
resources:
  requests:
    cpu: "100m"
    memory: "512Mi"
EOF
  ]
}

# # Redis
# resource "helm_release" "redis" {
#   name       = "redis"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "redis"
#   namespace  = "default"
#   version    = "20.0.0"

#   values = [
#     <<EOF
# auth:
#   password: "redispassword"
# architecture: "standalone"
# resources:
#   requests:
#     cpu: "100m"
#     memory: "512Mi"
# EOF
#   ]
# }

# # Elasticsearch
# resource "helm_release" "elasticsearch" {
#   name       = "elasticsearch"
#   repository = "https://helm.elastic.co"
#   chart      = "elasticsearch"
#   namespace  = "default"

#   values = [
#     <<EOF
# antiAffinity: "soft"
# esJavaOpts: "-Xmx128m -Xms128m"
# resources:
#   requests:
#     cpu: "100m"
#     memory: "512M"
#   limits:
#     cpu: "1000m"
#     memory: "512M"
# volumeClaimTemplate:
#   accessModes: [ "ReadWriteOnce" ]
#   storageClassName: "local-path"
#   resources:
#     requests:
#       storage: 100M
# replicas: 1
# minimumMasterNodes: 1
# EOF
#   ]
# }

# LocalStack (S3,SNS,SES,SQS emulation)
resource "helm_release" "localstack" {
  name       = "localstack"
  repository = "https://localstack.github.io/helm-charts"
  chart      = "localstack"
  namespace  = "default"

  values = [
    <<EOF
startServices: "s3,sqs,sns,ses,elasticache,opensearch,ssm"
service:
  type: "LoadBalancer"
resources:
  requests:
    cpu: "100m"
    memory: "512M"
ingress:
  enabled: yes
  ingressClassName: traefik
  hosts:
    - host: localstack.testing
      paths:
        - path: /
          pathType: ImplementationSpecific
EOF
  ]
}

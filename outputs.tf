output "mysql_connection" {
  value = {
    host          = "mysql.default.svc.cluster.local"
    port          = 3306
    database      = "myapp"
    username      = "myuser"
    password      = "mypassword"
    root_password = "rootpassword"
  }
}

output "redis_connection" {
  value = {
    host     = "redis-master.default.svc.cluster.local"
    port     = 6379
    password = "redispassword"
  }
}

output "elasticsearch_connection" {
  value = {
    host = "elasticsearch-master.default.svc.cluster.local"
    port = 9200
    url  = "http://elasticsearch-master.default.svc.cluster.local:9200"
  }
}

output "localstack_connection" {
  value = {
    host    = "localstack.default.svc.cluster.local"
    port    = 4566
    sqs_url = "http://localstack.default.svc.cluster.local:4566"
  }
}

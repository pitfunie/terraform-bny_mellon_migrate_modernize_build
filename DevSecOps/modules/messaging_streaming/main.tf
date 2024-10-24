# Messaging and Streaming Module (modules/messaging_streaming/main.tf):

resource "aws_mq_broker" "mqtt" {
  broker_name     = "mqtt-broker"
  engine_type     = "ActiveMQ"
  engine_version  = "5.15.6"
  deployment_mode = "SINGLE_INSTANCE"
  host_instance_type = "mq.t2.micro"
  user {
    username = "admin"
    password = "password"
  }
  logs {
    general = true
  }
}

resource "aws_s3_bucket" "data_lake" {
  bucket = "your-data-lake"
  tags = merge(var.tags, { Name = "DataLake" })
}

resource "aws_sqs_queue" "example_queue" {
  name = "example-queue"
  tags = var.tags
}

resource "aws_sns_topic" "example_topic" {
  name = "example-topic"
  tags = var.tags
}

resource "aws_msk_cluster" "example_cluster" {
  cluster_name       = "example-cluster"
  kafka_version      = "2.8.0"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type = "kafka.m5.large"
    client_subnets = [aws_subnet.web.id]
    security_groups = [aws_security_group.example_sg.id]
  }

  tags = var.tags
}

resource "aws_db_instance" "default" {
      allocated_storage = 10
      db_name = "mydb"
      identifier = "rds-test"
      engine = "mysql"
      engine_version = "8.0"
      instance_class = "db.t3.micro"
      username = "admin"
      password = "Cloud123"
      db_subnet_group_name = aws_db_subnet_group.sub-grp.id
      parameter_group_name = "default.mysql8.0"

      #Enable backup and retention
      backup_retention_period = 7
      backup_window = "02:00-03:00"

      #Enable monitoring (cloudwatch  Endhanced Monitoring)
      monitoring_interval = 60
      monitoring_role_arn = aws_iam_role.rds_monitoring.arn

      #Maintatenance window
      maintenance_window = "sun:04:00-sun:05:00"
      
      #Enable deletion protection
      deletion_protection = true

      #Skip final snapshot
      skip_final_snapshot =true 
}

## IAM role for RDS Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring" {
      name = "rds-monitoring-role"
      assume_role_policy = jsonencode({
            Version = "2012-10-17"
            Statement = [{
                  Action = "sts:AssumeRole"
                  Effect = "Allow"
                  Principal = {
                        Service = "monitoring.rds.amazonaws.com"
                  }
            }]
      })
  
}

# IAM policy attachment for RDS Monitoring
resource "aws_iam_role_policy_attachment" "rds_monitoring_attach" {
      role = aws_iam_role.rds_monitoring.name
      policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

############ with data source ##############
data "aws_subnet" "subnet_1" {
      filter {
        name = "tag:Name"
        values = ["subnet-1"]
      }
}

data "aws_subnet" "subnet_2" {
      filter {
        name = "tag:Name"
        values= ["subnet-2"]
      }
  
}

resource "aws_db_subnet_group" "sub-grp" {
      name = "mycustubnetgrp"
      subnet_ids = [data.aws_subnet.subnet_1.id, data.aws_subnet.subnet_2.id]
  
}

resource "aws_db_instance" "read_replica" {
      identifier = "rds-test-replica"
      replicate_source_db = aws_db_instance.default.arn
      instance_class = "db.t3.micro"

      db_subnet_group_name = aws_db_subnet_group.sub-grp.name
      parameter_group_name    = "default.mysql8.0"

      monitoring_interval = 60
      monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  
}
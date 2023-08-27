resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private[0].id

  key_name = local.eks_ssh_key

  vpc_security_group_ids = [aws_security_group.three-tier-private.id]
  tags = {
    Name = "${var.name}-private-instance"
  }
}

resource "aws_security_group" "three-tier-private" {
  name        = "three-tier-private"
  description = "Allow SSH only"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.allow-http.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id

  security_groups = [aws_security_group.allow-http.id]

  tags = {
    Name = "${var.name}-alb"
  }
}

resource "aws_security_group" "allow-http" {
  name        = "allow-http"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-http"
  }
}

resource "aws_lb_target_group" "this" {
  name     = "${var.name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  tags = {
    Name = "${var.name}-tg"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.this.id
}





//subnet group
resource "aws_db_subnet_group" "subnet-group" {
  name        = "sg"
  description = "DB Subnet Group"
  subnet_ids  = aws_subnet.private.*.id
}




//Security Group
resource "aws_security_group" "rds-sg" {
  description = "Created by RDS management console"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        var.cidr,
      ]
      description      = ""
      from_port        = 3306
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [aws_security_group.three-tier-private.id]
      self             = false
      to_port          = 3306
    },
  ]
  name   = "rds-${var.env}"
  vpc_id = aws_vpc.this.id
}




//database
resource "aws_db_instance" "db_instance" {
  allocated_storage          = 20
  auto_minor_version_upgrade = true
  backup_retention_period    = 7
  backup_window              = "03:48-04:18"
  copy_tags_to_snapshot      = true
  db_name                    = "dbmaster"
  db_subnet_group_name       = aws_db_subnet_group.subnet-group.name
  delete_automated_backups   = true
  deletion_protection        = false
  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
    "general",
    "slowquery",
  ]
  engine                              = "mysql"
  engine_version                      = "8.0.28"
  iam_database_authentication_enabled = false
  identifier                          = "assesment-${var.env}"
  instance_class                      = var.instance_class
  maintenance_window                  = "sun:22:16-sun:22:46"
  max_allocated_storage               = 100
  multi_az                            = var.multi_az
  option_group_name                   = "default:mysql-8-0"
  parameter_group_name                = "default.mysql8.0"
  port                                = 3306
  publicly_accessible                 = false
  skip_final_snapshot                 = true
  storage_encrypted                   = true
  storage_type                        = "gp2"
  username                            = var.username
  password                            = var.password
  vpc_security_group_ids              = [aws_security_group.rds-sg.id]
  apply_immediately                   = true
}



//read replica
resource "aws_db_instance" "replica" {
  allocated_storage          = 20
  auto_minor_version_upgrade = true
  backup_window              = "03:48-04:18"
  copy_tags_to_snapshot      = true
  delete_automated_backups   = true
  deletion_protection        = false
  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
    "general",
    "slowquery",
  ]
  engine                              = "mysql"
  engine_version                      = "8.0.28"
  iam_database_authentication_enabled = false
  identifier                          = "read-replica-assesment-${var.env}"
  instance_class                      = var.instance_class
  maintenance_window                  = "sun:22:16-sun:22:46"
  max_allocated_storage               = 100
  multi_az                            = false
  parameter_group_name                = "default.mysql8.0"
  port                                = 3306
  publicly_accessible                 = false
  replicate_source_db                 = "assesment-${var.env}"
  skip_final_snapshot                 = true
  storage_encrypted                   = true
  storage_type                        = "gp2"
  password                            = var.password
  vpc_security_group_ids              = [aws_security_group.rds-sg.id]
  apply_immediately                   = true
}

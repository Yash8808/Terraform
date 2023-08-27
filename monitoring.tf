
//RDS Dashboards
resource "aws_cloudwatch_dashboard" "rds" {
  dashboard_name = "RDS"

  dashboard_body = jsonencode(
    {
      "widgets" : [
        {
          "height" : 6,
          "width" : 6,
          "y" : 0,
          "x" : 0,
          "type" : "metric",
          "properties" : {
            "metrics" : [
              ["AWS/RDS", "CPUUtilization"]
            ],
            "view" : "timeSeries",
            "stacked" : false,
            "region" : "eu-west-2",
            "stat" : "Maximum",
            "period" : 300,
            "title" : "CPUUtilization"
          }
        },
        {
          "height" : 6,
          "width" : 6,
          "y" : 0,
          "x" : 6,
          "type" : "metric",
          "properties" : {
            "metrics" : [
              ["AWS/RDS", "CPUUtilization"]
            ],
            "view" : "gauge",
            "region" : "eu-west-2",
            "yAxis" : {
              "left" : {
                "min" : 0,
                "max" : 100
              }
            },
            "stat" : "Maximum",
            "period" : 60,
            "title" : "Maximum CPUUtilization"
          }
        },
        {
          "height" : 6,
          "width" : 6,
          "y" : 0,
          "x" : 12,
          "type" : "metric",
          "properties" : {
            "metrics" : [
              ["AWS/RDS", "DatabaseConnections"]
            ],
            "view" : "timeSeries",
            "stacked" : false,
            "region" : "eu-west-2",
            "period" : 300,
            "stat" : "Maximum"
          }
        },
        {
          "height" : 6,
          "width" : 6,
          "y" : 0,
          "x" : 18,
          "type" : "metric",
          "properties" : {
            "metrics" : [
              ["AWS/RDS", "DatabaseConnections"]
            ],
            "view" : "gauge",
            "region" : "eu-west-2",
            "yAxis" : {
              "left" : {
                "min" : 0,
                "max" : 100
              }
            },
            "stat" : "Maximum",
            "period" : 60,
            "title" : "Maximum DatabaseConnections"
          }
        },
        {
          "height" : 6,
          "width" : 6,
          "y" : 6,
          "x" : 0,
          "type" : "metric",
          "properties" : {
            "metrics" : [
              ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", aws_db_instance.db_instance.identifier]
            ],
            "view" : "gauge",
            "stacked" : true,
            "region" : "eu-west-2",
            "stat" : "Maximum",
            "period" : 60,
            "title" : "FreeStorageSpace",
            "yAxis" : {
              "left" : {
                "min" : 0,
                "max" : 21001094656
              }
            },
            "singleValueFullPrecision" : false,
            "liveData" : false,
            "setPeriodToTimeRange" : false,
            "sparkline" : true,
            "trend" : true
          }
        }
      ]
    }
  )
}


//Application Dashboard
resource "aws_cloudwatch_dashboard" "application" {
  dashboard_name = "Application"

  dashboard_body = jsonencode(
    {
      "widgets" : [
        {
          "type" : "metric",
          "x" : 0,
          "y" : 0,
          "width" : 6,
          "height" : 6,
          "properties" : {
            "view" : "timeSeries",
            "stacked" : false,
            "region" : "eu-west-2",
            "stat" : "Average",
            "period" : 300,
            "metrics" : [
              ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.this.id]
            ],
            "title" : "CPUUtilization"
          }
        }
      ]
    }
  )
}

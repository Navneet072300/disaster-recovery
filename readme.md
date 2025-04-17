Multi-Region Disaster Recovery Setup with AWS
This project provides a Terraform-based infrastructure for a multi-region disaster recovery setup on AWS. It includes failover mechanisms using AWS Route 53 for DNS failover, RDS with a primary instance and cross-region read replica, and S3 with cross-region replication. The primary region is us-east-1, and the secondary region is us-west-2.
Overview
The setup ensures high availability and data redundancy across two AWS regions:

S3 Replication: Objects in the primary bucket (us-east-1) are replicated to the secondary bucket (us-west-2).
RDS Failover: A MySQL primary database in us-east-1 has a read replica in us-west-2. Route 53 uses a failover routing policy to switch to the secondary endpoint if the primary fails.
Route 53 Health Checks: Monitors the primary RDS instance and triggers failover to the secondary region if the primary becomes unavailable.

Architecture

Primary Region (us-east-1):
S3 bucket with versioning enabled.
RDS MySQL primary instance (db.t3.micro) with automated backups.
Route 53 hosted zone with a primary CNAME record.

Secondary Region (us-west-2):
S3 bucket with versioning enabled for replication.
RDS MySQL read replica.
Route 53 secondary CNAME record for failover.

Route 53:
Failover routing policy with a health check on the primary RDS endpoint.

IAM: Role and policy for S3 replication.

Prerequisites

AWS Account: With permissions to create S3 buckets, RDS instances, Route 53 hosted zones, and IAM roles.
Terraform: Version 1.5 or later installed.
AWS CLI: Configured with credentials (aws configure).
Registered Domain: A domain registered in Route 53 (e.g., example.com).
Secure Password: A strong password for the RDS instance.

Directory Structure
├── main.tf # Core infrastructure resources (S3, RDS, Route 53)
├── provider.tf # AWS provider configuration for primary and secondary regions
├── variables.tf # Input variables (regions, domain, DB password)
└── README.md # This file

Setup Instructions

Clone or Create Repository:

Create a directory and save the Terraform files (main.tf, provider.tf, variables.tf) provided in the configuration.

Update Variables:

Open variables.tf and update:
domain_name: Replace example.com with your Route 53 registered domain.
db_password: Replace securepassword123 with a secure password for the RDS instance.
Optionally, adjust primary_region or secondary_region if using different regions.

Initialize Terraform:
terraform init

This downloads the required AWS provider and modules.

Review the Plan:
terraform plan

Verify the resources to be created (S3 buckets, RDS instances, Route 53 records, etc.).

Deploy the Infrastructure:
terraform apply

Type yes to confirm. Deployment typically takes 5-10 minutes due to RDS instance creation.

Verify Deployment:

S3 Replication:
Upload a file to the primary bucket (primary-bucket-<suffix>) in us-east-1.
Check the secondary bucket (secondary-bucket-<suffix>) in us-west-2 for the replicated file.

RDS:
In AWS Console, confirm the primary (primary-db) and read replica (secondary-db) are active.
Check replication status under "Replication" in the RDS console.

Route 53:
Resolve app.<your-domain> (e.g., app.example.com) to confirm it points to the primary RDS endpoint.
Simulate a failure by stopping the primary RDS instance and verify that app.<your-domain> resolves to the secondary RDS endpoint.

Terraform Configuration Details
Files

provider.tf:
Configures AWS providers for us-east-1 (primary) and us-west-2 (secondary) with aliases.

variables.tf:
Defines input variables for regions, domain name, and RDS password.

main.tf:
S3: Creates two buckets with versioning and replication from primary to secondary.
RDS: Deploys a MySQL primary instance with automated backups and a cross-region read replica.
Route 53: Sets up a hosted zone, failover routing policy, and health check for the primary RDS endpoint.
IAM: Configures a role and policy for S3 replication.

Key Resources

S3:
Buckets: primary-bucket-<random-suffix> and secondary-bucket-<random-suffix>.
Versioning enabled on both buckets.
Replication rule from primary to secondary with IAM role.

RDS:
Primary: MySQL 8.0, db.t3.micro, 20GB storage, automated backups (1-day retention).
Read Replica: Replicates from primary using ARN, same instance class.

Route 53:
Hosted Zone: For the specified domain.
CNAME Records: app.<domain> with primary and secondary failover policies.
Health Check: HTTP check on primary RDS hostname (port 3306).

IAM:
Role: s3-replication-role for S3 replication.
Policy: Grants permissions for GetObject, ListBucket, and replication actions.

Usage

Accessing the Application:
Use app.<your-domain> to connect to the RDS instance. It resolves to the primary endpoint unless failover occurs.

Failover Testing:
Stop the primary RDS instance in us-east-1 via AWS Console.
Route 53 health checks detect the failure (within ~90 seconds) and switch DNS to the secondary endpoint.

Data Storage:
Store objects in the primary S3 bucket; they automatically replicate to the secondary bucket.

Troubleshooting

S3 Replication Fails:
Verify versioning is enabled on both buckets (check aws_s3_bucket_versioning resources).
Ensure the IAM role has correct permissions (aws_iam_role_policy.replication).

RDS Read Replica Not Created:
Confirm automated backups are enabled (backup_retention_period = 1 in aws_db_instance.primary).
Check that the primary instance is in Available state before replica creation.

Route 53 Failover Not Working:
Verify the health check (aws_route53_health_check.primary) is correctly configured.
Ensure the RDS endpoint hostname is used without port (split(":", ...)[0]).
If HTTP health checks fail, try TCP with proper security group rules.

General Errors:
Run terraform plan to check for configuration issues.
Review AWS Console for resource statuses and error logs.

Production Considerations

Security:
Replace publicly_accessible = true with VPC security groups to restrict RDS access.
Use AWS Secrets Manager for the RDS password instead of variables.tf.
Enable encryption for S3 buckets and RDS instances.

Monitoring:
Set up CloudWatch alarms for RDS health, S3 replication, and Route 53 health checks.
Enable RDS Enhanced Monitoring and Performance Insights.

Backups:
Increase backup_retention_period (up to 35 days) for RDS.
Configure S3 lifecycle policies for versioning and archival.

Health Checks:
HTTP health checks on port 3306 may not work with RDS MySQL. Use TCP or deploy a custom health check endpoint (e.g., an EC2 instance or Lambda function).
Allow Route 53 health check IPs in RDS security groups.

Scalability:
Upgrade RDS instance types (e.g., db.m5.large) for production workloads.
Add multi-AZ for the primary RDS instance for additional resilience.

Cost Optimization:
Use Reserved Instances for RDS to reduce costs.
Monitor S3 storage and replication costs.

Cleanup
To destroy the infrastructure and avoid charges:
terraform destroy

Confirm with yes. Ensure all resources (S3 buckets, RDS instances, Route 53 records) are deleted via AWS Console.
License
This project is provided as-is for educational purposes. Ensure compliance with AWS terms and conditions.
Contact
For issues or questions, refer to the AWS documentation or contact your AWS support team. For Terraform-related queries, consult the Terraform AWS Provider documentation.

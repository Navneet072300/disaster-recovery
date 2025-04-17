# Multi-Region Disaster Recovery Setup with AWS

This project provides a Terraform-based infrastructure for a multi-region disaster recovery setup on AWS. It includes failover mechanisms using AWS Route 53 for DNS failover, RDS with a primary instance and cross-region read replica, and S3 with cross-region replication. The primary region is `us-east-1`, and the secondary region is `us-west-2`.

## Overview

The setup ensures high availability and data redundancy across two AWS regions:

- **S3 Replication**: Objects in the primary bucket (`us-east-1`) are replicated to the secondary bucket (`us-west-2`).
- **RDS Failover**: A MySQL primary database in `us-east-1` has a read replica in `us-west-2`. Route 53 uses a failover routing policy to switch to the secondary endpoint if the primary fails.
- **Route 53 Health Checks**: Monitors the primary RDS instance and triggers failover to the secondary region if the primary becomes unavailable.

## Architecture

### Primary Region (us-east-1):

- S3 bucket with versioning enabled.
- RDS MySQL primary instance (`db.t3.micro`) with automated backups.
- Route 53 hosted zone with a primary CNAME record.

### Secondary Region (us-west-2):

- S3 bucket with versioning enabled for replication.
- RDS MySQL read replica.
- Route 53 secondary CNAME record for failover.

### Route 53:

- Failover routing policy with a health check on the primary RDS endpoint.

### IAM:

- Role and policy for S3 replication.

## Prerequisites

- AWS Account with required permissions.
- Terraform v1.5 or later.
- AWS CLI configured (`aws configure`).
- Registered domain in Route 53 (e.g., `example.com`).
- Secure password for the RDS instance.

## Directory Structure

```
├── main.tf           # Core infrastructure resources (S3, RDS, Route 53)
├── provider.tf       # AWS provider configuration for primary and secondary regions
├── variables.tf      # Input variables (regions, domain, DB password)
└── README.md         # This file
```

## Setup Instructions

1. **Clone or Create Repository**
2. **Update Variables** in `variables.tf`:
   - `domain_name`: Replace with your domain.
   - `db_password`: Replace with a secure password.
   - Adjust `primary_region` or `secondary_region` if necessary.
3. **Initialize Terraform**:
   ```bash
   terraform init
   ```
4. **Review Plan**:
   ```bash
   terraform plan
   ```
5. **Deploy Infrastructure**:
   ```bash
   terraform apply
   ```
   Type `yes` to confirm.
6. **Verify Deployment**:
   - **S3**: Upload a file to the primary bucket and verify replication.
   - **RDS**: Confirm both primary and read replica are active.
   - **Route 53**: Check `app.<your-domain>` resolves to primary RDS, simulate failure to verify failover.

## Terraform Configuration Details

### provider.tf:

- Configures AWS providers for both regions using aliases.

### variables.tf:

- Input variables for regions, domain, and RDS password.

### main.tf:

- **S3**: Two versioned buckets with replication rule and IAM role.
- **RDS**: MySQL primary instance and cross-region read replica.
- **Route 53**: Hosted zone, failover policy, and health checks.
- **IAM**: Role and policy for replication actions.

## Key Resources

### S3:

- Buckets: `primary-bucket-<suffix>`, `secondary-bucket-<suffix>`
- Versioning and replication rule

### RDS:

- MySQL 8.0, `db.t3.micro`, 20GB storage
- Automated backups (1-day retention)
- Cross-region read replica

### Route 53:

- Hosted zone for specified domain
- Failover CNAME records
- Health check on port 3306 (use TCP or EC2-based endpoint)

### IAM:

- `s3-replication-role`
- Policy with S3 replication permissions

## Usage

### Accessing the Application:

Use `app.<your-domain>` to connect to the RDS instance. It resolves to the primary unless a failover occurs.

### Failover Testing:

Stop the primary RDS instance. Health checks will detect failure and Route 53 will switch DNS to the secondary.

### Data Storage:

Upload to the primary S3 bucket. Files will replicate automatically to the secondary bucket.

## Troubleshooting

### S3 Replication Fails:

- Check versioning on both buckets.
- Verify IAM permissions for replication.

### RDS Read Replica Not Created:

- Ensure `backup_retention_period = 1` in the primary instance.
- Primary must be in `Available` state.

### Route 53 Failover Issues:

- Verify health check configuration.
- Use RDS endpoint without port.
- Use TCP if HTTP fails.

### General Errors:

- Run `terraform plan` to debug.
- Check AWS Console for detailed logs.

## Production Considerations

### Security:

- Use private RDS with VPC security groups.
- Store passwords in AWS Secrets Manager.
- Enable encryption for S3 and RDS.

### Monitoring:

- CloudWatch alarms for RDS, S3, Route 53
- RDS Enhanced Monitoring

### Backups:

- Increase RDS backup retention
- S3 lifecycle policies

### Health Checks:

- Use TCP or EC2-based endpoint
- Whitelist Route 53 IPs in security groups

### Scalability:

- Upgrade RDS instance types
- Enable multi-AZ for primary

### Cost Optimization:

- Use Reserved Instances for RDS
- Monitor S3 replication/storage costs

## Cleanup

```bash
terraform destroy
```

![alt text](<Screenshot 2025-04-17 at 11.04.29 AM.png>)
![alt text](<Screenshot 2025-04-17 at 10.35.06 AM.png>)
![alt text](<Screenshot 2025-04-17 at 10.26.19 AM.png>)

Confirm with `yes`. Double-check resources are deleted in AWS Console.

## License

This project is provided as-is for educational purposes. Ensure compliance with AWS terms and conditions.

## Contact

For issues, refer to AWS documentation or contact AWS support. For Terraform-related help, consult the Terraform AWS Provider documentation.

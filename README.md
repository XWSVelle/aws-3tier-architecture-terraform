# aws-3tier-architecture-terraform
# Terraform-based AWS 3-tier highly available cloud architecture

#### SOSOCO AWS Infrastructure Project – Version 1 ####

## Business Scenario

SOSOCO is a young startup building an internal platform where companies can upload and share project documents with their teams.

Initially, the platform was hosted entirely on a single EC2 instance. The application, website, and uploaded files all lived on the same server.

As the company grew, several issues started appearing:

* Website performance degraded when too many users connected simultaneously
* Service outages occurred whenever the EC2 instance experienced issues
* Uploaded customer files were at risk because they were stored directly on the server
* Developers wanted a safer deployment process for future application releases
* The founders required a more professional and secure architecture before presenting the platform to investors

SOSOCO recruited a Junior Cloud / Infrastructure Engineer to redesign the environment using AWS and Terraform.

---

## Project Objective

Design and deploy a secure 3-tier cloud architecture using Infrastructure as Code (IaC) principles.

The solution must:

* Improve availability
* Protect application servers from direct internet access
* Move uploaded files to durable cloud storage
* Support future scalability
* Deploy infrastructure automatically using Terraform

---

## Founder Requirements

The founders requested:

* Infrastructure must remain available even if one Availability Zone fails
* Uploaded files should no longer be stored directly on EC2 instances
* Application servers must remain private
* Traffic should pass only through a Load Balancer
* Infrastructure deployment must be fully automated using Terraform
* Architecture should support future growth and scalability

---

## Target Architecture

Internet

↓

Application Load Balancer
(Public Subnets — AZ1 + AZ2)

↓

EC2 Application Servers
(Private Subnets — AZ1 + AZ2)

↓

S3 Bucket for Uploaded Files

---

## Architecture Diagram

sosoco-version1\aws-3tier-architecture-terraform\Architecture\sosoco-v1-diagram.png

---

## Infrastructure Deliverables

This implementation includes:

1. VPC with 2 Public Subnets and 2 Private Subnets
2. Internet Gateway
3. NAT Gateway
4. Security Groups
5. Application Load Balancer
6. EC2 Application Servers
7. IAM Role allowing EC2 access to S3
8. S3 Bucket for uploaded documents
9. Terraform-based infrastructure deployment

---

## Technologies Used

* AWS
* Terraform
* EC2
* VPC
* S3
* IAM
* ALB
* Networking
* Linux

---

## Future Improvements (Version 2)

* Auto Scaling Groups
* Terraform variables
* Terraform modules
* CI/CD pipelines
* Docker integration
* Monitoring and CloudWatch

---

> “We don’t want to lose customer files again, and we need an architecture that looks professional when we demo the product to investors.”
>
> — SOSOCO Founders

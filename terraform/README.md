# Voting App Infrastructure

This directory contains Terraform configuration for the Voting App DevOps capstone.

## Infrastructure

The current configuration declares an Amazon S3 bucket for project artifacts.

The AWS region, project name, and environment are configurable through variables.

## Prerequisites

- Terraform 1.5 or later
- AWS CLI
- AWS credentials with the permissions required for planned operations

## Initialize Terraform

Run from this directory:

    terraform init

## Format and validate

    terraform fmt
    terraform validate

## Preview infrastructure changes

    terraform plan

Review the plan before applying any changes.

**Important:** `terraform plan` previews changes. `terraform apply` can create or modify AWS resources and may incur charges. Do not run it without reviewing the plan and obtaining approval.

## Outputs

The configuration declares outputs for the AWS region, project name, and artifacts bucket name.

The bucket name output becomes available after the bucket is created and Terraform has recorded its state.

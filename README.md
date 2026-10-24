# SpendWise — AWS Cost Alerts with Terraform

**Know your cloud costs before they surprise you.**

SpendWise is a beginner-friendly Infrastructure as Code (IaC) project that uses Terraform to create an AWS monthly cost budget with email notifications. It helps AWS users monitor their spending and learn how to automate basic cloud cost-awareness configurations.

The project is designed to be reusable: each user deploys their own budget in their own AWS account.

## Project goals

- Create an AWS monthly cost budget using Terraform.
- Configure email notifications at 50%, 80%, and 100% of the budget.
- Demonstrate Infrastructure as Code for AWS cost monitoring.
- Help beginners understand budget alerts and their limitations.
- Provide reusable configuration, verification commands, and cleanup instructions.

## Architecture

```text
              AWS User
                  |
                  v
          Terraform CLI
                  |
                  v
           AWS Budgets API
                  |
                  v
         Monthly Cost Budget
               $10 USD
                  |
        +---------+---------+
        |         |         |
       50%       80%       100%
        |         |         |
        +---------+---------+
                  |
                  v
           Email Notifications
```

The architecture is intentionally simple. Terraform creates one AWS Budgets resource with three notification configurations. No EC2 instances, databases, or application servers are required.

## Technologies used

- **AWS Budgets** — monthly cost monitoring and notifications.
- **Terraform** — Infrastructure as Code.
- **AWS CLI** — AWS identity checks and verification.
- **Git and GitHub** — version control and project sharing.

## Project structure

```text
aws-spendwise/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars.example
│   └── terraform.tfvars
├── docs/
│   └── screenshots/
│       ├── 01-setup/
│       ├── 02-budget/
│       └── 03-alert-testing/
├── .gitignore
└── README.md
```

The real `terraform.tfvars` file is local and must not be committed to GitHub.

## How the budget works

The default monthly budget is **$10 USD**.

| Actual spending threshold | Approximate spending | Notification |
|---|---:|---|
| 50% | $5 | Early warning |
| 80% | $8 | Spending warning |
| 100% | $10 | Budget threshold warning |

The notifications use actual spending, the `GREATER_THAN` comparison operator, and percentage thresholds.

These are notification thresholds, not guaranteed trigger amounts. AWS cost data and notifications can be delayed, and a notification may arrive after spending has increased further.

## Prerequisites

Before deploying SpendWise, you need:

1. An AWS account.
2. Terraform installed (version 1.5 or later).
3. AWS CLI installed and configured.
4. An IAM identity with appropriate permissions to manage AWS Budgets.
5. An email address where you want to receive notifications.
6. PowerShell, a terminal, or another compatible command-line environment.

Check the installations:

```powershell
terraform -version
aws --version
aws sts get-caller-identity
```

The final command identifies the active AWS identity. Never publish your AWS account ID, access keys, or other sensitive account information.

## Step 1 — Clone the repository

After publishing this project to GitHub, users can clone it with:

```bash
git clone https://github.com/YOUR_USERNAME/aws-spendwise.git
cd aws-spendwise
```

Replace `YOUR_USERNAME` with the GitHub repository owner's username.

Alternatively, download the repository as a ZIP file and extract it.

## Step 2 — Configure the budget

Enter the Terraform directory:

```powershell
cd terraform
```

Copy the example configuration:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Open `terraform.tfvars` and edit the values:

```hcl
monthly_budget_limit = 10
notification_email   = "your-email@example.com"
```

Replace the example email with your own address. You can also change the monthly budget amount.

Keep `terraform.tfvars` private. Do not commit it to GitHub.

## Step 3 — Initialize and validate Terraform

Initialize Terraform and download the required provider:

```powershell
terraform init
```

Format the configuration:

```powershell
terraform fmt
```

Validate the configuration:

```powershell
terraform validate
```

Terraform should report that the configuration is valid.

## Step 4 — Review the deployment plan

Run:

```powershell
terraform plan
```

Review the proposed actions. For a fresh deployment, Terraform should propose creating one AWS Budgets resource.

Do not proceed if Terraform proposes unexpected changes or deletions. Investigate the plan first.

## Step 5 — Deploy SpendWise

When you are satisfied with the plan, run:

```powershell
terraform apply
```

Review the plan again and type `yes` when Terraform requests confirmation.

On successful deployment, Terraform should report that one resource was added.

The budget will be created in the AWS account associated with your active credentials.

## Step 6 — Verify the budget

Retrieve the account ID locally:

```powershell
$accountId = aws sts get-caller-identity --query Account --output text
```

Verify the budget:

```powershell
aws budgets describe-budget `
  --account-id $accountId `
  --budget-name "spendwise-monthly-budget" `
  --region us-east-1
```

Confirm that the budget limit is correct and that the time unit is `MONTHLY`.

## Step 7 — Verify notification subscriptions

Check the 50% notification:

```powershell
aws budgets describe-subscribers-for-notification `
  --account-id $accountId `
  --budget-name "spendwise-monthly-budget" `
  --notification "NotificationType=ACTUAL,ComparisonOperator=GREATER_THAN,Threshold=50,ThresholdType=PERCENTAGE" `
  --region us-east-1
```

Repeat the command with `Threshold=80` and `Threshold=100` to verify the remaining subscriptions.

Confirm that each notification has the expected email subscriber.

These checks verify the configured subscriptions. They do not prove that a threshold-triggered email has been delivered to an inbox.

## Security considerations

- Use an IAM identity with only the permissions required for the project.
- Do not publish AWS access keys, account IDs, personal email addresses, or sensitive screenshots.
- Do not commit `terraform.tfvars`, Terraform state files, or saved plan files.
- Protect Terraform state because it can contain configuration values and sensitive information.
- Review the Terraform plan before applying changes.
- Use your own AWS account and email address when deploying the project.

## Cost considerations and limitations

SpendWise creates an AWS Budgets resource and does not require an EC2 instance or other continuously running application infrastructure.

Check the current AWS Budgets pricing page before deployment: https://aws.amazon.com/aws-cost-management/aws-budgets/pricing/

AWS Budgets is a monitoring and notification mechanism, not a hard spending limit. It does not automatically stop resources when spending reaches the budget. Actual costs can exceed the configured threshold before an alert arrives.

Other services and resources in your AWS account can still incur charges independently of this project.

## Cleanup

When you no longer need the SpendWise budget, navigate to the Terraform directory and run:

```powershell
terraform destroy
```

Review the proposed deletion and type `yes` only if you want to remove the SpendWise resource.

**Important:** This command removes the budget managed by this Terraform configuration. It should not remove your separate, manually created personal budget.

Terraform state is required to manage the resource reliably. Do not delete your state file before destroying the resource. If you lose the state file, the AWS budget may remain in your account and require recovery or manual cleanup.

After cleanup, verify in the AWS console that `spendwise-monthly-budget` has been removed.

## Troubleshooting

### Terraform reports an undeclared variable

Ensure that `variables.tf` defines both `monthly_budget_limit` and `notification_email`.

### Terraform asks for an email address

Check that `terraform.tfvars` exists in the current Terraform directory and contains both required variables.

### AWS returns AccessDenied

The active IAM identity may not have the necessary permissions. Review the error and configure appropriate permissions before retrying.

### The notification subscription is missing

Run the subscriber verification commands and inspect the notification configuration in AWS Budgets.

### An email has not arrived

Check the configured email address, spam folder, AWS notification settings, and whether the actual-spending threshold has been exceeded. AWS cost data and notifications may be delayed.

## Learning outcomes

By completing SpendWise, users learn how to:

- Define AWS infrastructure using Terraform.
- Configure and verify AWS Budgets notifications.
- Use AWS CLI commands to inspect cloud resources.
- Parameterize infrastructure for reuse.
- Review deployment plans before changing cloud resources.
- Protect configuration files and Terraform state.
- Clean up resources after completing a project.

## Project status

The initial SpendWise budget has been deployed and its three email subscriptions have been verified in the developer's AWS account. The public repository, documentation, and evidence screenshots should be completed before presenting the project as a fully documented beginner tutorial.

## Contributing

Suggestions, improvements, and beginner-friendly documentation contributions are welcome. Please avoid including personal account details, credentials, or sensitive information in issues and pull requests.

## License

Choose an open-source license before publishing the repository. The MIT License is a reasonable option if you want others to reuse and adapt this educational project.

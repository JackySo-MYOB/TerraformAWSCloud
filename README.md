# Complete Terraform github action workflow


## Push trigger

Workflow “trigger” for when this Action should run. We use on “Push”, meaning if any file in this entire repo is updated at all in the master branch, this action will run. There are lots of other “on” triggers that can be used, check them out [here](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/events-that-trigger-workflows)

```yaml
name: Terraform Apply
on: [push]
```

## Job 
The next part of the file describes the jobs we’d like the container to take. We name it (“terraform_apply”), and set a runs-on. We’re using Ubuntu latest, but other previous Ubuntu are available, as well as Windows and Mac. the list of available builders is [here](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/workflow-syntax-for-github-actions#jobsjob_idruns-on)

```yaml
jobs:
  terraform_apply:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
```

## Steps 
The first task we want our terraform_apply container to do, called a “step” in Actions language. First, we set an environmental variable in the “env” block— the terraform version. That’s hard-coded in our script, and can be updated only in this single location, rather than in each command that references it.
Then we have a “run” block. You can reference a single command direction, like run: echo hello world, but if you want to run multiple commands in a single step, you use the run: | block and then separate each command with a return. We are downloading the TF version directly from HashiCorp, unzipping it, then moving it to our local exec path.

```yaml

    - name: Install Terraform
      env:
            TERRAFORM_VERSION: "0.12.15"
      run: |
        tf_version=$TERRAFORM_VERSION
        wget https://releases.hashicorp.com/terraform/"$tf_version"/terraform_"$tf_version"_linux_amd64.zip
        unzip terraform_"$tf_version"_linux_amd64.zip
        sudo mv terraform /usr/local/bin/
```

Then we start doing Terraform things with several blocks — first, a simple terraform --version to check our version installed correctly, then we initialize terraform. We’re using the same environmental variables we used when local to our computer — the access key and secret access key. Then we validate and apply the terraform.
Warning: Remember that there is no approval step before changes are pushed out. This is great for a lab, and terrible for prod. There are no tools I can find that permit dual-stages with an approval step in the middle, or manual “apply” runs. 

```yaml

    - name: Verify Terraform version
      run: terraform --version

    - name: Terraform init
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      run: terraform init -input=false

    - name: Terraform validation
      run: terraform validate

    - name: Terraform apply
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      run: terraform apply -auto-approve -input=false
```


## .github/workflows/terraform.yml

```yaml

# This workflow installs the latest version of Terraform CLI and configures the Terraform CLI configuration file
# with an API token for Terraform Cloud (app.terraform.io). On pull request events, this workflow will run
# `terraform init`, `terraform fmt`, and `terraform plan` (speculative plan via Terraform Cloud). On push events
# to the master branch, `terraform apply` will be executed.
#
# Documentation for `hashicorp/setup-terraform` is located here: https://github.com/hashicorp/setup-terraform
#
# To use this workflow, you will need to complete the following setup steps.
#
# 1. Create a `main.tf` file in the root of this repository with the `remote` backend and one or more resources defined.
#   Example `main.tf`:
#     # The configuration for the `remote` backend.
#     terraform {
#       backend "remote" {
#         # The name of your Terraform Cloud organization.
#         organization = "example-organization"
#
#         # The name of the Terraform Cloud workspace to store Terraform state files in.
#         workspaces {
#           name = "example-workspace"
#         }
#       }
#     }
#
#     # An example resource that does nothing.
#     resource "null_resource" "example" {
#       triggers = {
#         value = "A example resource that does nothing!"
#       }
#     }
#
#
# 2. Generate a Terraform Cloud user API token and store it as a GitHub secret (e.g. TF_API_TOKEN) on this repository.
#   Documentation:
#     - https://www.terraform.io/docs/cloud/users-teams-organizations/api-tokens.html
#     - https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets
#
# 3. Reference the GitHub secret in step using the `hashicorp/setup-terraform` GitHub Action.
#   Example:
#     - name: Setup Terraform
#       uses: hashicorp/setup-terraform@v1
#       with:
#         cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

name: 'Terraform'

on:
  push:
    branches:
    - master
  pull_request:

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest

    # Use the Bash shell regardless whether the GitHub Actions runner is ubuntu-latest, macos-latest, or windows-latest
    defaults:
      run:
        shell: bash

    # Checkout the repository to the GitHub Actions runner
    steps:
    - name: Checkout
      uses: actions/checkout@v2

    # Install the latest version of Terraform CLI and configure the Terraform CLI configuration file with a Terraform Cloud user API token
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v1
      with:
        cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

    # Initialize a new or existing Terraform working directory by creating initial files, loading any remote state, downloading modules, etc.
    - name: Terraform Init
      run: terraform init

    # Checks that all Terraform configuration files adhere to a canonical format
    - name: Terraform Format
      run: terraform fmt -check

    # Generates an execution plan for Terraform
    - name: Terraform Plan
      run: terraform plan

      # On push to master, build or change infrastructure according to Terraform configuration files
      # Note: It is recommended to set up a required "strict" status check in your repository for "Terraform Cloud". See the documentation on "strict" required status checks for more information: https://help.github.com/en/github/administering-a-repository/types-of-required-status-checks
    - name: Terraform Apply
      if: github.ref == 'refs/heads/master' && github.event_name == 'push'
      run: terraform apply -auto-approve

```

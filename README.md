# terragrunt-demo
one of the best practice of terragrunt

1. add .pre-commit-config.yaml on your terragrunt git repo  
  [pre-commit](https://pre-commit.com/) is very useful tool useful for identifying simple issues before submission to code review.  
  Before you can run hooks, you need to have the pre-commit package manager installed.  
  https://pre-commit.com/#installation
  
  * Add .pre-commit-config.yaml from https://github.com/gruntwork-io/pre-commit
  ```yaml
  repos:
  - repo: https://github.com/gruntwork-io/pre-commit
    rev: <VERSION> # Get the latest from: https://github.com/gruntwork-io/pre-commit/releases
    hooks:
      - id: terraform-fmt
      - id: terraform-validate
      - id: tflint
      - id: shellcheck
      - id: gofmt
      - id: golint
  ```

2. add .gitignore on your terragrunt git repo
```
.*.sw?
.idea
terragrunt.iml
vendor
.terraform
.vscode
*.tfstate
*.tfstate.backup
*.out
.terragrunt-cache
.bundle
.ruby-version
.terraform.lock.hcl
terragrunt
```
3. 
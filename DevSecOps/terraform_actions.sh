terraform_actions.sh:

#!/bin/bash

set -e

ACTION=$1

case "$ACTION" in
  init)
    terraform init
    ;;
  plan)
    terraform plan
    ;;
  apply)
    terraform apply -auto-approve
    ;;
  test)
    terraform validate
    ;;
  destroy)
    terraform destroy -auto-approve
    ;;
  *)
    echo "Usage: $0 {init|plan|apply|test|destroy}"
    exit 1
    ;;
esac

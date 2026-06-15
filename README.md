# Kittygram infrastructure

Terraform creates the Kittygram infrastructure in Yandex Cloud:

- VPC network and subnet;
- static public IP;
- security group with inbound ports `22` and `9000`;
- Ubuntu 24.04 VM prepared by cloud-init;
- Object Storage bucket for Terraform state.

The application is built and deployed by GitHub Actions.

## State bucket

Authenticate `yc` in the required organization and create the state bucket:

```bash
export YC_TOKEN=$(yc iam create-token)
terraform -chdir=infra/bootstrap init
terraform -chdir=infra/bootstrap apply \
  -var="bucket_name=kittygram-tfstate-itmp9"
```

The bootstrap state contains credentials and must stay local. Get values for
GitHub secrets:

```bash
terraform -chdir=infra/bootstrap output -raw bucket_name
terraform -chdir=infra/bootstrap output -raw access_key
terraform -chdir=infra/bootstrap output -raw secret_key
terraform -chdir=infra/bootstrap output -raw authorized_key
```

## GitHub secrets

Infrastructure:

| Secret | Value |
| --- | --- |
| `TF_STATE_BUCKET` | `bucket_name` output |
| `ACCESS_KEY` | `access_key` output |
| `SECRET_KEY` | `secret_key` output |
| `YC_SERVICE_ACCOUNT_KEY` | `authorized_key` output |
| `SSH_PUBLIC_KEY` | Public SSH key used by cloud-init |
| `SSH_KEY` | Matching private SSH key |

Application:

| Secret | Value |
| --- | --- |
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub token |
| `POSTGRES_DB` | PostgreSQL database name |
| `POSTGRES_USER` | PostgreSQL username |
| `POSTGRES_PASSWORD` | PostgreSQL password |
| `DJANGO_SECRET_KEY` | Django secret key |
| `TELEGRAM_CHAT_ID` | Telegram chat ID |
| `TELEGRAM_TOKEN` | Telegram bot token |

## Deploy

Run the `Terraform` workflow with the `apply` action. Its summary contains the
VM IP and the application URL.

Replace the temporary address in `tests.yml` with that URL:

```yaml
kittygram_domain: http://<vm-ip>:9000
```

Push to `main`. The `Kittygram Deploy` workflow checks the backend and
frontend, publishes three Docker images, deploys the application, runs the
external tests, and sends the Telegram notification.

Use the `destroy` action in the `Terraform` workflow to remove the main
infrastructure. The state bucket is managed separately in `infra/bootstrap`.

# Install Docker & Docker Compose

## Usage

Make sure the script is executable:
```bash
chmod +x install_docker.sh
```

Run the installation script:
```bash
./install_docker.sh
```

# Install Self-Hosted Supabase

## Usage

Make sure the script is executable:
```bash
chmod +x install_supabase.sh
```

Run the installation script:
```bash
sudo ./install_supabase.sh
```
## Start Supabase

Start the services (in detached mode):
```bash
docker compose up -d
```

After all the services have started you can see them running in the background:
```bash
docker compose ps
```

After a minute or less, all services should have a status Up [...] (healthy). If you see a status such as created but not Up, try inspecting the Docker logs for a specific container, e.g.,
```bash
docker compose logs analytics
```

To stop Supabase, use:
```bash
docker compose down
```

## Supabase Supervisor

| Field    | Value                    |
|----------|--------------------------|
| Host     | `localhost`              |
| Port     | `5432`                   |
| Database | `postgres`               |
| Username | `postgres.<tenant-id>`   |
| Password | your `POSTGRES_PASSWORD` |

# Database Configuration Setup

## Prerequisites
- Supabase account with an active project
- Local PostgreSQL instance running

---

## Configuration


```
CLOUD_DB_URL="postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres"
LOCAL_DB_URL="postgresql://postgres.[YOUR-TENANT-ID]:[YOUR-LOCAL-PASSWORD]@localhost:5432/postgres"
```

---

## Replace the Placeholders

### Cloud Database (`CLOUD_DB_URL`)
| Placeholder | Description | Example |
|---|---|---|
| `[YOUR-PASSWORD]` | Supabase database password | `mypassword123` |
| `[YOUR-PROJECT-REF]` | Supabase project reference ID | `abcdefghijklmn` |

> **Where to find it:** Supabase Dashboard → Project Settings → Database → Connection String

### Local Database (`LOCAL_DB_URL`)
| Placeholder | Description | Example |
|---|---|---|
| `[YOUR-TENANT-ID]` | Your local tenant/project ID | `myproject` |
| `[YOUR-LOCAL-PASSWORD]` | Your local PostgreSQL password | `localpassword` |

> **Where to find it:** Your local PostgreSQL setup credentials

---

## Example
```env
CLOUD_DB_URL="postgresql://postgres:mypassword123@db.abcdefghijklmn.supabase.co:5432/postgres"
LOCAL_DB_URL="postgresql://postgres.myproject:localpassword@localhost:5432/postgres"
```


# Run sync db script

Make sure the script is executable:
```bash
chmod +x *.sh
```
Run the installation script:
```bash
sudo ./sync_db.sh
```


# Setup Cronjob

## Usage

Setup cron script:
```bash
sudo ./cron_manager.sh setup
```

Stop cron script:
```bash
sudo ./cron_manager.sh stop
```

Check Cronjob list:
```bash
crontab -l
```

# Prerequisites
- Sufficient permissions (you may need `sudo`)


#!/bin/bash

# ── CONFIG ──────────────────────────────────────────────
CLOUD_DB_URL="postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres"
LOCAL_DB_URL="postgresql://postgres.[YOUR-TENANT-ID]:[YOUR-LOCAL-PASSWORD]@localhost:5432/postgres"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups"
LOG_DIR="$SCRIPT_DIR/logs"
BACKUP_FILE="$BACKUP_DIR/supabase_backup_$(date +%Y%m%d_%H%M%S).sql"
LOG_FILE="$LOG_DIR/supabase_sync.log"

# ────────────────────────────────────────────────────────

# Create directories FIRST before any logging
mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

echo "[$(date)] Starting sync..." >> "$LOG_FILE"


# 1. Reset local public schema
echo "[$(date)] Resetting local public schema..." >> "$LOG_FILE"
psql "$LOCAL_DB_URL" <<EOF
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
EOF

if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: reset failed" >> "$LOG_FILE"
  exit 1
fi

# 2. Dump only the public schema from cloud
pg_dump \
  --no-owner \
  --no-acl \
  --clean \
  --if-exists \
  --schema=public \
  "$CLOUD_DB_URL" > "$BACKUP_FILE"

if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: pg_dump failed" >> "$LOG_FILE"
  exit 1
fi

# 3. Restore to local
psql "$LOCAL_DB_URL" < "$BACKUP_FILE"

if [ $? -ne 0 ]; then
  echo "[$(date)] ERROR: restore failed" >> "$LOG_FILE"
  exit 1
fi

# 5. Clean up
rm "$BACKUP_FILE"
echo "[$(date)] Sync complete." >> "$LOG_FILE"

# 5. Refresh materialized views

# Ordered list of materialized views (dependencies first)
VIEWS=(
    "markings_with_subject_grade"
    "markings_final_grade"
    "gps_ngpm_subjects"
    "gps_school"
    "gps_district"
    "results_school"
    "results_year"
    "gps_ngpm_subjects_district"
    "gps_subject_overall"
    "gps_year"
    "markings_with_subject_grade_v2"
    "results_district"
    "stats_school_category"
    "stats_year"
    "gps_subject_overall_nongraded"
)

echo "======================================"
echo " Refreshing Materialized Views"
echo " Started: $(date)"
echo "======================================"

SUCCESS=0
FAILED=0

for VIEW in "${VIEWS[@]}"; do
    echo -n "Refreshing $VIEW ... "
    
    RESULT=$(psql "$LOCAL_DB_URL" -c "REFRESH MATERIALIZED VIEW $VIEW;" 2>&1)
    
    if [ $? -eq 0 ]; then
        echo "✓ OK"
        ((SUCCESS++))
    else
        echo "✗ FAILED"
        echo "  Error: $RESULT"
        ((FAILED++))
        # Uncomment to stop on first failure:
        # exit 1
    fi
done

echo "======================================"
echo " Done: $SUCCESS succeeded, $FAILED failed"
echo " Finished: $(date)"
echo "======================================"

exit $FAILED

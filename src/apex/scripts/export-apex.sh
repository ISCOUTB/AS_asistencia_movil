#!/bin/bash
set -e

if [ -z "$APP_ID" ]; then
  echo "❌ APP_ID no definido"
  exit 1
fi

echo "=== Exportando aplicación APEX ID $APP_ID del workspace ==="

sql -s $DB_USER/$DB_PASS@$DB_HOST:$DB_PORT/$DB_SERVICE <<EOF
apex export -applicationid $APP_ID -skipExportDate -dir apex_exports
exit;
EOF

echo "✅ Export terminado -> apex_exports/f${APP_ID}.sql"

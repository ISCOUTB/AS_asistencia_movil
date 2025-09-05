#!/bin/bash
set -e

echo "=== Importando aplicación APEX en el workspace ==="

sql $DB_USER/$DB_PASS@$DB_HOST:$DB_PORT/$DB_SERVICE <<EOF
begin
    apex_application_install.set_workspace('MI_WORKSPACE');
    apex_application_install.generate_application_id(true);
    apex_application_install.generate_offset;
end;
/
@/docker-entrypoint-initdb.d/f100.sql
exit;
EOF

echo "✅ Aplicación importada"

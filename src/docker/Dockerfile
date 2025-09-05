FROM gvenzl/oracle-xe:21-slim

# Instalar dependencias
USER root
RUN apt-get update && apt-get install -y wget unzip bash && rm -rf /var/lib/apt/lists/*

# Instalar SQLcl
RUN wget https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip -O /tmp/sqlcl.zip \
    && unzip /tmp/sqlcl.zip -d /opt/ \
    && rm /tmp/sqlcl.zip

ENV PATH="/opt/sqlcl/bin:${PATH}"

# Copiar código exportado y scripts
COPY apex_exports/*.sql /docker-entrypoint-initdb.d/
COPY scripts/import_apex.sh /docker-entrypoint-initdb.d/import_apex.sh
RUN chmod +x /docker-entrypoint-initdb.d/import_apex.sh

USER oracle

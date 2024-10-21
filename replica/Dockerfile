FROM postgres:13

COPY setup-replica.sh /docker-entrypoint-initdb.d/
COPY postgres.conf /etc/postgresql/postgresql.conf

RUN chmod 755 /docker-entrypoint-initdb.d/setup-replica.sh

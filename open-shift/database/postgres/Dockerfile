FROM postgres:9.4

LABEL com.singlehop.maintainer="Singlehop <dev@singlehop.com>"
LABEL com.singlehop.widget.version="1.0"
LABEL com.singlehop.widget.resource="database"

COPY ./scripts/init-remove-public-schema.sh /docker-entrypoint-initdb.d/init-remove-public-schema.sh
COPY ./scripts/init-add-application-schema.sh /docker-entrypoint-initdb.d/init-add-application-schema.sh

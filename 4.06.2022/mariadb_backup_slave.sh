#!/bin/bash

DATE=$(date +"%Y-%m-%d")
WORK_DIR=mysql_backups
MYSQL_PASS=Digger398!
MYSQL_DATABASES=$(mysql -uroot -p"$MYSQL_PASS" --skip-column-names -e "SHOW DATABASES LIKE '%otus%'";)

##############
# stop slave #
##############
mysql -uroot -p"$MYSQL_PASS" -e "STOP SLAVE";

##################
# dumping tables #
##################

for db in "${MYSQL_DATABASES[@]}"
    do
        mkdir -p "$WORK_DIR"/"$DATE"/"$db" && \
        echo "${db}" && \
        mysql -uroot -p"$MYSQL_PASS" "$db" --skip-column-names -s -e 'SHOW TABLES' | xargs -P4 -I {} \
        mysqldump -uroot -p"$MYSQL_PASS" --add-drop-table \
        --add-locks -q -Q \
        --source-data=2 \
        --single-transaction \
        --create-options \
        --disable-keys \
        --extended-insert \
        --set-charset \
        --routines \
        --quick \
        --events \
        --triggers "$db" '{}' -r "${WORK_DIR}"/"${DATE}"/"${db}"/'{}'.sql && \

        echo "database dumped successfully"

    done

###############
# start slave #
###############
mysql -uroot -p"$MYSQL_PASS" -e "START SLAVE";

###################################
# show slave status after backups #
###################################
mysql -uroot -p"$MYSQL_PASS" -e "SHOW SLAVE STATUS\G";
exit 0;
# src/bash/qto/funcs/backup-postgres-db.func.sh

# v0.7.4
# ---------------------------------------------------------
# create a full database backup containing db create clause
# ---------------------------------------------------------
doBackupPostgresDb(){

   test -f $PRODUCT_INSTANCE_DIR/bootstrapping && return
   test -z "${PROJ_INSTANCE_DIR-}" && PROJ_INSTANCE_DIR="$PRODUCT_INSTANCE_DIR"
   source $PROJ_INSTANCE_DIR/.env ; env_type=$ENV_TYPE
   doExportJsonSectionVars $PROJ_INSTANCE_DIR/cnf/env/$env_type.env.json '.env.db'

   mix_data_dir="$PROJ_INSTANCE_DIR/dat/mix"
   test -z "${postgres_db_name-}" && postgres_db_name="${env_type-}"_"${run_unit//-/_}"

   backup_dir=$mix_data_dir/$(date "+%Y")/$(date "+%Y-%m")/$(date "+%Y-%m-%d")/sql/$postgres_db_name
   backup_fname=$postgres_db_name.`date "+%Y%m%d_%H%M%S"`.full.dmp.sql
   test -d $backup_dir || mkdir -p $backup_dir

   which nmap 2>/dev/null && nmap -Pnv -p $postgres_db_port $postgres_db_host || \
         doExit 1 "cannot connect to $postgres_db_port:$postgres_db_host"

   PGPASSWORD="${postgres_db_useradmin_pw:-}" pg_dump -U "${postgres_db_useradmin:-}"  \
         -h $postgres_db_host -p $postgres_db_port -w --format=plain \
         $postgres_db_name   > $backup_dir/$backup_fname

   ls -1 $mix_data_dir/$(date "+%Y")/$(date "+%Y-%m")/$(date "+%Y-%m-%d")/sql/$postgres_db_name/* | sort -nr
   echo -e "\n"
   wc -l $mix_data_dir/$(date "+%Y")/$(date "+%Y-%m")/$(date "+%Y-%m-%d")/sql/$postgres_db_name/* | sort -nr
   sleep 1

}


# eof file: src/bash/qto/funcs/backup-postgres-db.func.sh

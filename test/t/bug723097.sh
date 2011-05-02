. inc/common.sh

init
run_mysqld --innodb_file_per_table

vlog "Loading data from sql file"
run_cmd ${MYSQL} ${MYSQL_ARGS} test < t/bug723097.sql

vlog "Saving checksum"
checksum_a=`${MYSQL} ${MYSQL_ARGS} -Ns -e "CHECKSUM TABLE messages" test | awk {'print $2'}`
vlog "Checksum before is $checksum_a"

vlog "Creating backup directory"
mkdir -p $topdir/data/full
vlog "Starting backup"
xtrabackup --datadir=$mysql_datadir --backup --target-dir=$topdir/data/full
vlog "Backup is done"
xtrabackup --datadir=$mysql_datadir --prepare --target-dir=$topdir/data/full
vlog "Data prepared fo restore"
stop_mysqld

cd $topdir/data/full/test
cp -r * $mysql_datadir/test
cd -
run_mysqld --innodb_file_per_table
checksum_b=`${MYSQL} ${MYSQL_ARGS} -Ns -e "CHECKSUM TABLE messages" test | awk {'print $2'}`
vlog "Checksum after is $checksum_b"
stop_mysqld

if [ $checksum_a -eq $checksum_b ]
then
	vlog "Checksums are Ok"
else
	vlog "Checksums are not equal"
	exit -1
fi

clean 

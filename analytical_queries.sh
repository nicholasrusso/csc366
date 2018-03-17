#!/bin/bash

my_sql_conn="mysql -h cslvm74.csc.calpoly.edu"
output_file="./dataWarehouseOutput.txt"
reset_file="./resetDataWarehouse.sql"
account_file="./account/accountRegistrationReport.sql"
device_file="./device/deviceRegistrationReport.sql"
email_file="./emailCampaigns/emailCampaignReport.sql"

echo "Enter your password for cslvm74.csc.calpoly.edu: "
read -s my_sql_passwd
my_sql="$my_sql_conn --password=$my_sql_passwd"

if [ ! -f $account_file ]; then
    echo "Account not found"
    exit 1
fi

if [ ! -f $device_file ]; then
    echo "Device not found"
    exit 1
fi

if [ ! -f $email_file ]; then
    echo "Email not found"
    exit 1
fi

echo "Outputting to ${output_file}."
echo "" > $output_file

startTime=`date +%s%N | cut -b1-13`

echo "Running $reset_file"
$my_sql < $reset_file

echo "Running $account_file"
$my_sql < $account_file >> $output_file

echo "Running $device_file"
$my_sql < $device_file >> $output_file

echo "Running $email_file"
$my_sql < $email_file >> $output_file

endTime=`date +%s%N | cut -b1-13`

totalTime=`expr $endTime - $startTime`

echo "Total Runtime: $(echo "scale=2;${totalTime}/1000" | bc) seconds."

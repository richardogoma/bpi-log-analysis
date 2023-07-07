#!/usr/bin/env bash

file=./output.log

# Eyeball log entries
cat $file \
    | petl "fromcsv() \
            .pushheader(['log_entry']) \
            .addrownumbers() \
            .look()"

# Capture relevant values into new fields
timestamp_pattern='(\d{4}-\d{2}-\d{2} \d{2}:\d{2})'
log_type_pattern='(\w+)'
duration_pattern='(\d+\.\d+)'
captured_groups="${timestamp_pattern}[\d\.\:\s]+${log_type_pattern}[\w\d\.\:\-\+\s]+${duration_pattern}"
cat $file \
    | petl "fromcsv() \
            .pushheader(['log_entry']) \
            .addrownumbers() \
            .capture('log_entry', '$captured_groups', ['timestamp','log_type', 'duration']) \
            .head()"

# Calculate basic descriptive statistics on the duration field
echo "Printing to console descriptive stats of the ETL process duration field ..."
cat $file \
    | petl "fromcsv() \
            .pushheader(['log_entry']) \
            .addrownumbers() \
            .capture('log_entry', '$captured_groups', ['timestamp','log_type', 'duration'], fill=[None, None, None]) \
            .stats('duration')"

# Create CSV file from processed log entries
echo "Loading processed log dataset to file system ..."
cat $file \
    | petl "fromcsv() \
            .pushheader(['log_entry']) \
            .addrownumbers() \
            .capture('log_entry', '$captured_groups', ['timestamp','log_type', 'duration'], fill=[None, None, None]) \
            .tocsv('processed_log.csv')"


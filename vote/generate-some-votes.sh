#!/bin/sh

# create POST data files with ab friendly formats
python make-data.py

# create 3000 votes
ab -n 1000 -c 50 -p posta -T "application/x-www-form-urlencoded" http://vote/
ab -n 1000 -c 50 -p postb -T "application/x-www-form-urlencoded" http://vote/
ab -n 1000 -c 50 -p posta -T "application/x-www-form-urlencoded" http://vote/

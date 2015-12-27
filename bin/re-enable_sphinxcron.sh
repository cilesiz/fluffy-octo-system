#!/bin/bash
sed -e 's/\#\*/\*/g' -e 's/\#@/@/g' /etc/cron.d/sphinx-indexer

#!/bin/bash

for i in `seq 1 3`
do
echo -e "\nrestarting memcached on ***$i***\n"
ssh mt-load-memcached-$i.host.cdc "/etc/init.d/memcached restart"
done


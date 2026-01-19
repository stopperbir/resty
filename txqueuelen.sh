#!/bin/bash
#!ifconfig bond0 txqueuelen 20000 && ifconfig eno12399 txqueuelen 20000 && ifconfig eno12409 txqueuelen 20000 && ifconfig lo txqueuelen 20000
blockdev --setra 4096 /dev/md0 && blockdev --setra 4096 /dev/nvme0n1 && blockdev --setra 4096 /dev/nvme1n1 && blockdev --report

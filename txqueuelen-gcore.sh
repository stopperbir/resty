#!/bin/bash
ifconfig bond0 txqueuelen 200000 && ifconfig bond0.2828 txqueuelen 200000 && ifconfig docker0 txqueuelen 200000 && ifconfig ens2f0np0 txqueuelen 200000 && ifconfig ens2f1np1 txqueuelen 200000 && ifconfig lo txqueuelen 200000

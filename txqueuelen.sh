#!/bin/bash
ifconfig bond0 txqueuelen 20000 && ifconfig eno12399 txqueuelen 20000 && ifconfig eno12409 txqueuelen 20000 && ifconfig lo txqueuelen 20000

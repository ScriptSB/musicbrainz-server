#!/bin/bash -u

export PERL_CARTON_PATH=~/carton-local

mb_server=`dirname $0`/../..
cd $mb_server

OUTPUT=`carton exec -- ./admin/BuildSitemaps.pl --ping` || echo "$OUTPUT"

# eof

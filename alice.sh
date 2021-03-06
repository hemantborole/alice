#!/bin/sh

retval=0
case "$1" in
'start')
  # Start alice
  ALICE_BASE='/alice'
  cd ${ALICE_BASE}
  if [ ! -f ebin/rest_app.boot ]; then
          make all_boot
  fi
  sudo -u rabbitmq erl -pa ebin -pa deps/*/ebin -name alice -s reloader -boot alice -setcookie `cat ~/.erlang.cookie` -noshell $@
  ;;
'stop')
  # Stop alice
  count=`ps aux|grep "beam.*alice"|grep -v grep|wc -l`
  if [ ${count} -gt 1 ]
  then
    echo "Could not kill Alice, multiple instances found. Kill Alice manually"
    retval=254
  elif [ "${count}" -eq 0 ]; then
    echo "Could not kill Alice, Alice is not running"
    retval=255
  else
    pid=`ps aux|grep "beam.*alice"|grep -v grep|awk '{print $2}'`
    sudo -u rabbitmq kill -9 "${pid}"
  fi
  ;;
'restart')
  $0 stop
  $0 start
  ;;
esac
exit $retval

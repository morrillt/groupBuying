#!/bin/sh 
# wrapper to daemonize rake tasks: see also http://mmonit.com/wiki/Monit/FAQ#pidfile
usage() { 
  echo "usage: ${0} [start|stop] name target [arguments]" 
  echo "\tname is used to create or read the log and pid file names" 
  echo "\tfor start: target and arguments are passed to rake" 
  echo "\tfor stop: target and arguments are passed to kill (e.g.: -n 3)" 
  exit 1
} 
[ $# -lt 2 ] && usage
cmd=$1 
name=$2 
shift ; shift

pid_file=./tmp/pids/${name}.pid 
log_file=./log/${name}.log

case $cmd in 
  start)
    if [ ${#} -eq 0 ] ; then 
      echo -e "\nERROR: missing target\n" 
      usage
    fi 
    pid=`cat ${pid_file} 2> /dev/null` 
    if [ -n "${pid}" ] ; then
      ps ${pid} 
      if [ $? -eq 0 ] ; then
        echo "ensure process ${name} (pid: ${pid_file}) is not running" 
        exit 1
      fi
    fi 
    echo $$ > ${pid_file} 
    exec 2>&1 rake $* 1>> ${log_file} ;;
  stop) pid=`cat ${pid_file} 2> /dev/null` 
    [ -n "${pid}" ] && kill $* ${pid} 
    rm -f ${pid_file} ;;
    *) usage ;; 
esac
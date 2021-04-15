#!/bin/bash
### SCRIPT TO CHECK THE SERVICES RUNNING ON REMOTE SERVER ###


######WORK DIRECTORY######
WORKDIR="/root"

###HTTP###
HTTPSERVERIP="10.0.0.1"
HTTPSERVERPORT="80"
##########

###HTTPS###
HTTPSSERVERIP="10.0.0.2"
HTTPSSERVERPORT="443"
##########

###MAIL###
SMTPSERVERIP="10.0.0.3"
SMTPSERVERPORT="25"
##########

###DNS###
DNSSERVERIP="10.0.0.4"
DOMAINTOCHECKDNS="carnival.com.bd"
ANSWERIP="10.0.0.10"
#########

###SSH###
SSHSERVERIP="10.0.0.5"
SSHSERVERPORT="22"
#########

###NOTIFICATIONS###
EMAIL="mail@testmail.com"
##########

 
 
### Binaries ###
MAIL=$(which mail)
TELNET=$(which telnet)
DIG=$(which dig)

### DATE TIME ###
TIME=$(date)

###Change dir###
cd $WORKDIR

###Restore when problem fix###
if [ $1 ]; then
  if [ $1=="fix" ]; then
    rm server_problem*.txt
	exit 1;
  fi
fi

###Check if already notified###
if [ -f server_problem.txt ]; then
  exit 1;
fi
 
###Test SMTP###
(
echo "quit"
) | $TELNET $SMTPSERVERIP $SMTPSERVERPORT | grep Connected > /dev/null 2>&1
if [ "$?" -ne "1" ]; then #Ok
  echo "PORT CONNECTED"
  if [ -f server_problem_first_time_smtp.txt ]; then #remove file if problem fixed
    rm -rf server_problem_first_time_smtp.txt
  fi
else #Connection failure
  if [ -f server_problem_first_time_smtp.txt ]; then #Second time, send notification below
    echo "SMTP PORT NOT CONNECTING" >> server_problem.txt
	rm -rf server_problem_first_time_smtp.txt
  else #First notification
    > server_problem_first_time_smtp.txt
  fi
fi
 
###Test HTTP###
(
echo "quit"
) | $TELNET $HTTPSERVERIP $HTTPSERVERPORT | grep Connected > /dev/null 2>&1
if [ "$?" -ne "1" ]; then #Ok
  echo "PORT CONNECTED"
  if [ -f server_problem_first_time_http.txt ]; then #remove file if problem fixed
    rm -rf server_problem_first_time_http.txt
  fi
else #Connection failure
  if [ -f server_problem_first_time_http.txt ]; then #Second time, send notification below
    echo "HTTP PORT NOT CONNECTING" >> server_problem.txt
	rm -rf server_problem_first_time_http.txt
  else #First notification
    > server_problem_first_time_http.txt
  fi
fi
 
###Test HTTPS###
(
echo "quit"
) | $TELNET $HTTPSSERVERIP $HTTPSSERVERPORT | grep Connected > /dev/null 2>&1
if [ "$?" -ne "1" ]; then #Ok
  echo "PORT CONNECTED"
  if [ -f server_problem_first_time_https.txt ]; then #remove file if problem fixed
    rm -rf server_problem_first_time_https.txt
  fi
else #Connection failure
  if [ -f server_problem_first_time_https.txt ]; then #Second time, send notification below
    echo "HTTPS PORT NOT CONNECTING" >> server_problem.txt
	rm -rf server_problem_first_time_https.txt
  else #First notification
    > server_problem_first_time_https.txt
  fi
fi
 
 
 
###Test DNS###
$DIG $DOMAINTOCHECKDNS @$DNSSERVERIP | grep $ANSWERIP
 
if [ "$?" -ne "1" ]; then #Ok
  echo "PORT CONNECTED"
  if [ -f server_problem_first_time_dns.txt ]; then #remove file if problem fixed
    rm -rf server_problem_first_time_dns.txt
  fi
else #Connection failure
  if [ -f server_problem_first_time_dns.txt ]; then #Second time, send notification below
    echo "DNS PORT NOT CONNECTING" >> server_problem.txt
	rm -rf server_problem_first_time_dns.txt
  else #First notification
    > server_problem_first_time_dns.txt
  fi
fi

###Test SSH###
(
echo "quit"
) | $TELNET $SSHSERVERIP $SSHSERVERPORT | grep Connected > /dev/null 2>&1
if [ "$?" -ne "1" ]; then #Ok
  echo "PORT CONNECTED"
  if [ -f server_problem_first_time_ssh.txt ]; then #remove file if problem fixed
    rm -rf server_problem_first_time_ssh.txt
  fi
else #Connection failure
  if [ -f server_problem_first_time_ssh.txt ]; then #Second time, send notification below
    echo "SSH PORT NOT CONNECTING" >> server_problem.txt
	rm -rf server_problem_first_time_ssh.txt
  else #First notification
    > server_problem_first_time_ssh.txt
  fi
fi

 
###Send mail notification after 2 failed check###
if [ -f server_problem.txt ]; then
  echo "$TIME" >> server_problem.txt
  $MAIL -s "Server Monitoring Alert" $EMAIL < /root/server_problem.txt
  rm -rf server_problem.txt
fi

### USE THE FOLLOWING COMMAND TO SET TIMER TO RUN THE SCRIPT
# crontab -e
# */5 * * * * /root/script.sh >/dev/null 2>&1
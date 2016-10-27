#!/bin/sh
my_dir="$(dirname "$0")"
f=0
i=0
count=0
PATH_UBUNTU=/tmp/ubuntu_server
PATH_REDHAT=/tmp/redhat_server
## Username 
USER=username
## Password username 
PASSWORD=password
## Password account root
PASSROOT=rootpass
## Insert server list , one each line . If you want to exclude server insert hashtag in front of line
LISTA=$(cat list_server.txt | grep -v '#')
## You can chose to insert a single ip address for test the script 
#LISTA=xx.xxx.xxx.xxx 
FILE=$(ls -lrtha /tmp/ | grep server | awk '{ print $9 }')
sleep 5
## This file contain the server with ssh on port 22 closed , not linux or ssh in not standard port ( 22 )
## This cicle for is use to inizialize file. 
cat /dev/null > /tmp/connection_refused.txt
for i in $FILE
do
        echo "Delete file from the directory /tmp/$i....."
        rm -fr /tmp/$i/*
done
                for f in $LISTA
                do
 ## check if port 22 is open
				SSH_OPEN=$(nc -z $f 22)
                if [ $? -ne 0 ] ; then
				## if port is close the ip address is insert in this file
                        echo $f >> /tmp/connection_refused.txt
                else
                        echo $f
                        sleep 2
						## Get the name of OS from the files in directory /etc/*release
                        OS=$(sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $USER@$f 'cat /etc/*release')
						## Get the hostname of the host
                        HOSTNAME=$(sshpass -p "$PASSWORD" ssh -t -o StrictHostKeyChecking=no $USER@$f hostname)
                        echo $OS > /tmp/os.txt
								## If found ubuntu in release 
                                if grep -iF ubuntu /tmp/os.txt ; then
                                        ## "$my_dir/ubuntu_file_check.sh"
                                        # touch "$PATH_UBUNTU/$HOSTNAME"_at.txt
                                        echo "IP : " $f > "$PATH_UBUNTU"/"$HOSTNAME"_at.txt
                                        echo "Hostname : " $HOSTNAME >> "$PATH_UBUNTU"/"$HOSTNAME"_at.txt
                                        echo "       " >> "$PATH_UBUNTU"/"$HOSTNAME"_at.txt
                                        echo "------------" >> "$PATH_UBUNTU"/"$HOSTNAME"_at.txt
                                        APT=$(sshpass -p $PASSWORD ssh -t -o StrictHostKeyChecking=no $USER@$f "dpkg -l at" | sed '1,5d')
                                        echo $APT >> "$PATH_UBUNTU"/"$HOSTNAME"_at.txt
                                        echo "------------" >> "$PATH_UBUNTU"/"$HOSTNAME"_at.txt
										echo "       " >> "$PATH_UBUNTU"/"$HOSTNAME"_at.txt
                                else
								## Else all other distro that not ubuntu
                                        ## "$my_dir/redhat_file_check.sh"
                                        echo "IP : " $f >  "$PATH_REDHAT"/"$HOSTNAME"\_at.txt
                                        echo "Hostname : " $HOSTNAME >> "$PATH_REDHAT"/"$HOSTNAME"\_at.txt
                                        RPM=$(sshpass -p "$PASSWORD" ssh -t -o StrictHostKeyChecking=no $USER@$f "rpm -qa | grep ^at-[1-9].")
                                                if [ -z "$RPM" ] ; then
                                                echo "RPM AT INSTALLATO" >> "$PATH_REDHAT"/"$HOSTNAME"\_at.txt
                                                fi
                                        echo "       " >> "$PATH_REDHAT"/"$HOSTNAME"\_at.txt
                                        echo "------------" >> "$PATH_REDHAT"/"$HOSTNAME"\_at.txt
                                        YUM=$(sshpass -p $PASSWORD ssh -t -o StrictHostKeyChecking=no $USER@$f echo $PASSROOT | script -c "su - root -c /root/SCRIPT_AT/yum_history.sh")
                                        cat /tmp/yum_history.txt >> "$PATH_REDHAT"/"$HOSTNAME"\_at.txt
                                        echo "------------" >> "$PATH_REDHAT"/"$HOSTNAME"\_at.txt
                                        echo "       " >> "$PATH_REDHAT"/"$HOSTNAME"\_at.txt
                                        sleep 5
                                fi
                fi
count=$((count+1))
done
echo "Numero Server controllati : " $count
exit 0

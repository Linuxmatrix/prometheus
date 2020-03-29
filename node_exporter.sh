#!/bin/bash
if [ `id -u` -ne 0 ]; then
echo -e "\e[You should run this script as root user\e[0m"

 exit 4
fi
Print() {

        case $3 in
                B)
                        if [ "$1" = SL ]; then
                                echo -n -e "\e[34m$2\e[0m"
                        elif [ "$1" = NL ]; then
                                echo -e "\e[34m$2\e[0m"
                        else
                                echo -e "\e[34m$2\e[0m"
                        fi
                        ;;
                G)
                        if [ "$1" = SL ]; then
                                echo -n -e "\e[32m$2\e[0m"
                        elif [ "$1" = NL ]; then
                                echo -e "\e[32m$2\e[0m"
                        else
                                echo -e "\e[32m$2\e[0m"
                        fi
                        ;;
                Y)
                        if [ "$1" = SL ]; then
                                echo -n -e "\e[33m$2\e[0m"
                        elif [ "$1" = NL ]; then
                                echo -e "\e[33m$2\e[0m"
                        else
                                echo -e "\e[33m$2\e[0m"
                        fi
                        ;;
                R)
                        if [ "$1" = SL ]; then
                                echo -n -e "\e[31m$2\e[0m"
                        elif [ "$1" = NL ]; then
                                echo -e "\e[31m$2\e[0m"
                        else
                                echo -e "\e[31m$2\e[0m"
                        fi
                        ;;

                *)
                        if [ "$1" = SL ]; then
                                echo -n -e "$2\e[0m"
                        elif [ "$1" = NL ]; then
                                echo -e "$2\e[0m"
                        else
                                echo -e "$2\e[0m"
                        fi
                        ;;
                esac

}


Print "SL" "=>> Checking existing configuration if any.. " "B"

if [ -f /usr/local/bin/node_exporter ]; then
Print "NL" " node_exporter alredy exist " "G"
#Print "NL" "Skipping Installtion.. " "G"
#else
#        Print "SL" "No Present.. " "R"
#        Print "NL" "Beginning Installation.. " "G"
    exit 1
fi


Print "SL" "=>> Downloading the node_exporter.. " "B"
cd /opt && curl -LO   https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz

if [ $? -eq 0 ] ; then
        Print "NL" "Downloadin is Completed.." "G"
else
        Print "NL" "Failed to download " "R"
        exit 1
fi
Print "SL" "=>> Uncompress tar.gz Archive File and Moving the node export binary to /usr/local/bin.... " "B"
tar -xvf node_exporter-0.18.1.linux-amd64.tar.gz && mv node_exporter-0.18.1.linux-amd64/node_exporter /usr/local/bin/
if [ $? -eq 0 ] ; then
        Print "NL" "Uncompress and Moving binaries  successfully.." "G"
else
        Print "NL" " Failed to Uncompress and Moving binaries" "R"
        exit 1
fi

Print "SL" "=>> adding node_exporter user .. " "B"
useradd -rs /bin/false node_exporter
if [ $? -eq 0 ] ; then
                Print "NL" "user add successfully...." "G"
else
        Print "NL" "Failed to add user" "R"
        exit 1
fi
Print "SL" "=>> Creating  node_exporter service file under systemd. .. " "B"
cat <<EOD >> /etc/systemd/system/node_exporter.service

[Unit]
Description=Node Exporter
After=network.target
 
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
 
[Install]
WantedBy=multi-user.target
EOD
if [ $? -eq 0 ] ; then
                Print "NL" "Completed.." "G"
else
        Print "NL" "Failed" "R"

exit 1
fi
Print "SL" "=>> Reload the system daemon and star the node exporter service.. .. " "B"

systemctl daemon-reload && systemctl enable node_exporter &&systemctl start node_exporter

if [ $? -eq 0 ] ; then
                Print "NL" "system daemon is reload and node service is started.." "G"
else
        Print "NL" "Failed to reload and start service " "R"

exit 1
fi

Print "SL" "=>>  Allowing port 9100 and 9090 in firewall and Reloading  the firewalld   daemon a.. .. " "B"
firewall-cmd --add-port=9100/tcp --permanent && firewall-cmd --add-port=9090/tcp --permanent &&firewall-cmd --reload
if [ $? -eq 0 ] ; then
                Print "NL" "9100 and 9090 ports are added in firewall.." "G"
else
        Print "NL" "Failed to firewall " "R"

exit 1
fi


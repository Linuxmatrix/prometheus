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

if [ -f /usr/local/bin/promtool ]; then
Print "NL" " prometheus alredy exist " "G"
#Print "NL" "Skipping Installtion.. " "G"
#else
#        Print "SL" "No Present.. " "R"
#        Print "NL" "Beginning Installation.. " "G"
    exit 1
fi


Print "SL" "=>> Downloading the prometheus.. " "B"
cd /opt && curl -LO    https://github.com/prometheus/prometheus/releases/download/v2.8.1/prometheus-2.8.1.linux-amd64.tar.gz

if [ $? -eq 0 ] ; then
        Print "NL" "Downloadin is Completed.." "G"
else
        Print "NL" "Failed to download " "R"
        exit 1
fi
Print "SL" "=>> Uncompress tar.gz Archive File and Moving the promtool  binary to /usr/local/bin.... " "B"
tar -xvf prometheus-2.8.1.linux-amd64.tar.gz && mv prometheus-2.8.1.linux-amd64/promtool /usr/local/bin/ && mv prometheus-2.8.1.linux-amd64/prometheus   /usr/local/bin/
if [ $? -eq 0 ] ; then
        Print "NL" "Uncompress and Moving binaries  successfully.." "G"
else
        Print "NL" " Failed to Uncompress and Moving binaries" "R"
        exit 1
fi

Print "SL" "=>> adding promtool user .. " "B"
useradd -rs /bin/false promtool
if [ $? -eq 0 ] ; then
                Print "NL" "user add successfully...." "G"
else
        Print "NL" "Failed to add user" "R"
        exit 1
fi
Print "SL" "=>> Creating  prometheus directory under etc & var/lib   . .. " "B"
mkdir /etc/prometheus && mkdir /var/lib/prometheus && chown prometheus:prometheus /etc/prometheus && chown prometheus:prometheus /var/lib/prometheus
if [ $? -eq 0 ] ; then
                Print "NL" " created directory successfully...." "G"
else
        Print "NL" "Failed to create directory" "R"
        exit 1
fi
Print "SL" "=>> copying prometheus binary and lib files  . .. " "B"
cd prometheus-2.8.1.linux-amd64 && mv consoles/ console_libraries/ /etc/prometheus/ && mv prometheus.yml /etc/prometheus/
if [ $? -eq 0 ] ; then
                Print "NL" " copying prometheus binary and lib files is completed  successfully...." "G"
else
        Print "NL" "Failed to copy prometheus binaty and lib files " "R"
        exit 1
fi
Print "SL" "=>> Creating  prometheus.service file under systemd. .. " "B"
cat <<EOD >> /etc/systemd/system/prometheus.service

[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target

EOD
if [ $? -eq 0 ] ; then
                Print "NL" "Completed.." "G"
else
        Print "NL" "Failed" "R"

exit 1
fi
Print "SL" "=>> Reload the system daemon and star the prometheus service.. .. " "B"

systemctl daemon-reload && systemctl enable prometheus.service &&systemctl start prometheus.service

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


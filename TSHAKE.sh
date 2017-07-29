#!/bin/bash 
 COUNTER=0
while [  $COUNTER -lt 5 ]; do
kill $(pgrep telegram-cli)
function print_logo() {
	echo -e "\e[38;5;77m"   
echo -e "       CH > @TshAkETEAM            "
echo -e "       CH > @TshAkETEAM           "
echo -e "       CH > @TshAkETEAM    "
echo -e "       CH > @TshAkETEAM     "
echo -e "       CH > @TshAkETEAM          \e[38;5;88m"
echo -e ""
echo -e ""
echo -e ""
echo -e "\e[33m        _____    _        _    _    _____    Dev @lIMyIl\e[0m"
echo -e "\e[33m       |_   _|__| |__    / \  | | _| ____|   Dev @EMADOFFICAL\e[0m"
echo -e "\e[33m         | |/ __| '_ \  / _ \ | |/ /  _|     Dev @IX00XI\e[0m"
echo -e "\e[33m         | |\__ \ | | |/ ___ \|   <| |___    Dev @H_173\e[0m"
echo -e "\e[33m         |_||___/_| |_/_/   \_\_|\_\_____|   Dev @lIESIl\e[0m"
echo -e "\e[33m                                             Dev @h_k_a\e[0m"
}
sleep 2
if [ ! -f ./tg ]; then
echo -e ""
echo -e "\e[33m        _____    _        _    _    _____    Dev @lIMyIl"
echo -e "\e[33m       |_   _|__| |__    / \  | | _| ____|   Dev @EMADOFFICAL"
echo -e "\e[33m         | |/ __| '_ \  / _ \ | |/ /  _|     Dev @IX00XI"
echo -e "\e[33m         | |\__ \ | | |/ ___ \|   <| |___    Dev @H_173"
echo -e "\e[33m         |_||___/_| |_/_/   \_\_|\_\_____|   Dev @lIESIl"
echo -e "\e[33m                                             Dev @h_k_a"
    echo "tg لا يوجد ملف"
    echo "Run $0 install"
    exit 1
 fi
 sleep 2
  print_logo
   echo -e ""
echo -e ""
echo -e "        \e[38;5;300mOperation | Starting Bot"
echo -e "        Source | TSHAKE Version 28 March 2017"
echo -e "        CH  | @TshAkETEAM"
echo -e "        Dev | @lIMyIl"
echo -e "        Dev | @IX00XI"
echo -e "        Dev | @lIESIl"
echo -e "        Dev | @H_173"
echo -e "        Dev | @EMADOFFICAL"
echo -e "        Dev | @h_k_a"
echo -e "        \e[38;5;40m"

   ./tg -s ./TSHAKE.lua
sleep 3
done

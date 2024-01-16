#!/bin/bash
input_file="/mnt/c/Users/FORGE-15R/Desktop/test.csv"
npx mudslide@latest -V
agents=$(awk -F, '{
    first=$1
    last=$2
 
    gsub(/\+/, "", $3)
    phone_number = $3

    if (phone_number !~ /.*Phone.*/){
        printf "%s,%s,%s-", first, last, phone_number
    }
}' "$input_file")

IFS='-'
read -ra agents_list <<< "$agents"

echo "Agents list has been imported, there're ${#agents_list[@]} agents found"
echo "Attempting to send whatsapp messages to them....."

IFS=','
for agent in "${agents_list[@]}";
do
  read -ra agent_property <<< "$agent"
  npx mudslide@latest send "${agent_property[2]}" "Hi is this ${agent_property[0]} ?"
  if [[ $? == 1 ]]; then
    echo "seems like you might need to login to whatsapp through mudslide first"
    npx mudslide@latest login
    error=$?
    if [[ $error == 1 ]]; then
        echo "login failed. exiting...."
        exit $error
    else
      npx mudslide@latest send "${agent_property[2]}" "Hi is this ${agent_property[0]} ?"
    fi
  fi
  sleep 30
done

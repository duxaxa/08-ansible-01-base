#!/usr/bin/env bash

ansible_playbook_home="/vagrant/playbook"
ansible_password_file="/tmp/pass_file"


declare -A image

#https://stackoverflow.com/questions/14370133/is-there-a-way-to-create-key-value-pairs-in-bash-script

image["ubuntu"]="pycontribs/ubuntu"
image["centos7"]="pycontribs/centos:7"
image["fedora_container"]="pycontribs/fedora"


#**********************************************************#

function start_containers() {

  for container in ${!image[@]}
    do
      echo -e "--- Launching a docker container \"${container}\" from image \"${image[${container}]}\": ---"
      if docker run -d -t --rm --name ${container} ${image[${container}]} > /dev/null
        then
          echo -e "--- Done. ---\n"
        else
          echo -e "--- Error while starting docker container... Exit. ---\n"
          exit 1
      fi
    done
}


function stop_containers() {

    for container in ${!image[@]}
      do
        echo -e "--- Stoping a docker container \"${container}\" from image \"${image[${container}]}\": ---"
        if docker container stop ${container} > /dev/null
          then
            echo -e "--- Done. ---\n"
          else
            echo -e "--- Error while stoping docker container... Exit. ---\n"
            exit 1
        fi

      done
}


function play_ansible() {

    if cd ${ansible_playbook_home}
      then
        echo -e "\n--- Running ansible playbook: ---\n"
        ansible-playbook site.yml -i inventory/prod.yml --vault-password-file ${ansible_password_file}
      else
        echo -e "\n--- Error when changing directory... Exit. ---\n"
        stop_containers
        exit 1
    fi
}


#**********************************************************#

echo -e "\n--- Launching docker containers... : ---\n"
start_containers


echo -e "\n--- The following docker containers are running: ---\n"
docker ps


echo -e "\n--- Changing the directory with ansible playbook \"${ansible_playbook_home}\": ---\n"
play_ansible


echo -e "\n--- Stopping docker containers... : ---"
stop_containers

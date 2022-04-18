# Домашнее задание к занятию "08.01 Введение в Ansible"

## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.  
_ansible 2.12.4 установлен с помощью pip:_ `python3 -m pip install --user ansible`  
```shell
vagrant@test-netology:/vagrant/playbook$ ansible --version
ansible [core 2.12.4]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/vagrant/.local/lib/python3.8/site-packages/ansible
  ansible collection location = /home/vagrant/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/vagrant/.local/bin/ansible
  python version = 3.8.10 (default, Mar 15 2022, 12:22:08) [GCC 9.4.0]
  jinja version = 2.10.1
  libyaml = True
```

2. Создайте свой собственный публичный репозиторий на github с произвольным именем.  
_репозиторий: https://github.com/duxaxa/08-ansible-01-base_    

3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.  
_https://github.com/duxaxa/08-ansible-01-base/playbook_  

## Основная часть
#### 1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.  


<details>
  <summary>Значение `some_fact`: `12`</summary>
  
```shell
vagrant@test-netology:/vagrant/playbook$ ansible-playbook -i inventory/test.yml site.yml

PLAY [Print os facts] **************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [localhost]

TASK [Print OS] ********************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP *************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```  

</details>


#### 2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.  

Файл с переменными для группы хостов `all`: [group_vars/all/examp.yml](playbook/group_vars/all/examp.yml).  
Редактируем его содержание:  

```yaml
---
  some_fact: "all default fact"
```  


<details>
  <summary>Проверяем, что выводимое значение для переменной `some_fact` изменилось:</summary>
  
```shell
vagrant@test-netology:/vagrant/playbook$ ansible-playbook -i inventory/test.yml site.yml

PLAY [Print os facts] **************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [localhost]

TASK [Print OS] ********************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP *************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

</details>


#### 3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.  

<details>
  <summary>Подготовлены контейнеры:</summary>
  
```shell
vagrant@test-netology:/vagrant/playbook$ sudo docker run -d -t --rm --name ubuntu pycontribs/ubuntu

vagrant@test-netology:/vagrant/playbook$ sudo docker run -d -t --rm --name centos7 pycontribs/centos:7

vagrant@test-netology:/vagrant/playbook$ sudo docker ps

CONTAINER ID   IMAGE                 COMMAND       CREATED         STATUS         PORTS     NAMES
f4610c2d2b11   pycontribs/centos:7   "/bin/bash"   2 minutes ago   Up 2 minutes             centos7
d4bf389015aa   pycontribs/ubuntu     "/bin/bash"   3 minutes ago   Up 3 minutes             ubuntu
```

</details>

<details>
  <summary>Пользователя, запускающего playbook, нужно добавить в группу 'docker':</summary>
  
```shell
sudo usermod -a -G docker vagrant
```
иначе будет ошибка вида (не будет работать подключение к контейнерам docker):
```shell
vagrant@test-netology:/vagrant/playbook$ ansible-playbook site.yml -i inventory/prod.yml

PLAY [Print os facts] **************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
fatal: [centos7]: FAILED! => {"msg": "Docker version check (['/usr/bin/docker', 'version', '--format', \"'{{.Server.Version}}'\"]) failed: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get \"http://%2Fvar%2Frun%2Fdocker.sock/v1.24/version\": dial unix /var/run/docker.sock: connect: permission denied\n"}
fatal: [ubuntu]: FAILED! => {"msg": "Docker version check (['/usr/bin/docker', 'version', '--format', \"'{{.Server.Version}}'\"]) failed: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get \"http://%2Fvar%2Frun%2Fdocker.sock/v1.24/version\": dial unix /var/run/docker.sock: connect: permission denied\n"}

PLAY RECAP *************************************************************************************************************************************************
centos7                    : ok=0    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=0    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
  failed=0    skipped=0    rescued=0    ignored=0
```

</details>


#### 4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.  

Значение `some_fact` для контейнера centos7: `el`  
Значение `some_fact` для контейнера ubuntu: `deb`

<details>
  <summary>Результат работы playbook:</summary>
  
```shell
vagrant@test-netology:/vagrant/playbook$ ansible-playbook site.yml -i inventory/prod.yml

PLAY [Print os facts] **************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ********************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP *************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

</details>


#### 5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.  

Редактируем файлы:  
[group_vars/el/examp.yml](playbook/group_vars/el/examp.yml):  

```yaml
---
  some_fact: "el default fact"
```

Редактируем файлы:  
[group_vars/deb/examp.yml](playbook/group_vars/deb/examp.yml):  

```yaml
---
  some_fact: "deb default fact"
```

<details>
  <summary>Результат работы playbook на окружении 'test.yml':</summary>
  
```shell
vagrant@test-netology:/vagrant/playbook$ ansible-playbook site.yml -i inventory/test.yml

PLAY [Print os facts] ************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
ok: [localhost]

TASK [Print OS] ******************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ****************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP ***********************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

</details>


#### 6. Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.  

<details>
  <summary>Результат работы playbook на окружении 'prod.yml':</summary>
  
```shell
vagrant@test-netology:/vagrant/playbook$ ansible-playbook site.yml -i inventory/prod.yml

PLAY [Print os facts] ************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ******************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ****************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ***********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

</details>


<details>
  <summary>Результат работы playbook на окружении 'test.yml' и 'prod.yaml':</summary>
  
```shell
vagrant@test-netology:/vagrant/playbook$ ansible-playbook site.yml -i inventory/test.yml -i inventory/prod.yml

PLAY [Print os facts] ************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ******************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ****************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}

PLAY RECAP ***********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

</details>


#### 7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.  

```shell
vagrant@test-netology:/vagrant/playbook$ ansible-vault encrypt group_vars/deb/examp.yml
New Vault password:
Confirm New Vault password:
Encryption successful

vagrant@test-netology:/vagrant/playbook$ ansible-vault encrypt group_vars/el/examp.yml
New Vault password:
Confirm New Vault password:
Encryption successful
```


#### 8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.  

<details>
  <summary>Результат работы playbook:</summary>
  
```shell
vagrant@test-netology:/vagrant/playbook$ ansible-playbook site.yml -i inventory/prod.yml

PLAY [Print os facts] ************************************************************************************************************************************************************
ERROR! Attempting to decrypt but no vault secrets found

vagrant@test-netology:/vagrant/playbook$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-password
Vault password:

PLAY [Print os facts] ************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ******************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ****************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ***********************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

</details>


#### 9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.  

Будем использовать плагин `local`:  

<details>
  <summary>Использование ansible-doc:</summary>
  
```shell
vagrant@test-netology:/vagrant/playbook$ ansible-doc -F -t connection
[WARNING]: Collection ibm.qradar does not support Ansible version 2.12.4
[WARNING]: Collection frr.frr does not support Ansible version 2.12.4
[WARNING]: Collection splunk.es does not support Ansible version 2.12.4
ansible.netcommon.httpapi      /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/ansible/netcommon/plugins/connection/httpapi.py
ansible.netcommon.libssh       /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/ansible/netcommon/plugins/connection/libssh.py
ansible.netcommon.napalm       /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/ansible/netcommon/plugins/connection/napalm.py
ansible.netcommon.netconf      /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/ansible/netcommon/plugins/connection/netconf.py
ansible.netcommon.network_cli  /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/ansible/netcommon/plugins/connection/network_cli.py
ansible.netcommon.persistent   /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/ansible/netcommon/plugins/connection/persistent.py
community.aws.aws_ssm          /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/aws/plugins/connection/aws_ssm.py
community.docker.docker        /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/docker/plugins/connection/docker.py
community.docker.docker_api    /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/docker/plugins/connection/docker_api.py
community.docker.nsenter       /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/docker/plugins/connection/nsenter.py
community.general.chroot       /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/general/plugins/connection/chroot.py
community.general.funcd        /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/general/plugins/connection/funcd.py
community.general.iocage       /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/general/plugins/connection/iocage.py
community.general.jail         /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/general/plugins/connection/jail.py
community.general.lxc          /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/general/plugins/connection/lxc.py
community.general.lxd          /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/general/plugins/connection/lxd.py
community.general.qubes        /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/general/plugins/connection/qubes.py
community.general.saltstack    /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/general/plugins/connection/saltstack.py
community.general.zone         /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/general/plugins/connection/zone.py
community.libvirt.libvirt_lxc  /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/libvirt/plugins/connection/libvirt_lxc.py
community.libvirt.libvirt_qemu /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/libvirt/plugins/connection/libvirt_qemu.py
community.okd.oc               /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/okd/plugins/connection/oc.py
community.vmware.vmware_tools  /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/community/vmware/plugins/connection/vmware_tools.py
containers.podman.buildah      /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/containers/podman/plugins/connection/buildah.py
containers.podman.podman       /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/containers/podman/plugins/connection/podman.py
kubernetes.core.kubectl        /home/vagrant/.local/lib/python3.8/site-packages/ansible_collections/kubernetes/core/plugins/connection/kubectl.py
local                          /home/vagrant/.local/lib/python3.8/site-packages/ansible/plugins/connection/local.py
paramiko_ssh                   /home/vagrant/.local/lib/python3.8/site-packages/ansible/plugins/connection/paramiko_ssh.py
psrp                           /home/vagrant/.local/lib/python3.8/site-packages/ansible/plugins/connection/psrp.py
ssh                            /home/vagrant/.local/lib/python3.8/site-packages/ansible/plugins/connection/ssh.py
winrm                          /home/vagrant/.local/lib/python3.8/site-packages/ansible/plugins/connection/winrm.py


vagrant@test-netology:/vagrant/playbook$ ansible-doc -t connection local
> ANSIBLE.BUILTIN.LOCAL    (/home/vagrant/.local/lib/python3.8/site-packages/ansible/plugins/connection/local.py)

        This connection plugin allows ansible to execute tasks on the Ansible 'controller' instead of on a remote host.

ADDED IN: historical

OPTIONS (= is mandatory):

- pipelining
        Pipelining reduces the number of connection operations required to execute a module on the remote server, by executing many Ansible
        modules without actual file transfers.
        This can result in a very significant performance improvement when enabled.
        However this can conflict with privilege escalation (become). For example, when using sudo operations you must first disable
        'requiretty' in the sudoers file for the target hosts, which is why this feature is disabled by default.
        [Default: ANSIBLE_PIPELINING]
        set_via:
          env:
          - name: ANSIBLE_PIPELINING
          ini:
          - key: pipelining
            section: defaults
          vars:
          - name: ansible_pipelining

        type: boolean


NOTES:
      * The remote user is ignored, the user with which the ansible CLI was executed is used instead.


AUTHOR: ansible (@core)

NAME: local
```

</details>


#### 10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.  

Редактируем [inventory/prod.yml](playbook/inventory/prod.yml):  

```yaml
---
  el:
    hosts:
      centos7:
        ansible_connection: docker

  deb:
    hosts:
      ubuntu:
        ansible_connection: docker

  local:
    hosts:
      test-netology:
        ansible_connection: local
```


#### 11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.  

<details>
  <summary>Результат работы playbook на окружении 'prod.yaml':</summary>
  
```shell
vagrant@test-netology:/vagrant/playbook$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-password
Vault password:

PLAY [Print os facts] ************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************
ok: [test-netology]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ******************************************************************************************************************************************************************
ok: [test-netology] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ****************************************************************************************************************************************************************
ok: [test-netology] => {
    "msg": "all default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ***********************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
test-netology              : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

</details>


#### 12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.  

ДЗ: https://github.com/duxaxa/08-ansible-01-base/tree/main

---

## Необязательная часть

#### 1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.  

 
```shell

vagrant@test-netology:/vagrant/playbook$ ansible-vault decrypt group_vars/el/examp.yml
Vault password:
Decryption successful

vagrant@test-netology:/vagrant/playbook$ ansible-vault decrypt group_vars/deb/examp.yml
Vault password:
Decryption successful

vagrant@test-netology:/vagrant/playbook$ for f in $(ls group_vars/{el,deb}/examp.yml); do echo -e "$(cat ${f})\n"; done
---
  some_fact: "deb default fact"

---
  some_fact: "el default fact"

```

#### 2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.  

```shell
vagrant@test-netology:/vagrant/playbook$ ansible-vault encrypt_string PaSSw0rd
New Vault password:
Confirm New Vault password:
!vault |
          $ANSIBLE_VAULT;1.1;AES256
          36663838303134303032353337613763663737633066666365393564363461613831353833393539
          6264383561356233383033313536343333396338646331340a323861353631303436643132383361
          66376234396362303339653837323539383939336364383233313763656236386433666132616265
          3566646338326435320a373637633430383136353162623630383865363234613166393932386637
          3432
Encryption successful
```

Редактируем файл `group_vars/all/exmp.yml`:  
```yaml
---
  some_fact: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          36663838303134303032353337613763663737633066666365393564363461613831353833393539
          6264383561356233383033313536343333396338646331340a323861353631303436643132383361
          66376234396362303339653837323539383939336364383233313763656236386433666132616265
          3566646338326435320a373637633430383136353162623630383865363234613166393932386637
          3432
```

#### 3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.  

<details>
  <summary>Результат работы playbook:</summary>
  
```shell
vagrant@test-netology:/vagrant/playbook$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-password
Vault password:

PLAY [Print os facts] ************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
ok: [test-netology]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ******************************************************************************************************************************
ok: [test-netology] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ****************************************************************************************************************************
ok: [test-netology] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ***********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
test-netology              : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

</details>


#### 4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).  

Подготовим новый контейнер `fedora_container`
```shell
vagrant@test-netology:/vagrant/playbook$ docker run -d -t --rm --name fedora_container pycontribs/fedora
ad77e9b0c34ff049b0b3a7a0b51be73d1191fbe3046d432b745c5a645a66d96e

vagrant@test-netology:/vagrant/playbook$ docker ps
CONTAINER ID   IMAGE                 COMMAND       CREATED         STATUS         PORTS     NAMES
ad77e9b0c34f   pycontribs/fedora     "/bin/bash"   6 seconds ago   Up 4 seconds             fedora_container
f4610c2d2b11   pycontribs/centos:7   "/bin/bash"   15 hours ago    Up 15 hours              centos7
d4bf389015aa   pycontribs/ubuntu     "/bin/bash"   15 hours ago    Up 15 hours              ubuntu
```

Редактируем файл [inventory/prod.yml](playbook/inventory/prod.yml), добавляем группу `fedora`:  

```yaml
  fedora:
    hosts:
      fedora_container:
        ansible_connection: docker
```

Добавляем файл с переменными для группы `fedora` [group_vars/fedora/examp.yml](playbook/group_vars/fedora/examp.yml):  
```yaml
---
  some_fact: "Fedora default fact"
```

<details>
  <summary>Результат работы playbook на окружении 'prod.yaml' с новой группой 'fedora':</summary>
  
```shell
vagrant@test-netology:/vagrant/playbook$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-password
Vault password:

PLAY [Print os facts] ************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
ok: [test-netology]
ok: [fedora_container]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ******************************************************************************************************************************
ok: [test-netology] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [fedora_container] => {
    "msg": "Fedora"
}

TASK [Print fact] ****************************************************************************************************************************
ok: [test-netology] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [fedora_container] => {
    "msg": "Fedora default fact"
}

PLAY RECAP ***********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
fedora_container           : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
test-netology              : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

</details>


#### 5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.  

Скрипт [run_play_stop.sh](bash/run_play_stop.sh).

<details>
  <summary>Результат работы скрипта 'run_play_stop.sh':</summary>
  
```shell
vagrant@test-netology:/vagrant/playbook$ ./run_play_stop.sh

--- Launching docker containers... : ---

--- Launching a docker container "fedora_container" from image "pycontribs/fedora": ---
--- Done. ---

--- Launching a docker container "ubuntu" from image "pycontribs/ubuntu": ---
--- Done. ---

--- Launching a docker container "centos7" from image "pycontribs/centos:7": ---
--- Done. ---


--- The following docker containers are running: ---

CONTAINER ID   IMAGE                 COMMAND       CREATED         STATUS                  PORTS     NAMES
6c6475cd79b4   pycontribs/centos:7   "/bin/bash"   1 second ago    Up Less than a second             centos7
61b46e7fcb7a   pycontribs/ubuntu     "/bin/bash"   2 seconds ago   Up 1 second                       ubuntu
8a8ea108f873   pycontribs/fedora     "/bin/bash"   3 seconds ago   Up 1 second                       fedora_container

--- Changing the directory with ansible playbook "/vagrant/playbook": ---


--- Running ansible playbook: ---


PLAY [Print os facts] ************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
ok: [test-netology]
ok: [ubuntu]
ok: [fedora_container]
ok: [centos7]

TASK [Print OS] ******************************************************************************************************************************
ok: [test-netology] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [fedora_container] => {
    "msg": "Fedora"
}

TASK [Print fact] ****************************************************************************************************************************
ok: [test-netology] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [fedora_container] => {
    "msg": "Fedora default fact"
}

PLAY RECAP ***********************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
fedora_container           : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
test-netology              : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


--- Stopping docker containers... : ---
--- Stoping a docker container "fedora_container" from image "pycontribs/fedora": ---
--- Done. ---

--- Stoping a docker container "ubuntu" from image "pycontribs/ubuntu": ---
--- Done. ---

--- Stoping a docker container "centos7" from image "pycontribs/centos:7": ---
--- Done. ---


```

</details>



---
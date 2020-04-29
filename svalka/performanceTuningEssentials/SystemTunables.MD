Configuring System Tunables
=============

- Изменения /proc с помощью echo
- Изменения /proc с помощью sysctl
- Настройка опций модулей ядра

Теперь давайте поговорим о конфигурации системных параметров ядра. На английском языке эти параметры называют system tunables. Они живут в трех разных частях ОС Линукса. Мы посмотрим на proc значения, которые могут использоваться при помощи команды *echo*, которая установит новое значения в рантайме, но не персистентно. То есть после перезагрузки они будут сброшены. Далее, мы посмотрим, как делать изменения персистентными, использоватьсяользуя *sysctl*. Наконец, мы посмотрим на опции загрузки модулей.

- PID директории.
- Информационные файлы (cpuinfo, meminfo, partitions).
- sys - параметры ядра.


Итак самая основная часть Линукса, которую можно крутить и оптимизировать - этио файловая система *proc*. Она состоит из трех разных вещей. Есть PID файлы - это директории. Каждый процесс имеет свой PID. Окружения процесса управляется с помощью его директории PID. Более того именно из нее берутся данные для мониторинга состояния процесса. В директории PID процесс хранит свой текущий статус.
Далее идут информационные файлы. Это такие файлы, как cpuinfo, meminfo, partitions. Можно считать эти файлы файловыми интерфейсами, которые можно читать и получать информацию от ядра ОС в таком виде, что с ней можно работать. То есть понятном для человека.
sys каталог содержит параметры, которые разделены на несколько интерфейсов, которые содержат соответствующие параметры. Не все интерфейсы очень важны.

```
* fs - файловая система
* kernel - для параметров, которые относятся именно к ядру
* net - сеть
* vm - память
```

Итак, если к примеру мы пойдем в каталог vm, то сможем увидить параметры, которые относятся к управлению памятью. Давай-те поговорим о каком-нибудь одном. Пускай это будет параметр *swappiness*. Swappiness параметр определяет насколько охотно ядро будет свапать страницы RAM памяти при увелечинной на нее нагрузке. Он имеет значение от нуля до ста, где ноль обозначает, что ядро не будет свапать страницы совсем, а сто обозначает, что ядро начнет перемещать страницы на файловую систему сразу же. Теперь если я хочу изменить этот параметр, я могу просто сделать `echo` нового значения. Вот так это и делается. Значения параметра определяется содержимомым файла. Меняя содержимое файла, вы меняете поведение ядра сразу же. Но как только вы перезагрузите компьютер, все изменения пропадут.

````
echo > vm/swappiness
cat vm/swappiness
````

Если вы собираетесь оптимизировать производительность ОС Linux, то вы будете работать с `/proc/sys` файловой системой постоянно. В ней много различных параметров, которые можно поменять. В большинстве случаев у вас, я надеюсь, будет какой-то план, но все-равно нужно немного поупражняться, понаделать ошибок и выводов, чтобы выяснить, что работает эффективнее. И для этого лучше всего и проще всего использовать просто `echo`. Это дает максимум гибкости в применении параметров, которые вы хотите попробовать. А если это закончится большим фиаско, и все станет работать наоборот хуже - простая перезагрузка вернет все значения по умолчанию. Однако, если сервер перезагружать нельзя в данный момент, есть и другие способы сбросить свое творчество. Среди них `sysctl`.

`sysctl` стартует как служба, что видно при выполнении команды:

````
systemctl status systemd-sysctl
````

 `sysctl` - это служба, которая стартует довольно рано во время загрузки и считывает параметры, которые хранятся в `sysctl` конфигурационных файлых. Классически эти файлы хранятся в директориях:

````
/etc/sysctl.conf
/etc/sysctl.d        - это параметры настраиваемые пользователем
/usr/lib/sysctl.d    - это параметры настраиваемые производителем
````

Таким образом, если вы хотите знать,существуют ли какие-то дифолтные настройки параметров ядра на вашем компьютере, то надо начинать с диреткории `/usr/lib/sysctl.d`. Давайте с вами сейчас и посмотрим:

````
# ls -l /usr/lib/sysctl.d/
total 16
-rw-r--r--. 1 root root 1810 May 11  2019 10-default-yama-scope.conf
-rw-r--r--. 1 root root  524 Jul  1 18:29 50-coredump.conf
-rw-r--r--. 1 root root 1190 Jul  1 18:29 50-default.conf
-rw-r--r--. 1 root root  246 May 11  2019 50-libkcapi-optmem_max.conf

[root@postgres mtuktarov]# cat /usr/lib/sysctl.d/50-coredump.conf
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.

# See sysctl.d(5) for the description of the files in this directory,
# and systemd-coredump(8) and core(5) for the explanation of the
# setting below.

kernel.core_pattern=|/usr/lib/systemd/systemd-coredump %P %u %g %s %t %c %h %e
````

Видим, что есть несколько конфигурационных файлов? например, `50-coredump.conf`. Внутри лежит один параметр - `kernel.core_pattern`, этот параметр определяет поведения ядра при аварийной остановке процесса, а именно собирать ли дамп памяти или нет. Последние опции со знаком `%` отвечает за то, что будет в названии файла (pid, tid...).

Тут важно помнить, что название параметра это название относительного пути файла параметра, который относителен к директории `/proc/sys` и у которого заменены знаки слэша на точки. Таким образом параметр выше у нас живет по пути `/proc/sys/kernel/core_pattern`.

Таким же образом можно изменить любой необходимый параметр в `/proc/sys` и выставить постоянное значение.

Давайте посмотрим на другие файлы, может найдем что-нибудь интересное. И так у нас тут есть:
`10-default-yama-scope.conf`, `50-default.conf`, `50-libkcapi-optmem_max.conf`. Это все дифолтные системные параметры, и если вы хотите поменять что-то из них, то не делайте это в директории `/usr/lib/sysctl.d/`. Для этих целей существует директория `/etc/sysctl.d/`.

````
[root@postgres mtuktarov]# ls -l /etc/sysctl.d/
total 0
lrwxrwxrwx. 1 root root 14 Jul  1 18:29 99-sysctl.conf -> ../sysctl.conf
````

Как видим, у нас в этой директории лежит только один файл `99-sysctl.conf`, который по существу является символической ссылкой на `/etc/sysctl.conf`. Таким образом, вы можете просто добавлять сои параметры в конфигурационный файл `/etc/sysctl.conf`.

Давайте вспомним имя файла, который определяет `swappiness` параметр. Чтобы его поменять, нам нужно записать измеенения в файл `/proc/sys/vm/swappiness`. Мы можем, к примеру, изменить это значения на `40`:

````
echo 40 > /proc/sys/vm/swappiness
````

Как только я подтвердил, что в файле правлиьное значение, я переношу его в файл `sysctl.conf`. В этом случае у меня практически нет шанса ошибиться.
Также есть и другие способы манипулировать значениями параметра ядра. Например

- `sysctl -p` позволяет прочесть все параметры из файла конфигурации.

````
[root@postgres mtuktarov]# sysctl -p /usr/lib/sysctl.d/50-default.conf
kernel.sysrq = 16
kernel.core_uses_pid = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.promote_secondaries = 1
net.core.default_qdisc = fq_codel
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
````

- `sysctl -a` покажет все доступные параметры. Давайте посмотрим сколько ж их всего.

````
[root@postgres mtuktarov]# sysctl -a | wc -l
972
````
===========
```
#include<iostream>

int main(){
    int i=0;
    char* ptr =NULL;
    while(true){
      if ((ptr =(char*)malloc(1048576)) == NULL) {
       return 0;
      }
      std::cout << "Allocated "<< i+1 << "MB\n";
      i++;
    }
    std::cout << "Finished allocation";
    return 0;
}
```
```
g++ test.cpp
yum install gcc-c++
echo 2 > /proc/sys/vm/overcommit_memory
./a.out
echo 0 > /sys/fs/cgroup/memory/test/memory.swappiness

```

Изменение параметров модулей ядра
=============

- lsmod, чтобы получить список всех доступных модулей
- modinfo <module>, чтобы получить доступные параметры
- modprobe <module> key=value указать параметр в рантайме
- modprobe -r <module> выгрузить модуль
- /etc/modprobe.d/<modulename>.conf указать персистентный параметр

Еще один важный интерфейс для управления поведением ОС Linux - это параметры модулей ядра.

Итак, есть команда `modinfo`, которая может быть использована, чтобы найти список параметров, доступный для конкретного модуля. Как только необходимый параметр найден, то можно использовать команду `modprobe`, указав в которой название модуля, ключ параметра и необходимое значение, которое вы хотите присвоить. Таким способом можно загрузить модуль со специфичным параметром в ядро прямо в рантайме. Однако, так можно сделать далеко не всегда, потому что многие модули автоматически загружаются во время загрузки. Как только такой модуль загружен, его нельзя просто выгрузить и загрухить снова.

Если необходимо указать параметр персистентно, тогда его нужно добавить в файл `/etc/modprobe.d/modulename.conf`. Конвенция тут заключается в том что имя модуля и имя кофигурационного файла должны совпадать. В этом файле вы обозначаете опции, ключ=значение. Давайте посмотрим на примере.

Выполним команду `lsmod`, которая возвращает список всех доступных модулей. В качестве эксперимента мы возьмем модуль `cdrom`. Это модуль, который загружается для доступа к CD дискам. Если мы выполним `modinfo cdrom`, то получим информацию, которая доступна для нашего модуля, включая параметры. Мы видим что все из этих параметров имеют тип Boolean. Но это не всегда так. Модули ядра работают с разными типа данных. Давайте для примера выполним `modinfo e1000`. Здесь, например, часто импользуется array и int.

Тут надо отметить, что документации для параметров модулей обычно не понятны или их нет. Потому что пишут их разработчики ядра, их документация мало интересует.

А теперь давайте вернемся к сидирому. Итак у нас есть boolean параметр`lockdoor`. Давайте посмотрим, получится ли загрузить этот модуль из командной строки.

Обратите внимание, что никакого фидбэка мы не получили. И это так работает. Поэтому иногда понять, сработал ли параметр бывает крайне сложнло. Иногда эту информацию можно найти в `dmesg`. Но в нашем случае он просто пишет, что `cdrom` был выгружен. И даже не говорит нам о том, а был ли потом обратно загружен.
Порой можно найти полезную информацию в `/sys` файловой системе.
В ФС `/sys` есть `/sys/module/`. В `/sys/module/` вы найдете поддиректорию для каждого модуля. Там то и возможно что будет дополнительная информация в виде опций и параметров или еще чего.

````
# cat /sys/module/battery/parameters/cache_time
    1000
````

Нужно понимать, что и наоборот бывает - иногда информации найти очень тяжело и нам по-большому счету остается надеяться, что все модули были загружены верно.

После того как модуль настроен, нужно переходить к следующему шагу - идти в `/etc/modprobe.d/`. Давайте посмотрим что там лежит. Вот такой конфигурационный файл будет всегда при старте системы щагружать cdrom модуль вместе с указанным параметром.


````
#echo "options cdrom lockdoor=1" > /etc/modprobe.d/cdrom.conf
````


Working with Tuned

- tuned allows administrators to apply specific performance profiles
- This allows sysadmins to apply sysctl, /sys, /proc parameters
- The tuned service is installed by default in RHEL7
- The tuned service applies static profiles, but cron can be used to change to a different profile at a different time
- Dynamic tuning can be enabled by changing dynamic_tuning to 1 in /etc/tuned/tuned-main.conf
    * As a result, tuned will adjust system tuning every 10 seconds

If you have  a very busy server that is busy during office hours and doing nothing during night, then you might use cron to load a different Tuned profile during the off hours.

Tuned Profiles

- Different tuned profiles are available, you can list them using tuned-adm list
- Use tuned-adm active to show which profile is active
- Change the active profile with tuned-adm profile <name>
- Use tuned-adm recommend to let tuned recommend a profile for your system
    * The output of this command is determined by different system parameters, such as installed packages

tuned-adm recommend command is looking at some system parameters such as installed packages. Based on the installed packages, it's going to try to make a guess of what type of system you are using. Based on that it will recommend to use a specific profile.

When working with the generic profiles, you should realise that the big question in performance optimization, is either you are going to optimise for throughput or you are going to optimise for latency. You can't do both.

Generic profiles are applying some basic parameters that normally fit the needs of one of these specific workloads. By selecting one of the generic profiles, you will set different parameters in /proc/, but also in other parts of the system, like the /sys/ file system.


Managing Custom Tuned Profiles

Let's start with /usr/lib/tuned/ which contains the default configurations the major part of which contains a subdirectory.

# vim /usr/lib/tuned/desktop/tuned.conf

#
# tuned configuration
#

[main]
summary=Optimize for the desktop use-case       <— description
include=balanced                            <— including another profile

[sysctl]
kernel.sched_autogroup_enabled=1            <— parameter


# vim /usr/lib/tuned/balanced/tuned.conf

#
# tuned configuration
#

[main]
summary=General non-specialized tuned profile

[cpu]
governor=conservative
energy_perf_bias=normal

[audio]
timeout=10

[video]
radeon_powersave=dpm-balanced, auto

[disk]
# Comma separated list of devices, all devices if commented out.
# devices=sda

[scsi_host]
alpm=medium_power

Balanced profile has a couple of additional options. These additional options relate to figures that don't only come from the sysctl environment. It comes from tuned plug-ins which provide additional functionality. As you can see there is a CPU, audio, video, disk, scsi_host plug-ins, each of which contains very specific parameters.


Creating a custom tuned profile

# mkdir /etc/tuned/sander
# cp /usr/lib/tuned/throughput-performance/tuned.conf /etc/tuned/sander/

# vim /etc/tuned/sander/tuned.conf
                    add following sections:
[disk]              <— generic section that applies to all disks
readahead=4096

[my-disk]               <— created my own label "my-disk"
type=disk               <— identified the type as "disk" (identifies the tuned
                            plugin that should be used)
devices=sda         <— identified the device to which this applies
readahead=8192      <— the readahead that I want to use on sda

[script]                            <— for using a shell script script.sh in the profile
script=${i:PROFILE_DIR}/script.sh       which is located in the same directory


# systemctl restart tuned
# systemctl status tuned        <— to check that nothing has been logged
# tuned-adm list                <—  will return a sander profile
# tuned-adm profile sander      <—  will return a sander profile
# tuned-adm profile virtual-guest
# tail -f /var/log/messages
…
Jul 20 02:10:02 vagrant_centos7 root: TUNED_PROFILE: profile is set to Sander
Jul 20 02:10:27 vagrant_centos7 root: TUNED_PROFILE: profile Sander is off



The script itself contains a start and stop sections, which is going to explain what needs to loaded and unloaded when the profile is running. In our case we just add logger functions:

# vim /etc/tuned/sander/script.sh

#!/bin/sh

. /usr/lib/tuned/functions

start() {
        logger "TUNED_PROFILE: profile is set to Sander"
        return 0
}

stop() {
        logger "TUNED_PROFILE: profile Sander is off"
        return 0
}

process $@

Tuned man pages

tuned (8)               - dynamic adaptive system tuning daemon
tuned-adm (8)           - command-line tool for switching between different
                            tuning profiles
tuned-main.conf (5)     - tuned global configuation file
tuned-profiles (7)      - description of basic tuned profiles
tuned.conf (5)          - tuned profile definition

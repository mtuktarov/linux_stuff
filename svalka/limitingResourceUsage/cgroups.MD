Control Groups

Важной частью оптимизации доступа к ресуросам являются Control Groups.

Control Groups, also known as cgroups, have been around for quite some time. In the recent versions of Linux they have been integrated in a pretty nice way in systemd.

- Control Groups хранят ресурсы в контроллерах, которые представляют собой тип ресурса. Другими словами, вы можете определить группы доступных ресурсов, для того чтобы, например, у web-сервера был гарантированный набор ресурсов, и у базы данных был гарантированный набор ресурсов. Чтобы этого достичь cgroups работает с основными контроллерами
    ⁃   Основные контроллеры: cpu, memory, and blkio
    ⁃   Контроллеры имеют древовидную структуру, в которой разные веса или ограничения применены к каждой ветви.
        •   Каждая такая ветвь - это cgroup
        •   К cgroup могут быть прикреплены один или более процесов
    ⁃   Cgroups может быть применеа из командной строки или systemd
        •   На старых версиях Linux cgroups применяется с помощью команд cgconfig или cgred
        •   И в том и другом случае, cgroups настройки записываются в /sys/fs/cgroups директорию, которая содержит контроллеры.
        •   В директориях контроллеров лежат файлы, которые представляют собой разные настройки

Cgroups лежит в /sys/fs/cgroup, которая автоматически создается ядром. Здесь лежат контроллеры.
перечислить
Давайте посмотрим на cpu контроллер. Видим разные файлы, которые представляют собой настройки. Например, cpushares, о котором поговорим чуть позже.

Давайте пойдем в другой контроллер, например, memory. Здеь тоже куча всяких контроллеров.
Интересно, что контроллеры сделаны очень похоже на параметры ядра, о которых мы говорили ранее и которые лежат в /proc/sys за исключением того, что вы можете установить эти параметры для определенных групп процессов. А это позволяет управлять реурсами для разных процессов по-разному.

В качестве примера на то как работает параметр memory limit in bytes. Если мы посмотрим на его значение, то уввидим, что это довольно много байтов и это можно приравнять к бесконечности.

Давайте посмотрим как это будет работать, если мы хотим запустить процесс внутри определенной cgroup с ограниченным размером памяти.

- Надо создать поддиректорию, давайте назовем ее test.
```
mkdir /sys/fs/cgroup/memory/test
```
test автоматически унаследовала все файлы, которые существуют в контроллере. Значения все такие же. Эти файлы - это интерфейс к ядру, поэтому менять значения редактором, скажем vi, не получится. Нужно использовать echo.
- Давайте выставим лимит в 10.000 байтов. Как только мы это сделали, новое значение будет применено. Но почему 8192?
```
echo 10000 > memory.limit_in_bytes
[root@postgres test]# cat memory.limit_in_bytes
8192

```
- Файл tasks используется для помещения определенных процессов в группу. Это можно двумя способами:

1. Красивый и автоматический при помощи `cg control` `cg ret`
2. Не такой уж красивый, но работает - найди ID процесса и сделай echo в task.

Как только процесс попал в tasks, все ограничения, которые определены cgroup, применились на процесс.

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
echo 512M > /sys/fs/cgroup/memory/user.slice/memory.limit_in_bytes
g++ test.cpp
echo 0 > /sys/fs/cgroup/memory/test/memory.swappiness
yum install gcc-c++
./a.out
```


Итак мы познакомились с тем, как работают cgroups. Но такой метод управления ими не удобен. Мы сейчас изменеили только один параметр памяти, но вы есть и куча других, которые хочется поменять, чтобы сформировать среду ресурсов, доступных для процесса. Это и CPU, и memory, и Blkio. Чтобы сделать это более удобным способом, cgroups интегрированы в systemd.

### Интеграция cgroups с systemd

Давайте представим что вся операционная система поделена на кусочки. По умолчанию есть три кусочка:
    ⁃   system
    ⁃   user
    ⁃   machine
Эти куски являются главным разделением для выделения ресурсов. Давайте на примере cpushares посмотрим как это работает. cpushares - это один из параметров, который можно выставить, чтобы управлять распределеним ресурсов, и он может быть выставлен на уровне slice. Таким образом, вы можете сказать, например, что system кусок - это 1024, user кусок - 256, а кусок machine - 2048. Что значат эти цифры по отдельности? Абсолютно ничего. Но по отношению друг к другу они значение имеют. 1024 в 4 раза меньше 256, а 2048 в 2 раза больше 1024. Таким образом, если система будет полностью загружена, то machine slice получит большинство из имеющихся ресурсов, system - половину из тех, что доступны machine, а user - четверть их тех, что доступны system.

Внутри slices живут services. Пусть к примеру внутри System slice находятся службы S1, S2, S3. Все эти служюы попадают под ограничения, выставленные на уровне slice. Но на уровне самих служб вы тоже можете определить cpushares. Пускай у служба 1 получает 1024, служба 2 - 512, а служба 3 0 256. Вы можете сказать, что если это сложить, то получится больше 1024, которые выделены для slice system - как такое возможно? Но такое возможно, потому что slices имеют значения только по отношению друг другу на том уровне, на котором определены. Вне system slice они ничего не значат. В данном случае мы видим, что служба получит в два раза больше времени CPU, чем служба 2, а служба 2, в свою очередь, получит 2 раза больше CPU времени, которое доступно для службы 3.

Это то как cgroup настройки на главном уровне соотносятся с разными slices, а внутри slices, они соотносятся со службами. Между ними существует еще один уровень scope. Но он используется очень редко и о нем я говорить не буду.

Теперь, когда у нас появилось представление о cgroups, давайте посмотрим на детали того как это работает с systemd.

   ⁃   Systemd разделяет cpu, cpuacct, blkio и memory на разные slices:
    •   system для процессов и демонов
    •   machine для виртуальных машин
    •   user для сессий пользователей
    ⁃   в системе с systemd, system-enabled cgroups могут быть выключены, и вы сможете использовать cgconfig and cgred. Смотри systemd-system.conf для инструкций, как это сделать. Не забудь после этого пересобрать initramfs, чтобы изменения вступили в силу.

Systemd разделяет cpu, cpuacct, blkio и memory на разные slices, которые создают различные области в ОС. system для процессов и демонов. machine для виртуальных машин. Если вы не пользуетесь виртуализацией на своем компьютере, то про machine slice можете забыть. user slice для сессий пользователей. В системе с systemd, system-enabled cgroups могут быть выключены, и вы сможете использовать cgconfig and cgred. Смотри systemd-system.conf для инструкций, как это сделать. Не забудь после этого пересобрать initramfs, чтобы изменения вступили в силу.

    ⁃   Администратор может создавать свои собственные slices. Также, slices можно создавать внутри slicesб используя при этом имена parent-child.slice. Это и позволяет создать строго разделенное пространство имен.

    ⁃   Child slices унаследуют настройки parent slices
    ⁃   Не забудьте включить CPU, Memory и I/O accounting, чтобы видеть как они используются внутри slice.

Enabling Accounting

    ⁃   Включить accounting в [Service] секции unit файла
        •   CPUAccounting=true
        •   MemoryAccounting=true
        •   BlockIOAccounting=true
    ⁃   Лучше: включить в /etc/systemd/system.conf - применится на все в systemd
    ⁃   Используй drop-in файлы, чтобы сделать исключения
        •   например SSH сервис будет использовать drop-in /etc/systemd/system/sshd.service.d/*.conf
    ⁃   man 5 systemd.resource-control для дальнейшего ознакомления
        •   CPUShares=512
        •   MemoryLimit=512M
        •   BlockIO*=


Таким образом, включение accounting - это первое обязательное условие, которое подразумевает 3 настройки:
CPUAccounting=true
MemoryAccounting=true
BlockIOAccounting=true

Это может быть сделано на определенном systemd unit, а лучше в etc/systemd/system.conf. В таком случае настройки применятся на все компоненты systemd окружения. Чтобы переопределить для каких-то unit'ов, нужно использовать systemd drop-in файлы, которые мы использовали ранее. Для получения представления всего тоого, что может быть сделано при помощи systemd управления ресурсами, можно обратиться к man странице systemd.resource-control.
А теперь, когда появилось некоторое понимание, давайте перейдем к командной строке.

### Управление systemd groups

Чтобы показать, как cgroups работает я создал 2 systemd service файла stress1.service and stress2.service в /etc/systemd/system:

bash-4.2# cat /etc/systemd/system/stress1.service
[Unit]
Description=Create some stress

[Service]
Type=simple
ExecStart=/usr/bin/dd if=/dev/zero of=/dev/null

Цель этих скриптов в том, чтобы полностью загрузить ЦПУ, однако, чтобы сделать это демо действительно показательным надо бы использовать одно ядро. У меня 2 ядра. Но это можно легко починить
```
echo 0 > /sys/devices/system/cpu/cpu1/online
```
После этого мы стартуем наши службы
after that we start the services:
```
systemctl start stress1 stress2
```

Откроем top - процессы занимают по половине свободного времени ЦПУ:

```
PID         USER    PR  NI      VIRT            RES SHR     S   %CPU    %MEM    TIME+ COMMAND
24855   root        20      0   107992  612 516 R   50.5        0.1         0:47.17 dd
24863   root        20      0   107992  612 516 R   49.8    0.1         0:45.55 dd
```

Теперь под обычем юзером давайте запустим что-нибудь такое, что длится бесконечно и пытается получить все время ядра:

```
while true; do true; done &
```

На данный момент 3 процесса пытаются заполучить время ЦПУ:
```
PID         USER        PR      NI      VIRT        RES SHR S   %CPU    %MEM    TIME+ COMMAND
25429   user        20      0   115432    552   168 R   33.7    0.1         0:22.74 bash
24855   root        20      0   107992    612   516 R   33.3    0.1         5:21.67 dd
24863   root    20      0   107992    612   516 R   33.3    0.1         5:20.07 dd
```

Эти результаты могут удивить, потому что по определению user slince должен получить половину времени.

    ⁃   Set the below configuration in /etc/systemd/system.conf
    -bash-4.2# vim /etc/systemd/system.conf
    DefaultCPUAccounting=yes
    DefaultBlockIOAccounting=yes
    DefaultMemoryAccounting=yes

    ⁃   Reboot the server and disable one of the kernels again
    ⁃   Top will now show:

```
 PID        USER    PR  NI      VIRT        RES SHR S   %CPU    %MEM    TIME+COMMAND
 1479   mtuktar+    20      0   115568  652 176     R   57.0    0.1         1:52.64 bash
 1525   root        20      0   107992    608   516     R   21.5    0.1         0:46.68 dd
 1518   root        20      0   107992    612   516     R   21.2    0.1         0:48.09 dd
```
So, after enabling accounting, slices are becoming effective. All of the user processes together have a claim that is similar to all of the system processes together as well.

However, this can lead to pretty undesirable situations because normally on a server you don't want a user to get this specific claim to the available processes and that's why you want to define your CPUShares. Let's play with the CPUShares a little bit now.

    0.  Stop stress services and change their configuration:
    bash-4.2# vim /etc/systemd/system/stress1.service
    [Service]
    Type=simple
    ExecStart=/usr/bin/dd if=/dev/zero of=/dev/null
    CPUShares=512

    bash-4.2# vim /etc/systemd/system/stress1.service
    [Service]
    Type=simple
    ExecStart=/usr/bin/dd if=/dev/zero of=/dev/null
    CPUShares=1024
    0.  Launch the services
    0.  Check the top

```
PID         USER    PR  NI      VIRT        RES SHR S   %CPU    %MEM     TIME+ COMMAND
1479.     mtuktar+  20   0      115568  652 176 R   60.8    0.1         11:16.57    bash
1594    root        20   0      107992  608 516 R   26.2    0.1         0:16.84     dd
1601        root        20   0      107992  608 516 R   13.0    0.1         0:08.12     dd
```
    0.  now we kill user process and system.slice shares 100% of CPU cycles
```
PID     USER        PR      NI      VIRT        RES SHR     S   %CPU    %MEM        TIME+ COMMAND
2129        root        20      0   107992      608 516     R   66.8    0.1         4:28.12 dd
2161        root        20      0   107992      612 516     R   33.2    0.1         2:07.46 dd
```

```
systemctl stop stress1 stress2
```
```
man systemd.resource-control
```l
3.5 Managing Slices

Monitoring cgroups

    ⁃   Use systemd-cgtop to show a top-like overview of cgroups
    ⁃   Use systemd-cals for a complete list of all slices, cgroups and their associated processes

Putting Commands into a Slice

    ⁃   To put a command into a slice, you can use the systemd-run command with the --slice= option:
    •   systemd-run --slice=example.slice sleep 10d
    •   show with systemd-cgls /example.slice/<servicename>
    •   If the --slice option is not used, commands started with systemd-run will be put into the system.slice3.4 Managing Systemd cgroups

Using Custom Slices

    ⁃   Put a service in a custom slice using Slice=my.slice; if the slice doesn't yet exist it will be created when the service is started
    ⁃   You can also pre-create custom slices by creating a *.slice file in /etc/systemd/system. Put the tunables in the [Slice] section
    ⁃   To make a slice a child of another slice, give it the name <parent>-<child>.slice; it will inherit all settings of the parent slice
    ⁃   Note that the slice will only be created once the first process is stated within

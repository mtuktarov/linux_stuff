### 1. Написать Dockerfile для сборки образа, который будет запускать контейнер с django приложением, доуступным по ссылке: https://github.com/mtuktarov/linux_goodies/tree/master/docker/django-test-app. Для запуска приложения использовать команду `python manage.py runserver 0.0.0.0:8000`, где `manage.py` - это файл из репозитория.
### 2. Зная, что в этом приложении django хранит базу в файле  `db.sqlite3`, нужно избавиться от ошибки, которая появится при старте:
```
You have 15 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): admin, auth, contenttypes, polls, sessions.
Run 'python manage.py migrate' to apply them.
```
### 3. Запустить контейнер так, чтобы приложение было доступным из браузера Ubuntu, используя Ubuntu hostname. Создать аккаунт на Dockerhub и залить туда образ. Указать имя образа.

### 4. Нужно запустить php приложение, которое находится по ссылке: https://github.com/mtuktarov/linux_goodies/tree/master/docker/php
так, чтобы его основной функционал стал доступен - а именно добавление и удаление врачей из базы. Всего три контейнера - mysql, php:fpm и nginx.
**hospital_db.sql** - этот файл содержит `sql` инстуркции, которые должны применяться при старте базы данных.

### 5. Самостоятельно разобраться с настройкой uwsgi и запустить flaskapp(https://github.com/mtuktarov/linux_goodies/tree/master/docker/python/uwsgi), либо djangoapp (https://github.com/mtuktarov/linux_goodies/tree/master/docker/django-test-app), используя uwsgi в конейнере за nginx'ом, заупущенным также в контейнере. Пример настройки uwsgi можно найти здесь https://github.com/mtuktarov/mtuktarov.ru

### 6. Разработчик плохо задокументировал, как его приложение из образа `mtuktarov/overwrite_cmd_exercise` работает. Однако при запуске образа по дифолту он показывает немного справочной информации. Нужно создать `Dockerfile`, который начинается с `FROM mtuktarov/overwrite_cmd_exercise` и добавить `CMD` инструкцию в Dockerfile таким образом, чтобы при запуске приложение эмулировало работу часов. Когда будете собирать образ, сделайте ему тег `“docker-clock`. Пришлите Dockerfile и команду запуска вашего приложения.

### 7. Напишите Dockerfile для создания нового приложения на основе ubuntu:20.04. Создайте скрипт-файл с содержимым `echo "Input website:"; read website; echo "Searching.."; sleep 1; curl http://$website;`. Переместите этот файл в образ и запускайте при помощи `CMD`. Создайте образ с тегом `curler`. Запустите команду `docker run [options] curler (с правильными флагами)` и введите `mtuktarov.ru` после `Input website:` запроса. Пришлите Ваш Dockerfile и результат работы приложения.

### 8. Образ `mtuktarov/first_volume_exercise` создает лог в `/usr/app/logs.txt`. Запустите контейнер таким образом, чтобы лог создался на хостовой файловой системе. Напишите, какие команды были для этого использованы.

### 9. Образ `mtuktarov/ports_exercise` запустит Web сервис, который слушает на порту `80`. Используйте `-p` флаг, чтобы получить доступ к содержимому Web страницы. Напишите, какие команды были для этого использованы.

### 10. Хороший разработчик создает хороший READMEs, которые могут быть использованы для создания Dockerfiles. Склонируй, форкни или загрузи директорию `docker/frontend-example-docker` из репозитория `https://github.com/mtuktarov/linux_goodies.git`. Создайте Dockerfile для этого проекта и напишите такую команду, которая запустит проект в docker контейнере с перенаправленным портом `5000`. Поэтому после запуска контейнера и открытия вкладки `http://localhost:5000` будет отображаться сообщение об успехе: `Congratulations! You configured your ports correctly!` Напишите ваш Dockerfile и какие команды были для этого использованы.

### 11. Склонируйте, форкни или загрузи директорию `docker/backend-example-docker` из репозитория `https://github.com/mtuktarov/linux_goodies.git`. Создайте Dockerfile для этого проекта и напишите такую команду, которая запустит проект в docker контейнере с перенаправленным портом `8000`. Поэтому после запуска контейнера и открытия вкладки `http://localhost:8000`, будет генерироваться сообщение в `logs.txt`, который находится в рабочей директории. Создайте volume для `logs.txt`, чтобы после завершения работы приложения, лог не был утрачен, а при рестарте - приложение продолжало писать в тот же файл. Напишите ваш Dockerfile и какие команды были для этого использованы.

### 11. Запустите оба приложения `frontend-example` and `backend-example` с правильными перенаправленными портами и добавьте инструкцию `ENV` в Dockerfile с необходимой информацией, как написано в READMEs:
https://github.com/mtuktarov/linux_goodies/blob/master/docker/frontend-example-docker/README.md
https://github.com/mtuktarov/linux_goodies/blob/master/docker/backend-example-docker/README.md

Backend конфигурация будет игнорироваться до тех пор пока frontend не отправит `_backend_url_/ping` запрос по нажатию кнопки `Press to Test`. Конфигурация станет готова, когда эта кнопка для задания 1.12 станет зеленой. Менять код frontend и backend проектов не нужно. Напишите ваш Dockerfile и какие команды были для этого использованы.

More: https://devopswithdocker.com/

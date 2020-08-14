### 1. Написать Dockerfile для сборки образа, который будет запускать контейнер с django приложением, доуступным по ссылке: https://github.com/mtuktarov/linux_goodies/tree/master/docker/django-test-app. Для запуска приложения использовать команду `python manage.py runserver 0.0.0.0:8000`, где `manage.py` - это файл из репозитория.
### 2. Зная, что в этом приложении django хранит базу в файле  `db.sqlite3`, нужно избавиться от ошибки, которая появится при старте:
```
You have 15 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): admin, auth, contenttypes, polls, sessions.
Run 'python manage.py migrate' to apply them.
```
### 3. Запустить контейнер так, чтобы приложение было доступным из браузера Ubuntu, используя Ubuntu hostname.
### 4. Создать аккаунт на Dockerhub и залить туда образ. Указать имя образа.


### 5. Нужно запустить php приложение, которое находится по ссылке: https://github.com/mtuktarov/linux_goodies/tree/master/docker/php
так, чтобы его основной функционал стал доступен - а именно добавление и удаление врачей из базы. Всего три контейнера - mysql, php:fpm и nginx.
**hospital_db.sql** - этот файл содержит `sql` инстуркции, которые должны применяться при старте базы данных.

### 6. Самостоятельно разобраться с настройкой uwsgi и запустить flaskapp(https://github.com/mtuktarov/linux_goodies/tree/master/docker/python/uwsgi), либо djangoapp (https://github.com/mtuktarov/linux_goodies/tree/master/docker/django-test-app), используя uwsgi в конейнере за nginx'ом, заупущенным также в контейнере. Пример настройки uwsgi можно найти здесь https://github.com/mtuktarov/mtuktarov.ru

### 1. Написать регулярное выражение, которое проверяет является ли строка валидным IP-адрес. Например, 192.168.1.1 подойдет, а 256.300.1.1 — нет.
### 2. Написать регулярное выражение, которое проверяет, является ли указанный файл картинкой. Картинкой считаем файлы, названия которых оканчиваются на `.jpg`, `.png` или `.gif`.
### 3. Написать регулярное выражение для проверки, ведет ли ссылка URL на некоторый файл, и это действительно ссылка на картинку. Картинкой считаем файлы, названия которых оканчиваются на `.jpg`, `.png` или `.gif`.
### 4. *Написать регулярное выражение, которое проверяет, является ли строка валидным «белым» IP-адресом (5.255.255.5 подойдет, а 172.16.0.1 — нет).
Будем считать, что белые адреса не принадлежат сетям:
0.0.0.0/8
127.0.0.1/8
169.254.0.0/16
172.16.0.0/12
192.168.0.0/16
10.0.0.0/8
255.255.255.255/32

### 5. *Написать регулярное выражение, которое проверяет, что файл в URL (например, https://site.ru/folder/download/test.docx) не является картинкой. Картинкой считаем файлы, названия которых оканчиваются на `.jpg`, `.png` или `.gif`.

### 6. У вас есть лог `log.txt`, который содержит запросы на загрузку файлов. Один запрос на одной строке. IP адрес во втором столбце. Имя файла может быть в любом столбце. Столбцы разделены одним или несколькими пробелами. Нужно написать выражение в одну строку, которое выведет список всех IP адресов за исключением loopback интерфейсов, с которых запрашивался файл /closeio.html, а также количество таких запросов для каждого адреса. Результат должен быть отсортирован по этому значению. Можно использовать стандартные тулы, которые запустятся на большинстве UNIX системах.

### 7. нужно в строке найти номер телефона, который может иметь вид
81234567890
+71234567890
1234567890
8-123-456-78-90
123-456-78-90
+7-123-456-78-90
123-456-78-90
+7(123)456-78-90
8(123)456-78-90
(123)456-78-90
8(123)456-7890
+7(123)456-7890
(123)456-7890
8 123 456 78 90
123 456 78 90
+7 123 456 78 90
123 456 78 90
+7(123)456 78 90
8(123)456 78 90
(123)456 78 90
8(123)456 7890
+7(123)456 7890
(123)456 7890
и заменить на один тип +7(123)4561234. Остальную часть строки, которая телефоном не является оставить без изменений. Написать набор тестовых данных для проверки

Y0dWeWJDQXRjQ0F0WlNBbmN5OWNLejljWkQ5Y0lEOWNMVDljS0Q4b1hHUjdNMzBwWENBL1hDay9YQzAvS0Z4a2V6TjlLVndnDQpQMXd0UHloY1pIc3lmU2xjSUQ5Y0xUOG9YR1I3TW4wcEwxd2dLemNvWERFcFhESmNNMXcwTDJkdEp5Qm1hV3hsYm1GdFpRbz0NCg==

Примечание. Задания с 4 по 6  даны для тех, кому двух упражнений показалось недостаточно.

Входные данные для тестов: https://github.com/mtuktarov/linux_stuff/blob/master/test_data.txt


```0.0.0.0/8```
маска 8 бит - или ```255.0.0.0```. такая запись означает, что первые 8 бит содержат в себе адрес сети, а остальные - возможные адреса хостов. Первые 8 бит в IP адресе - это первый октет - ну здесь это первый нолик. Остальные 3 байта - это всевозможные адреса хостов. То есть в эту сеть входят адреса ```0.0.0.0-0.255.255.255``` (причем первый адрес называют адресом сети, а последний -- ее бродкастом (если отправить что-то на адрес бродкаста, то получат все участники сети). то есть хосты могут быть ```0.0.0.1-0.255.255.254``` ).
Для нас это значит что мы фильтруем адреса из диапозона ```0.0.0.0-0.255.255.255``` - они НЕ публичные (белые).

```127.0.0.1/8``` - тут правильно будет написать нуль на конце. Та же история.
```169.254.0.0/16``` - тут маска ```16``` или ```255.255.0.0``` - делит сеть и хосты пополам - ```169.254.0.0-169.254.255.255```

Вот этот разберем. Может кому полезно будет. Маска ```12``` или ```255.240.0.0```.
```172.16.0.0/12``` - тут 12 бит левых бит сеть, 20 правых - хосты в этой сети. В целом Маска это всегда слева единицы, а справа нули. Единицы - определяют сеть. Нули - количество хостов. Если адрес записать в бинарном виде и наложить на него маску - применить логическую операцию конъюнкции – "И":
```11000000.00010000.00000000.00000000
11111111.11110000.00000000.00000000
-----------------------------------
11000000.00010000.00000000.00000000```
то получим фиксированный адрес сети под единицами маски и всевозможные значения хостов, где маска равна нулю: ```11000000.00010000.00000000.00000000-11000000.00011111.11111111.11111111```

Если перевести в десятичный вид - ```172.16.0.0-172.31.255.255```. Это непубличные (приватные адреса).
```192.168.0.0/16```
```10.0.0.0/8```
```255.255.255.255/32``` - 32 бита обозначают сеть. 0 - хосты. /32 — это подсеть, состоящая из одного хоста, то есть никакая и не сеть, в сущности. Только один адрес - ```255.255.255.255```

Кому интересно весь список непубличных адресов есть тут: https://tools.ietf.org/html/rfc5735#section-4

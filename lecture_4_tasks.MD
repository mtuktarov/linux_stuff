1. Написать регулярное выражение, которое проверяет валидный IP-адрес. Например, `192.168.1.1` подойдет, а `256.300.1.1` — нет.

2.
    - Написать регулярное выражение, которое проверяет, является ли указанный файлом нужного типа (на выбор `.com,.exe` или `.jpg,.png,.gif` и т.д.):

    - Написать регулярное выражение для проверки, ведет ли ссылка URL на некоторый файл, и это действительно ссылка на картинку (например, `http://site.com/folder/1.png`), а не на любой файл.

3. Написать регулярное выражение, которое проверяет, является выведенное значение «белым» IP-адресом (`5.255.255.5` подойдет, а `172.16.0.1` — нет).

4. *Написать регулярное выражение, которое проверяет, что файл в URL (например, `https://site.ru/folder/download/test.docx`) не обладает неким расширением (например .exe не пройдет, или .sh — не пройдет. Выбор списка исключенных расширений за вами).

5. *В test_data.txt есть лог, который содержит запросы на загрузку файлов. Один запрос на одной строке. IP адрес во втором столбце. Имя файла может быть в любом столбце. Столбцы разделены одним или несколькими пробелами. Нужно написать выражение в одну строку, которое выведет список всех IP адресов за исключением loopback интерфейсов, с которых запрашивался файл /closeio.html, а также количество таких запросов для каждого адреса. Результат должен быть отсортирован по этому значению. Можно использовать стандартные тулы, которые запустятся на большинстве UNIX системах.

```
#=====================
echo "Below will show addresses that exp MUST match but does not match (no output means no errors)"
diff --new-line-format="" --unchanged-line-format="" <(head -121 test_data.txt | grep -v addresses) <(grep -P $(de $exp_one) test_data.txt)

echo "Below will show addresses that exp must NOT match but matches (no output means no errors)"
diff --new-line-format="" <(head -143 test_data.txt | tail -21 | grep -P $(de $exp_one)) <(head -143 test_data.txt | tail -21)

#=====================
echo "expression below must return 26: $(grep -E $(de $exp_two_1) test_data.txt | wc -l)"
echo "expression below must return 11: $(grep -E $(de $exp_two_2) test_data.txt | wc -l)"
echo "expression below must return 37: $(grep -E $(de $exp_two_3) test_data.txt | wc -l)"

echo "expression below must return 15: $(grep -E $(de $exp_two_2_1) test_data.txt | wc -l)"
echo "expression below must return 34: $(grep -E $(de $exp_two_2_2) test_data.txt | wc -l)"
echo "expression below must return 49: $(grep -E $(de $exp_two_2_3) test_data.txt | wc -l)"


#=====================
echo "Below will show addresses that exp MUST match but does not match (no output means no errors)"
diff --new-line-format="" --unchanged-line-format="" <(head -n 27 test_data.txt | grep -v addresses) <(grep -P $(de $exp_three) test_data.txt)

echo "Below will show addresses that exp must NOT match but matches (no output means no errors)"
diff --new-line-format="" <(head -144 test_data.txt | tail -117 | grep -v addresses | grep -P $exp_three) <(head -144 test_data.txt | tail -117 | grep -v addresses)

#=====================
grep -P $(de $exp_two_2_3) test_data.txt > tmp.txt
grep -P $(de $exp_four_1) test_data.txt >> tmp.txt
sort tmp.txt > regex.txt
echo "If here is an output - you have errors. part 1"
diff --new-line-format="" --unchanged-line-format="" <(grep -P $(de $exp_four_2) test_data.txt | sort) regex.txt
echo "If here is an output - you have errors. part 2"
diff --new-line-format="" --unchanged-line-format="" regex.txt <(grep -P $(de $exp_four_2) test_data.txt | sort)

#=====================
eval $(de "$exp_five")
```

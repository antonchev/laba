# Тестовое задание Devops

Задание:
* Развернуть 4 ВМ:
    * Debian 10, 1 ядро, 1.5ГБ RAM, 10ГБ диск. 
        * Софт: keepalived, nginx, php-fpm
    * 2x Centos 7, 1 ядро, 1.5ГБ RAM, 10ГБ диск
        * Софт: mysql
* На всех машинах настроить вход по ssh только по ключу.
* На ВМ с mysql настроить Master-Slave репликацию.
* Настроить keepalived на использование vIP 172.40.0.10/23
* Настроить корректную работу nginx + php-fpm
* Создать статическую страницу Hello World! (html файл)
* Создать динамическую страницу Hello World! <time> (php файл)
    * Вместо <time> должно выводиться текущее время
* Проверить, что обе страницы доступны по vIP, даже если один из серверов отключен.
* Написать php скрипт реализующий два метода: set и get
* Пример: 
    * http://172.40.0.10/script.php?set=123 
    * http://172.40.0.10/script.php?get (возвращает ранее указанное значение)
* Для хранения значения должна использоваться ранее настроенная mysql.

Зависимости:
 ```shell 
 Должен быть установлен Vagrant Hashicorp
  ```
Реализация:
```shell
vagrant up
```

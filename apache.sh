#!/bin/bash
#Autor Juri Kononov
#Apache2 создание сайта в дериктории /var/www
export LC_ALL=C
#Пользователь имеет права root?
if [ $UID -ne 0 ] #UID у пользователя root == 0, если нет то он не руут
then
    echo "У этого пользователя нету прав для запуска скрипта. Зайдите под пользователем root"
    exit 1 #выход с ошибкой
fi

#проверка вводимых параметров
SITE=$1
if [ $# -ne 1 ] #если количество введенных параметров не равно 1
then
   echo "Параметры запуска не правельные. Запустите скрипт по примеру: ./apache.sh www.mingisait.ee"
   exit 1
fi
    echo "Создаем сайт с именем $SITE !"

#проверяем установлен ли апач на сервере
dpkg -s apache2 | grep "Status: install ok installed" #запрашиваем версию пакета, выполняем поиск по словосочетанию "Status: install ok installed"
if [ $? -eq 0 ] #если команда поиска возвращает статус код 0, значет поиск удолсяи апач установлен
then 
    echo "Apache2 уже установлен"
else
    echo "Apache2 еще не установлен"
    apt-get update && apt-get install apache2 #Устанавливаем апач
fi

#создаем запись в файле хостс и создаем каталог для файлов сайта
echo "127.0.0.1 $SITE" >> /etc/hosts
mkdir -p /var/www/$SITE

#создаем и описываем конфигурационный файл апача
cp /etc/apache2/sites-available/default /etc/apache2/sites-available/$SITE
sed -i 's/ServerAdmin webmaster@localhost/ServerAdmin webmaster@'$SITE'\n\tServerName '$SITE'/' /etc/apache2/sites-available/$SITE #ищем нужные строчки и подставляем значения
sed -i 's@DocumentRoot /var/www@DocumentRoot /var/www/'$SITE'@' /etc/apache2/sites-available/$SITE

#копируем стандатный файл страници в каталог сайта
cp /var/www/index.html /var/www/$SITE/

#"запускаем сайт и перезапускаем сервис апач"
a2ensite $SITE
service apache2 restart
if [ $? -eq 0 ] #если команда поиска возвращает статус код 0, значет поиск удолсяи апач установлен
then 
    echo "Сайт установлен успешно!"
else
    echo "Произошла ошибка, обратитесь к логам для проверки!"
fi

#!/bin/bash
#Autor Juri Kononov, rühm A21
#Apache2 kodutöö, loob saiti ja kausta /var/www sse
export LC_ALL=C
#kas kasutaja on root õigustes?
if [ $UID -ne 0 ]
then
    echo "Kasutajal pole õigusi skripti käivitamiseks, logi juurkasutajaga"
    exit 1
fi

#parameetrite kontroll
SITE=$1
if [ $# -ne 1 ]
then
   echo "Skripti parameetrid on valed. Käivita Sktript Järgnevalt: ./apache.sh www.mingisait.ee"
   exit 1
fi
    echo "Loon veebilehe nimega $SITE !"

#kontrollin, las Apache2 on paigaldatud süsteemis või mitte
dpkg -s apache2 | grep "Status: install ok installed"
if [ $? -eq 0 ]
then 
    echo "Apache2 on instaleeritud"
else
    echo "Apache2 ei ole instaleeritud"
    apt-get update && apt-get install apache2
fi

#kirjutame faili hosts anmed ja loome saiti jaoks kausta
echo "127.0.0.1 $SITE" >> /etc/hosts
mkdir -p /var/www/$SITE

#kirjutame Apache Konf faili andmeid
cp /etc/apache2/sites-available/default /etc/apache2/sites-available/$SITE
#sed -i 's/ServerAdmin webmaster@localhost/ServerAdmin webmaster@'$SITE'\n\tServerName' $SITE'/' /etc/apache2/sites-available/$SITE     //ei toiminud
#sed -i 's@DocumentRoot /var/www@DocumentRoot /var/www/'$SITE'@' /etc/apache2/sites-available/$SITE                                     //ei toiminud

sed -i 's/ServerAdmin webmaster@localhost/ServerAdmin webmaster@'$SITE'\n\tServerName '$SITE'/' /etc/apache2/sites-available/$SITE
sed -i 's@DocumentRoot /var/www@DocumentRoot /var/www/'$SITE'@' /etc/apache2/sites-available/$SITE

#kopeerin vaikimisi faili site kaustasse
cp /var/www/index.html /var/www/$SITE/

#"käivitame" antud veebisaiti ja taaskäivitame demonit
a2ensite $SITE
service apache2 restart

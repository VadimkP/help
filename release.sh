#!/bin/bash
## Creater Vadim Plekhanov <va.plekhanov@gmail.com>

echo -n "Что необходимо обновить? (edo, edoadm, rio, migrator, status_checker): "
read ans
case "$ans" in
     edo) echo "Обновляем edo!"
          edo=$(find /data/edo/release_edo -maxdepth 1 -type d | grep release | sort -rV | head -1 |  awk 'match($0,/[0-9]+/){print substr($0,RSTART,RLENGTH)}')
          let "new_release =  $edo + 1"
          echo "Создаем новый каталог 'release.$new_release'."
          mkdir /data/edo/release_edo/release.$new_release

          echo -n "Введите новую версию ЭДО (Формат версии: xx.y.z или xx.y.z_k): "
                  read vers
          mv /tmp/edokf.war-$vers*.war /data/edo/release_edo/release.$new_release/
          echo "Копируем файлы из предыдущего релиза."
          cp /data/edo/release_edo/release.$edo/javax.mail-1.5.5.jar /data/edo/release_edo/release.$new_release

                  echo "Создаем Dockerfile с новой версией."

                  touch /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "FROM registry.edo:5000/tomcat-localy:7.0.68-jdk8" > /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "ENV CATALINA_OPTS=\"-Xmx8192m -Xms8192m\" " >> /data/edo/release_edo/release.$new_release/Dockerfile
                  echo 'ENV JAVA_OPTS=" \ ' >> /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "-Dpath.cms='/opt/EDOKF/cmsdb_EDOKF_flat' \ " >> /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "-Dpath.logs='/opt/EDOKF/cmsdb_EDOKF_flat/content/1/logs' \ " >> /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "-Dpath.config='/opt/EDOKF/cmsdb_EDOKF_flat/spb_test_configuration.json' \ " >> /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "-Dcom.sun.management.jmxremote \ " >> /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "-Dcom.sun.management.jmxremote=true \ " >> /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "-Dcom.sun.management.jmxremote.port=9999 \ " >> /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "-Dcom.sun.management.jmxremote.rmi.port=9999 \ " >> /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "-Dcom.sun.management.jmxremote.ssl=false \ " >> /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "-Dcom.sun.management.jmxremote.authenticate=false \ " >> /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "-Djava.rmi.server.hostname=localhost\" " >> /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "RUN rm -rf /usr/local/tomcat/webapps/*" >> /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "COPY edokf.war-$vers.war /usr/local/tomcat/webapps/ROOT.war" >> /data/edo/release_edo/release.$new_release/Dockerfile
                  echo "COPY javax.mail-1.5.5.jar /usr/lib/jvm/java-1.8.0-openjdk-amd64/jre/lib/ext/" >> /data/edo/release_edo/release.$new_release/Dockerfile

                  docker build -t edo:$vers /data/edo/release_edo/release.$new_release/ --no-cache
                  echo "Образ edo:$vers создан!"

                  echo "-----------------------------------"

                  echo "Удаляем старый контейнер и останавливаем текущий "
          old_conteiner_name=$(docker ps -a | grep tomcat_edo | grep Exited | awk '{ print $NF }')
          docker rm $old_conteiner_name
          up_conteiner=$(docker ps -a | grep tomcat_edo | grep Up | awk '{ print $1 }')
          docker stop $up_conteiner
                  ls -la /data/EDOKF_auto
                  echo "----------ВНИМАНИЕ! Запускаем новый docker-контейнер ЭДО!!!----------"
                  echo -n "С какой версией CMS_DB запускаем docker-контейнер ЭДО : "
                  read cms_ver
          docker run -d -p8080:8080 -p9999:9999 -v /data/EDOKF_auto/$cms_ver/:/opt/EDOKF/cmsdb_EDOKF_flat/ \
           -v /data/EDOKF_auto/cms_logs/:/opt/EDOKF/cmsdb_EDOKF_flat/content/1/logs/ -v /data/EDOKF_auto_xls/:/opt/EDOKF/cmsdb_EDOKF_flat/content/1/xls/ \
           -v /data/tomcat/conf/:/usr/local/tomcat/conf/ --sysctl net.ipv4.ip_no_pmtu_disc=1  -e "TZ=Europe/Moscow" --log-opt max-size=5m \
           --log-opt max-file=20 --name $old_conteiner_name edo:$vers

      echo "Для просмотра логов, пожалуйста, запустите в консоле docker logs -f $old_conteiner_name !"
      exit 1
;;

      edoadm) echo "Обновляем edoadm!"
          edoadm=$(find /data/edo/release_admin -maxdepth 1 -type d | grep release | sort -rV | head -1 |  awk 'match($0,/[0-9]+/){print substr($0,RSTART,RLENGTH)}')
          let "new_edoadm = $edoadm + 1"
          echo "Создаем новый каталог 'release_admin.$new_edoadm'."
          mkdir /data/edo/release_admin/release_admin.$new_edoadm

          echo -n "Введите новую версию Админки ЭДО (Формат версии: xx.y.z или xx.y.z_k): "
                  read vers_adm
          mv /tmp/edokf-admin-$vers_adm*.war /data/edo/release_admin/release_admin.$new_edoadm/
          echo "Копируем файлы из предыдущего релиза."
          cp /data/edo/release_admin/release_admin.$edoadm/javax.mail-1.5.5.jar /data/edo/release_admin/release_admin.$new_edoadm

                  echo "Создаем Dockerfile с новой версией."

                  touch /data/edo/release_admin/release_admin.$new_edoadm/Dockerfile
                  echo "FROM tomcat:7.0.68-jre8" > /data/edo/release_admin/release_admin.$new_edoadm/Dockerfile
                  echo "ENV CATALINA_OPTS=\"-Xmx2048m -Xms2048m\" " >> /data/edo/release_admin/release_admin.$new_edoadm/Dockerfile
                  echo 'ENV JAVA_OPTS=" \ ' >> /data/edo/release_admin/release_admin.$new_edoadm/Dockerfile
                  echo "-Dpath.cms='/opt/EDOKF/cmsdb_EDOKF_flat' \ " >> /data/edo/release_admin/release_admin.$new_edoadm/Dockerfile
                  echo "-Dpath.logs='/opt/EDOKF/cmsdb_EDOKF_flat/content/1/logs' \ " >> /data/edo/release_admin/release_admin.$new_edoadm/Dockerfile
                  echo "-Dpath.config='/opt/EDOKF/cmsdb_EDOKF_flat/spb_test_configuration.json' \ " >> /data/edo/release_admin/release_admin.$new_edoadm/Dockerfile
                  echo "-Delastic.url='http://172.31.1.151:9200'\" " >> /data/edo/release_admin/release_admin.$new_edoadm/Dockerfile
                  echo "RUN rm -rf /usr/local/tomcat/webapps/*" >> /data/edo/release_admin/release_admin.$new_edoadm/Dockerfile
                  echo "COPY edokf-admin-$vers_adm*.war /usr/local/tomcat/webapps/ROOT.war" >> /data/edo/release_admin/release_admin.$new_edoadm/Dockerfile
                  echo "COPY javax.mail-1.5.5.jar /usr/lib/jvm/java-1.8.0-openjdk-amd64/jre/lib/ext/" >> /data/edo/release_admin/release_admin.$new_edoadm/Dockerfile

                  docker build -t edoadm:$vers_adm /data/edo/release_admin/release_admin.$new_edoadm/ --no-cache
                  echo "Образ edoadm:$vers_adm создан!"

                  echo "-----------------------------------"

                  echo "Останавливаем текущий контейнер и удаляем предыдущий "
          old_conteiner_name_adm=$(docker ps -a | grep tomcat_admin | grep Exited | awk '{ print $NF }')
          docker rm $old_conteiner_name_adm
          up_conteiner_adm=$(docker ps -a | grep tomcat_admin | grep Up | awk '{ print $1 }')
          docker stop $up_conteiner_adm

                  ls -la /data/EDOKF_auto
                  echo "----------ВНИМАНИЕ! Запускаем новый docker-контейнер Админки ЭДО!!!----------"
                  echo -n "С какой версией CMS_DB запускаем docker-контейнер : "
                  read cms_ver
          docker run -d -p8282:8080 -v /data/EDOKF_auto/$cms_ver/:/opt/EDOKF/cmsdb_EDOKF_flat/ \
           -v /data/EDOKF_auto/cms_logs/adm/:/opt/EDOKF/cmsdb_EDOKF_flat/content/1/logs/ \
           -v /data/tomcat/conf/:/usr/local/tomcat/conf/ --sysctl net.ipv4.ip_no_pmtu_disc=1  -e "TZ=Europe/Moscow" --log-opt max-size=5m \
           --log-opt max-file=20 --name $old_conteiner_name_adm edoadm:$vers_adm

      echo "Для просмотра логов, пожалуйста, запустите в консоле docker log -f $old_conteiner_name_adm !"

      exit 1
;;

     *) echo "Вы ввели неверное значение!"
        echo " --------------- Выход! --------------"
        exit 1
;;
esac
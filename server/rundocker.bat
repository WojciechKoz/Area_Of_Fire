cd /d %~dp0
docker build -t areaoffireserver .
docker run -t -i -p 7543:7543 areaoffireserver

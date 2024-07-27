@echo off

set DOMINO_BIN_DIR=d:\lotus\notes12
set DOMINO_DATA_DIR=d:\notesdata

set DOMINO_HOSTNAME=darwin.nashed.de

set MICRO_CA_CERT=%DOMINO_DATA_DIR%\dominolab_cert.pem
set MICRO_CA_ROOT=%DOMINO_DATA_DIR%\dominolab_root.pem

echo Addin Nomad to host file
REM echo 127.0.0.1 %DOMINO_HOSTNAME% >> C:\Windows\System32\drivers\etc\hosts

echo Waiting if server replies
curl -k --retry 20 --retry-delay 6 --retry-connrefused --silent https://%DOMINO_HOSTNAME%:9443

echo Get the certificate chain via Java keytool

%DOMINO_BIN_DIR%\jvm\bin\keytool.exe -printcert -rfc -sslserver %DOMINO_HOSTNAME%:9443 > %MICRO_CA_CERT%

echo Get the root certificate from the chain into a separate file

for /f "tokens=*" %%a in (%MICRO_CA_CERT%) do (
  if "%%a" == "-----BEGIN CERTIFICATE-----" echo > %MICRO_CA_ROOT%
  echo %%a >> %MICRO_CA_ROOT%
)

echo Import the MicroCA root certificate into Windows trust store

certutil.exe -addstore -f root %MICRO_CA_ROOT%

echo Finally start the browser to connect to Domino via Nomad Web

start https://%DOMINO_HOSTNAME%:9443

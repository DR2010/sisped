@echo off
cls
echo Aguarde...instalando SISPED 2.5
if "%1"=="" goto erroexit
if "%2"=="" goto erroexit
%2:
cd\

if  exist  %2:\sisped\spv.exe     goto  jaexiste
if  exist  %2:\sisped\sisped.exe  goto  jaexiste

echo Versao antiga do sisped NAO encontrada. Prosseguindo...
md\sisped > Nul
cd\sisped > Nul
goto fim

:jaexiste

echo Versao antiga do sisped encontrada. Prosseguindo...
rem Caso exista algum arquivo em sisped.old nao sera feita a eliminacao dos
rem dados.
if       exist  %2:\sisped.old\sisped.exe  goto fim
if  not  exist  %2:\sisped.old\sisped.exe  md\sisped.old
cd\sisped.old
Echo Gerando copia dos dados atuais...
copy \sisped\*.* > Nul
goto fim

:fim
Echo Limpando diretorio SISPED
cd\sisped
del *.dbf > Nul
del *.exe > Nul
del *.bat > Nul
del *.txt > Nul
del *.ntx > Nul
Echo Copiando sistema...
copy %1:sispcomp.exe /v > nul
Echo Iniciando descompactacao...
sispcomp
Echo Excluindo arquivo temporario...
if exist sispcomp.exe del sispcomp.exe
echo Fim da instalacao.
echo Para executar, digite SPV e tecle enter.
echo:
goto fimII

:erroexit
Echo 
Echo Falta parametro.
Echo Ex: INSTALA A C
Echo ÿ

:fimII

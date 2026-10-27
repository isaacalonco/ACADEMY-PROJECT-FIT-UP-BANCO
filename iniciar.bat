@echo off
chcp 65001 >nul
title FIT UP - Sistema de Gestao de Academias

echo =========================================================
echo       FIT UP - Sistema de Gestao de Academias
echo =========================================================
echo.

:: 1. Verificar instalacao do Java
where java >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Java nao foi encontrado no PATH do sistema.
    echo Instale o Java 21+ ou configure a variavel JAVA_HOME.
    echo.
    pause
    exit /b 1
)

:: 2. Executar o JAR montado com todas as dependencias, se existir
if exist "%~dp0app\backend\target\academy-1.0-SNAPSHOT-jar-with-dependencies.jar" (
    echo [INFO] Iniciando FIT UP via JAR executavel...
    echo [INFO] Interface Web: http://localhost:8080
    echo.
    cd /d "%~dp0app\backend"
    java -jar target\academy-1.0-SNAPSHOT-jar-with-dependencies.jar
    pause
    exit /b 0
)

:: 3. Alternativa: compilar e executar via Maven
where mvn >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [INFO] JAR nao encontrado. Compilando e iniciando via Maven...
    cd /d "%~dp0app\backend"
    mvn -q package -DskipTests
    java -jar target\academy-1.0-SNAPSHOT-jar-with-dependencies.jar
    pause
    exit /b 0
)

echo [ERRO] JAR nao encontrado em app\backend\target e Maven nao esta no PATH.
echo Execute "mvn package" dentro de app\backend para gerar o JAR.
echo.
pause

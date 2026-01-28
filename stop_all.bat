@echo off
REM RAGFlow Windows停止脚本
REM 一键停止所有本地服务（保留远程数据库连接）

REM 设置控制台编码为UTF-8
chcp 65001 >nul

echo ========================================
echo RAGFlow Windows停止脚本
echo ========================================
echo.
echo 注意: 此脚本只会停止本地Ragflow服务
echo       远程数据库连接将保持不变
echo.

REM 停止后端服务器
echo [1/3] 停止后端服务器...
taskkill /F /IM python.exe /FI "WINDOWTITLE eq RAGFlow Backend*" 2>nul
if %errorlevel% equ 0 (
    echo   后端服务器已停止
) else (
    echo   后端服务器未运行或已停止
)

REM 停止任务执行器
echo [2/3] 停止任务执行器...
taskkill /F /IM python.exe /FI "WINDOWTITLE eq RAGFlow Task Executor*" 2>nul
if %errorlevel% equ 0 (
    echo   任务执行器已停止
) else (
    echo   任务执行器未运行或已停止
)

REM 停止前端服务
echo [3/3] 停止前端服务...
taskkill /F /IM node.exe 2>nul
if %errorlevel% equ 0 (
    echo   前端服务已停止
) else (
    echo   前端服务未运行或已停止
)

echo.
echo ========================================
echo 所有本地服务已停止
echo ========================================
echo.
echo 远程数据库连接保持不变:
echo   MySQL: 121.37.100.46:5455
echo   Redis: 121.37.100.46:6379
echo   Elasticsearch: 121.37.100.46:1200
echo   MinIO: 121.37.100.46:9000
echo.
pause
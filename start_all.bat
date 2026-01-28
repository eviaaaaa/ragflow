@echo off
REM RAGFlow Windows启动脚本
REM 使用参数控制启动级别：
REM   start_all.bat 4 - 只启动核心服务（后端、任务执行器、前端）
REM   start_all.bat 5 - 启动核心服务 + 管理服务器
REM   start_all.bat 6 - 启动所有服务（核心服务 + 管理服务器 + 缓存服务器 + 数据源同步）
REM   start_all.bat   - 默认启动核心服务（等同于参数4）

REM 设置控制台编码为UTF-8
chcp 65001 >nul

echo ========================================
echo RAGFlow Windows启动脚本
echo ========================================
echo.

REM 设置环境变量
set PYTHONPATH=D:\python\ragflow-fir

REM 设置conda环境名称
set CONDA_ENV_NAME=RagflowEnv
set CONDA_ENV_PATH=D:\python\RagflowEnv

REM 检查是否激活了conda环境
echo 检查conda环境...
conda info --envs | findstr /C:"*" >nul
if %errorlevel% neq 0 (
    echo 未检测到激活的conda环境，尝试自动激活...
    call conda activate "%CONDA_ENV_PATH%"
    
    REM 再次检查环境是否激活
    conda info --envs | findstr /C:"*" >nul
    if %errorlevel% neq 0 (
        echo 错误: 无法自动激活conda环境 %CONDA_ENV_NAME%
        echo 请手动运行: conda activate "%CONDA_ENV_PATH%"
        pause
        exit /b 1
    )
    echo 已成功激活conda环境: %CONDA_ENV_NAME%
)

echo 环境检查完成
echo.

REM 解析启动参数
set START_LEVEL=%1
if "%START_LEVEL%"=="" set START_LEVEL=4

if "%START_LEVEL%"=="4" (
    echo 启动模式: 核心服务（快速启动）
) else if "%START_LEVEL%"=="5" (
    echo 启动模式: 核心服务 + 管理服务器
) else if "%START_LEVEL%"=="6" (
    echo 启动模式: 所有服务（完整功能）
) else (
    echo 错误: 无效的启动参数
    echo 用法:
    echo   start_all.bat 4 - 只启动核心服务（后端、任务执行器、前端）
    echo   start_all.bat 5 - 启动核心服务 + 管理服务器
    echo   start_all.bat 6 - 启动所有服务（核心服务 + 管理服务器 + 缓存服务器 + 数据源同步）
    echo   start_all.bat   - 默认启动核心服务（等同于参数4）
    pause
    exit /b 1
)

echo.

REM 启动后端服务器
echo [1] 启动后端服务器...
start "RAGFlow Backend" cmd /k "chcp 65001 >nul && set PYTHONPATH=D:\python\ragflow-fir && python api/ragflow_server.py"

REM 等待后端服务器启动
echo 等待后端服务器启动...
timeout /t 10 /nobreak >nul

REM 启动任务执行器
echo [2] 启动任务执行器...
start "RAGFlow Task Executor" cmd /k "chcp 65001 >nul && set PYTHONPATH=D:\python\ragflow-fir && python rag/svr/task_executor.py 0"

REM 等待任务执行器启动
echo 等待任务执行器启动...
timeout /t 5 /nobreak >nul

REM 根据启动级别启动额外服务
if "%START_LEVEL%"=="5" (
    echo [3] 启动管理服务器...
    start "RAGFlow Admin Server" cmd /k "chcp 65001 >nul && set PYTHONPATH=D:\python\ragflow-fir && python admin/server/admin_server.py"
    echo 等待管理服务器启动...
    timeout /t 5 /nobreak >nul
)

if "%START_LEVEL%"=="6" (
    echo [3] 启动管理服务器...
    start "RAGFlow Admin Server" cmd /k "chcp 65001 >nul && set PYTHONPATH=D:\python\ragflow-fir && python admin/server/admin_server.py"
    echo 等待管理服务器启动...
    timeout /t 5 /nobreak >nul
    
    echo [4] 启动缓存文件服务器...
    start "RAGFlow Cache Server" cmd /k "chcp 65001 >nul && set PYTHONPATH=D:\python\ragflow-fir && python rag/svr/cache_file_svr.py"
    echo 等待缓存服务器启动...
    timeout /t 3 /nobreak >nul
    
    echo [5] 启动数据源同步服务...
    start "RAGFlow Data Sync" cmd /k "chcp 65001 >nul && set PYTHONPATH=D:\python\ragflow-fir && python rag/svr/sync_data_source.py 0"
    echo 等待数据源同步服务启动...
    timeout /t 3 /nobreak >nul
)

REM 启动前端服务
if "%START_LEVEL%"=="4" (
    echo [3] 启动前端服务...
) else if "%START_LEVEL%"=="5" (
    echo [4] 启动前端服务...
) else if "%START_LEVEL%"=="6" (
    echo [6] 启动前端服务...
)

cd web
start "RAGFlow Frontend" cmd /k "chcp 65001 >nul && npm run dev"
cd ..

echo.
echo ========================================
echo 服务启动完成！
echo ========================================
echo.
echo 访问地址:
echo   Web界面: http://localhost:9222/
echo   后端API: http://localhost:9380

if "%START_LEVEL%"=="5" (
    echo   管理界面: http://localhost:9381
)

if "%START_LEVEL%"=="6" (
    echo   管理界面: http://localhost:9381
)

echo.
echo 已启动服务:
echo   - 后端服务器: 主API服务
echo   - 任务执行器: 文档解析和任务处理
echo   - 前端服务: Web界面

if "%START_LEVEL%"=="5" (
    echo   - 管理服务器: 系统管理和用户管理
)

if "%START_LEVEL%"=="6" (
    echo   - 管理服务器: 系统管理和用户管理
    echo   - 缓存服务器: 文件缓存优化
    echo   - 数据源同步: 外部数据源同步
)

echo.
echo 按任意键关闭此窗口（服务将继续在后台运行）
pause >nul

@echo off
chcp 65001 >nul 2>nul
setlocal EnableDelayedExpansion
echo ============================================================
echo   Git Push Tool  -  日常更新推送
echo ============================================================
echo.

set "REPO_DIR=%~dp0"
cd /d "%REPO_DIR%"

REM ── 检查 git ──
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: 未找到 git
    pause
    exit /b 1
)

REM ── 必须已是 git 仓库（否则请先运行 gitupdate.bat）──
if not exist ".git" (
    echo ERROR: 当前文件夹还不是 git 仓库。
    echo        请先运行 gitupdate.bat 完成首次初始化和上传。
    pause
    exit /b 1
)

REM ── 确保 origin 指向记住的地址（容错：万一被改过）──
if exist ".gitrepo" (
    set "REMOTE_URL="
    set /p REMOTE_URL=<.gitrepo
    if defined REMOTE_URL set "REMOTE_URL=!REMOTE_URL: =!"
    if defined REMOTE_URL (
        git remote get-url origin >nul 2>nul
        if !errorlevel! neq 0 (
            git remote add origin "!REMOTE_URL!"
        ) else (
            git remote set-url origin "!REMOTE_URL!"
        )
    )
)

REM ────────────────────────────────────────────────────────────
REM  [1] 显示改动
REM ────────────────────────────────────────────────────────────
echo [1] 改动列表:
echo ------------------------------------------------------------
git status --short
echo.

for /f %%i in ('git status --short ^| find /c /v ""') do set "CHANGE_COUNT=%%i"

REM 本地已提交但还没推上去的 commit 数
set "AHEAD=0"
for /f %%a in ('git rev-list --count origin/main..HEAD 2^>nul') do set "AHEAD=%%a"
if not defined AHEAD set "AHEAD=0"

if "%CHANGE_COUNT%"=="0" (
    if "!AHEAD!"=="0" (
        echo   没有改动，也没有待推送的提交。
        pause
        exit /b 0
    )
    echo   没有新改动，但有 !AHEAD! 个提交还没推送。直接推送...
    echo.
    goto :push
)

echo   发现 %CHANGE_COUNT% 处改动
echo.

REM ────────────────────────────────────────────────────────────
REM  [2] 提交信息（回车用默认 update）
REM ────────────────────────────────────────────────────────────
echo [2] 提交信息（回车使用默认）:
set "COMMIT_MSG="
set /p "COMMIT_MSG=  > "
if "!COMMIT_MSG!"=="" set "COMMIT_MSG=update"
echo.

REM ────────────────────────────────────────────────────────────
REM  [3] 提交
REM ────────────────────────────────────────────────────────────
echo [3] 提交中...
git add -A
git commit -m "!COMMIT_MSG!"
echo.

:push
REM ────────────────────────────────────────────────────────────
REM  [4] 推送
REM ────────────────────────────────────────────────────────────
echo [4] 推送中...
git push origin main
if %errorlevel% neq 0 (
    echo   首次推送失败，尝试 -u 重试...
    git push -u origin main
)
if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo   推送失败 —— 请看上面的错误信息。
    echo   你的提交已安全保存在本地。修复原因后再次运行本工具，
    echo   会自动重新推送待发送的提交。
    echo ============================================================
    pause
    exit /b 1
)
echo.
echo ============================================================
echo   完成！已成功推送。
echo ============================================================
pause

@echo off
chcp 65001 >nul 2>nul
setlocal EnableDelayedExpansion
echo ============================================================
echo   Git Update Tool  -  单库多产品  -  提交并上传到总库
echo ============================================================
echo.

set "REPO_DIR=%~dp0"
cd /d "%REPO_DIR%"

REM ── 总库地址：写死（单库多产品，所有产品共用这一个库）──
set "REMOTE_URL=https://github.com/Xintheo/My-Products.git"

REM ── 检查 git ──
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: 未找到 git，请先安装 Git。
    pause
    exit /b 1
)

REM ── 容错：.gitrepo 若存在则以它为准（可手动改地址）──
if exist ".gitrepo" (
    set /p _R=<.gitrepo
    if defined _R set "REMOTE_URL=!_R: =!"
)

if not defined REMOTE_URL (
    echo ERROR: 未配置总库地址。
    echo        请在 .gitrepo 写入总库地址，或在脚本中填好 REMOTE_URL。
    pause
    exit /b 1
)
echo 总库地址: !REMOTE_URL!
echo.

REM ============================================================
REM  [1] 确保当前文件夹是总库的 working copy
REM      若不是 git 仓库：init + 关联 origin（首次）
REM ============================================================
if not exist ".git" (
    echo [1] 当前不是 git 仓库，初始化并关联总库...
    git init
    git branch -M main
    git remote add origin "!REMOTE_URL!"
    echo     已 init 并关联 origin
    echo     首次建议先拉取总库已有内容，避免覆盖他人产品：
    echo     正在尝试 git pull origin main ...
    git pull origin main --allow-unrelated-histories --no-edit
) else (
    echo [1] 已是 git 仓库
    git remote get-url origin >nul 2>nul
    if !errorlevel! neq 0 (
        git remote add origin "!REMOTE_URL!"
    ) else (
        git remote set-url origin "!REMOTE_URL!"
    )
)
echo.

REM ============================================================
REM  [2] 生成 .gitignore（若不存在）—— 工具自身不进库
REM ============================================================
if not exist ".gitignore" (
    echo [2] 生成 .gitignore...
    >.gitignore echo .DS_Store
    >>.gitignore echo Thumbs.db
    >>.gitignore echo __pycache__/
    >>.gitignore echo node_modules/
    >>.gitignore echo .gitrepo
    >>.gitignore echo gitupdate.bat
    >>.gitignore echo push.bat
) else (
    echo [2] .gitignore 已存在，保留
)
echo.

REM ============================================================
REM  [3] 生成 push.bat（日常增量推送用，base64 内嵌）
REM ============================================================
if not exist "push.bat" (
    echo [3] 生成 push.bat...
    set "PUSH_B64=QGVjaG8gb2ZmDQpjaGNwIDY1MDAxID5udWwgMj5udWwNCnNldGxvY2FsIEVuYWJsZURlbGF5ZWRFeHBhbnNpb24NCmVjaG8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09DQplY2hvICAgR2l0IFB1c2ggVG9vbCAgLSAg5pel5bi45pu05paw5o6o6YCBDQplY2hvID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQ0KZWNoby4NCg0Kc2V0ICJSRVBPX0RJUj0lfmRwMCINCmNkIC9kICIlUkVQT19ESVIlIg0KDQpSRU0g4pSA4pSAIOajgOafpSBnaXQg4pSA4pSADQp3aGVyZSBnaXQgPm51bCAyPm51bA0KaWYgJWVycm9ybGV2ZWwlIG5lcSAwICgNCiAgICBlY2hvIEVSUk9SOiDmnKrmib7liLAgZ2l0DQogICAgcGF1c2UNCiAgICBleGl0IC9iIDENCikNCg0KUkVNIOKUgOKUgCDlv4Xpobvlt7LmmK8gZ2l0IOS7k+W6k++8iOWQpuWImeivt+WFiOi/kOihjCBnaXR1cGRhdGUuYmF077yJ4pSA4pSADQppZiBub3QgZXhpc3QgIi5naXQiICgNCiAgICBlY2hvIEVSUk9SOiDlvZPliY3mlofku7blpLnov5jkuI3mmK8gZ2l0IOS7k+W6k+OAgg0KICAgIGVjaG8gICAgICAgIOivt+WFiOi/kOihjCBnaXR1cGRhdGUuYmF0IOWujOaIkOmmluasoeWIneWni+WMluWSjOS4iuS8oOOAgg0KICAgIHBhdXNlDQogICAgZXhpdCAvYiAxDQopDQoNClJFTSDilIDilIAg56Gu5L+dIG9yaWdpbiDmjIflkJHorrDkvY/nmoTlnLDlnYDvvIjlrrnplJnvvJrkuIfkuIDooqvmlLnov4fvvInilIDilIANCmlmIGV4aXN0ICIuZ2l0cmVwbyIgKA0KICAgIHNldCAiUkVNT1RFX1VSTD0iDQogICAgc2V0IC9wIFJFTU9URV9VUkw9PC5naXRyZXBvDQogICAgaWYgZGVmaW5lZCBSRU1PVEVfVVJMIHNldCAiUkVNT1RFX1VSTD0hUkVNT1RFX1VSTDogPSEiDQogICAgaWYgZGVmaW5lZCBSRU1PVEVfVVJMICgNCiAgICAgICAgZ2l0IHJlbW90ZSBnZXQtdXJsIG9yaWdpbiA+bnVsIDI+bnVsDQogICAgICAgIGlmICFlcnJvcmxldmVsISBuZXEgMCAoDQogICAgICAgICAgICBnaXQgcmVtb3RlIGFkZCBvcmlnaW4gIiFSRU1PVEVfVVJMISINCiAgICAgICAgKSBlbHNlICgNCiAgICAgICAgICAgIGdpdCByZW1vdGUgc2V0LXVybCBvcmlnaW4gIiFSRU1PVEVfVVJMISINCiAgICAgICAgKQ0KICAgICkNCikNCg0KUkVNIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgA0KUkVNICBbMV0g5pi+56S65pS55YqoDQpSRU0g4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSADQplY2hvIFsxXSDmlLnliqjliJfooag6DQplY2hvIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KZ2l0IHN0YXR1cyAtLXNob3J0DQplY2hvLg0KDQpmb3IgL2YgJSVpIGluICgnZ2l0IHN0YXR1cyAtLXNob3J0IF58IGZpbmQgL2MgL3YgIiInKSBkbyBzZXQgIkNIQU5HRV9DT1VOVD0lJWkiDQoNClJFTSDmnKzlnLDlt7Lmj5DkuqTkvYbov5jmsqHmjqjkuIrljrvnmoQgY29tbWl0IOaVsA0Kc2V0ICJBSEVBRD0wIg0KZm9yIC9mICUlYSBpbiAoJ2dpdCByZXYtbGlzdCAtLWNvdW50IG9yaWdpbi9tYWluLi5IRUFEIDJePm51bCcpIGRvIHNldCAiQUhFQUQ9JSVhIg0KaWYgbm90IGRlZmluZWQgQUhFQUQgc2V0ICJBSEVBRD0wIg0KDQppZiAiJUNIQU5HRV9DT1VOVCUiPT0iMCIgKA0KICAgIGlmICIhQUhFQUQhIj09IjAiICgNCiAgICAgICAgZWNobyAgIOayoeacieaUueWKqO+8jOS5n+ayoeacieW+heaOqOmAgeeahOaPkOS6pOOAgg0KICAgICAgICBwYXVzZQ0KICAgICAgICBleGl0IC9iIDANCiAgICApDQogICAgZWNobyAgIOayoeacieaWsOaUueWKqO+8jOS9huaciSAhQUhFQUQhIOS4quaPkOS6pOi/mOayoeaOqOmAgeOAguebtOaOpeaOqOmAgS4uLg0KICAgIGVjaG8uDQogICAgZ290byA6cHVzaA0KKQ0KDQplY2hvICAg5Y+R546wICVDSEFOR0VfQ09VTlQlIOWkhOaUueWKqA0KZWNoby4NCg0KUkVNIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgA0KUkVNICBbMl0g5o+Q5Lqk5L+h5oGv77yI5Zue6L2m55So6buY6K6kIHVwZGF0Ze+8iQ0KUkVNIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgA0KZWNobyBbMl0g5o+Q5Lqk5L+h5oGv77yI5Zue6L2m5L2/55So6buY6K6k77yJOg0Kc2V0ICJDT01NSVRfTVNHPSINCnNldCAvcCAiQ09NTUlUX01TRz0gID4gIg0KaWYgIiFDT01NSVRfTVNHISI9PSIiIHNldCAiQ09NTUlUX01TRz11cGRhdGUiDQplY2hvLg0KDQpSRU0g4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSADQpSRU0gIFszXSDmj5DkuqQNClJFTSDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIANCmVjaG8gWzNdIOaPkOS6pOS4rS4uLg0KZ2l0IGFkZCAtQQ0KZ2l0IGNvbW1pdCAtbSAiIUNPTU1JVF9NU0chIg0KZWNoby4NCg0KOnB1c2gNClJFTSDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIANClJFTSAgWzRdIOaOqOmAgQ0KUkVNIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgA0KZWNobyBbNF0g5o6o6YCB5LitLi4uDQpnaXQgcHVzaCBvcmlnaW4gbWFpbg0KaWYgJWVycm9ybGV2ZWwlIG5lcSAwICgNCiAgICBlY2hvICAg6aaW5qyh5o6o6YCB5aSx6LSl77yM5bCd6K+VIC11IOmHjeivlS4uLg0KICAgIGdpdCBwdXNoIC11IG9yaWdpbiBtYWluDQopDQppZiAlZXJyb3JsZXZlbCUgbmVxIDAgKA0KICAgIGVjaG8uDQogICAgZWNobyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0NCiAgICBlY2hvICAg5o6o6YCB5aSx6LSlIOKAlOKAlCDor7fnnIvkuIrpnaLnmoTplJnor6/kv6Hmga/jgIINCiAgICBlY2hvICAg5L2g55qE5o+Q5Lqk5bey5a6J5YWo5L+d5a2Y5Zyo5pys5Zyw44CC5L+u5aSN5Y6f5Zug5ZCO5YaN5qyh6L+Q6KGM5pys5bel5YW377yMDQogICAgZWNobyAgIOS8muiHquWKqOmHjeaWsOaOqOmAgeW+heWPkemAgeeahOaPkOS6pOOAgg0KICAgIGVjaG8gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09DQogICAgcGF1c2UNCiAgICBleGl0IC9iIDENCikNCmVjaG8uDQplY2hvID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQ0KZWNobyAgIOWujOaIkO+8geW3suaIkOWKn+aOqOmAgeOAgg0KZWNobyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0NCnBhdXNlDQo="
    powershell -NoProfile -Command "$b=$env:PUSH_B64; $bytes=[System.Convert]::FromBase64String($b); [System.IO.File]::WriteAllBytes((Join-Path (Get-Location) 'push.bat'), $bytes); Write-Host '  已生成 push.bat'"
) else (
    echo [3] push.bat 已存在，保留
)
echo.

REM ============================================================
REM  [4] 先与远程同步（拉取他人可能新增的产品），再提交本地
REM ============================================================
echo [4] 同步远程（拉取最新，避免推送被拒）...
git pull origin main --no-edit 2>nul
echo.

REM ============================================================
REM  [5] 提交当前所有产品文件夹
REM ============================================================
echo [5] 当前改动：
git add -A
git status --short
echo.
set "MSG="
set /p "MSG=  提交信息（回车默认 update products）: "
if "!MSG!"=="" set "MSG=update products"
git commit -m "!MSG!" 2>nul
if %errorlevel% neq 0 echo   没有需要提交的新内容
echo.

REM ============================================================
REM  [6] 推送到总库
REM ============================================================
echo [6] 推送到总库...
git push -u origin main
if %errorlevel% neq 0 (
    echo   直接推送失败，尝试先拉取合并...
    git pull origin main --allow-unrelated-histories --no-edit
    git push -u origin main
)
if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo   推送失败 —— 看上面错误。提交已安全存在本地。
    echo ============================================================
    pause
    exit /b 1
)
echo.
echo ============================================================
echo   完成！产品已上传到总库。以后增量更新可用 push.bat。
echo ============================================================
pause

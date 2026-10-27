@echo off
setlocal EnableExtensions
chcp 65001 >nul
set "REPO=https://github.com/khanheximrs-spec/thanhthan-webgame-ios.git"
set "WORK=%TEMP%\thanhthan-ios-github-%RANDOM%%RANDOM%"
set "ROOT=%~dp0"

where git >nul 2>&1
if errorlevel 1 (
  echo.
  echo CHUA CO GIT CHO WINDOWS.
  echo Mo https://git-scm.com/downloads/win va cai dat Git, sau do chay lai file nay.
  start "" "https://git-scm.com/downloads/win"
  goto :end
)

if not exist "%ROOT%ThanhThanWebGame\GameScreen.swift" (
  echo LOI: Khong tim thay thu muc ma nguon. Hay giai nen toan bo ZIP truoc khi chay.
  goto :end
)
if not exist "%ROOT%.github\workflows\unsigned-ipa.yml" (
  echo LOI: Thieu thu muc an .github. Hay giai nen ZIP bang Windows Explorer hoac 7-Zip.
  goto :end
)

echo.
echo ==== DANG TAI DU AN THANH THAN LEN GITHUB ====
git clone --depth 1 "%REPO%" "%WORK%"
if errorlevel 1 (
  echo LOI: Khong clone duoc repository. Kiem tra mang va dang nhap GitHub.
  goto :end
)

robocopy "%ROOT%ThanhThanWebGame" "%WORK%\ThanhThanWebGame" /E /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 goto :copyError
robocopy "%ROOT%ThanhThanWebGame.xcodeproj" "%WORK%\ThanhThanWebGame.xcodeproj" /E /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 goto :copyError
robocopy "%ROOT%.github" "%WORK%\.github" /E /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 goto :copyError
copy /Y "%ROOT%README.md" "%WORK%\README.md" >nul
if errorlevel 1 goto :copyError

pushd "%WORK%"
git add README.md .github ThanhThanWebGame ThanhThanWebGame.xcodeproj
if errorlevel 1 goto :gitError
git diff --cached --quiet
if not errorlevel 1 (
  echo Ma nguon da co san tren GitHub, khong can commit lai.
  goto :openActions
)

git config user.name >nul 2>&1
if errorlevel 1 git config user.name "ThanhThan iOS Build"
git config user.email >nul 2>&1
if errorlevel 1 git config user.email "thanhthan-ios@users.noreply.github.com"

git commit -m "Add complete iOS source and automatic IPA workflow"
if errorlevel 1 goto :gitError

echo.
echo DANG DAY MA NGUON LEN GITHUB. Neu duoc hoi, hay dang nhap GitHub tren trinh duyet.
git push origin main
if errorlevel 1 goto :gitError

:openActions
popd
echo.
echo THANH CONG: DA TAI MA NGUON LEN GITHUB.
echo Mo tab Actions de xem qua trinh build va tai artifact IPA chua ky.
start "" "https://github.com/khanheximrs-spec/thanhthan-webgame-ios/actions"
goto :end

:copyError
echo LOI: Khong sao chep duoc ma nguon.
goto :end

:gitError
popd
echo.
echo LOI: Git khong hoan thanh. Doc thong bao phia tren.
echo Neu bi tu choi quyen, hay dang nhap tai khoan GitHub dung chu so huu kho.

:end
echo.
pause
endlocal

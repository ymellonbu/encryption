@echo off
title 🔐 파일 암호화 + 바탕화면 설정 🔐
setlocal EnableDelayedExpansion

:: 1. 암호화할 폴더 경로 입력
set /c folder="암호화할 폴더 경로를 입력하세요 (예: C:\Users\내문서): "

:: 2. 비밀번호 입력
set /p password="암호를 입력하세요: "

:: 3. 비밀번호를 key.txt로 저장
echo %password% > "%folder%\key.txt"

:: 4. 암호화 실행 (PowerShell AES256)
echo.
echo ▶ 파일 암호화 중...
for %%F in ("%folder%\*") do (
    if "%%~nxF" neq "key.txt" (
        powershell -Command "& {
            $key=New-Object Byte[] 32;
            (1..32)|%{$key[$_-1]=[byte]('%password%'.ToCharArray()[$_%('%password%'.Length)])};
            $iv=New-Object Byte[] 16;
            $aes=New-Object System.Security.Cryptography.AesManaged;
            $aes.Key=$key;
            $aes.IV=$iv;
            $aes.Mode='CBC';
            $aes.Padding='PKCS7';
            $encryptor=$aes.CreateEncryptor();
            $bytes=[System.IO.File]::ReadAllBytes('%%F');
            $encBytes=$encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
            [System.IO.File]::WriteAllBytes('%%F.enc', $encBytes)
        }"
        del "%%F"
    )
)

echo.
echo ✅ 모든 파일이 암호화되었습니다! (%folder%)
echo 🔑 암호 키가 key.txt에 저장됨.
pause

:: 5. 복호화 실행
cls
set /p password=<"%folder%\key.txt"
echo ▶ 복호화 진행 중...

for %%F in ("%folder%\*.enc") do (
    powershell -Command "& {
        $key=New-Object Byte[] 32;
        (1..32)|%{$key[$_-1]=[byte]('%password%'.ToCharArray()[$_%('%password%'.Length)])};
        $iv=New-Object Byte[] 16;
        $aes=New-Object System.Security.Cryptography.AesManaged;
        $aes.Key=$key;
        $aes.IV=$iv;
        $aes.Mode='CBC';
        $aes.Padding='PKCS7';
        $decryptor=$aes.CreateDecryptor();
        $bytes=[System.IO.File]::ReadAllBytes('%%F');
        $decBytes=$decryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
        [System.IO.File]::WriteAllBytes('%%~dpnF', $decBytes)
    }"
    if exist "%%~dpnF" (
        del "%%F"
    )
)

echo.
echo ✅ 모든 파일이 복호화되었습니다! (%folder%)
echo 🔑 key.txt 파일을 삭제하세요!
pause

:: 6. 바탕화면 배경색 검정으로 변경
echo.
echo ▶ 바탕화면 색상 변경 중...
reg add "HKEY_CURRENT_USER\Control Panel\Colors" /v Background /t REG_SZ /d "0 0 0" /f

echo.
echo ✅ 바탕화면 색상이 검정색으로 설정되었습니다.
echo ⚠️ 적용하려면 로그아웃하거나 재부팅해야 합니다.
pause

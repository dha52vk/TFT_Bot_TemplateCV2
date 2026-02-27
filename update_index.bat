@echo off
setlocal enabledelayedexpansion

set "output=index.json"
set "S2=  "
set "S4=    "
set "S6=      "
set "S8=        "

echo [1/3] Dang quet thu muc va tao %output%...

:: Khoi tao file JSON
echo { > "%output%"

:: Dem thu muc cha (C1)
set "count_c1=0"
for /f "delims=" %%D in ('dir /ad /b 2^>nul') do (
    set "attr=%%~aD"
    if "!attr:~3,1!" NEQ "h" set /a count_c1+=1
)

set "curr_c1=0"
for /f "delims=" %%D in ('dir /ad /b 2^>nul') do (
    set "attr=%%~aD"
    if "!attr:~3,1!" NEQ "h" (
        set /a curr_c1+=1
        echo %S2%"%%D": [ >> "%output%"
        
        :: Dem thu muc con (C2)
        set "count_c2=0"
        for /f "delims=" %%S in ('dir "%%D" /ad /b 2^>nul') do (
            set "s_attr=%%~aS"
            if "!s_attr:~3,1!" NEQ "h" set /a count_c2+=1
        )

        set "curr_c2=0"
        for /f "delims=" %%S in ('dir "%%D" /ad /b 2^>nul') do (
            set "s_attr=%%~aS"
            if "!s_attr:~3,1!" NEQ "h" (
                set /a curr_c2+=1
                echo %S4%{ >> "%output%"
                echo %S6%"%%S": [ >> "%output%"

                :: Dem file con
                set "count_f=0"
                for /f "delims=" %%F in ('dir "%%D\%%S" /a-d /b /s 2^>nul') do (
                    if /i "%%~nxF" NEQ "%output%" if /i "%%~nxF" NEQ "%~nx0" set /a count_f+=1
                )

                set "curr_f=0"
                for /f "delims=" %%F in ('dir "%%D\%%S" /a-d /b /s 2^>nul') do (
                    if /i "%%~nxF" NEQ "%output%" if /i "%%~nxF" NEQ "%~nx0" (
                        set /a curr_f+=1
                        set "f_path=%%F"
                        set "f_path=!f_path:%cd%\=!"
                        set "f_path=!f_path:\=/!"
                        
                        if !curr_f! LSS !count_f! (
                            echo %S8%"!f_path!", >> "%output%"
                        ) else (
                            echo %S8%"!f_path!" >> "%output%"
                        )
                    )
                )
                
                echo %S6%] >> "%output%"
                if !curr_c2! LSS !count_c2! (
                    echo %S4%}, >> "%output%"
                ) else (
                    echo %S4%} >> "%output%"
                )
            )
        )
        if !curr_c1! LSS !count_c1! (
            echo %S2%], >> "%output%"
        ) else (
            echo %S2%] >> "%output%"
        )
    )
)
echo } >> "%output%"

echo [2/3] Da tao xong %output%.

:: 2. THUC HIEN GIT TOAN BO
echo.
echo [3/3] Dang thuc hien Git (Add all, Commit, Push)...

if exist ".git\" (
    :: Add tat ca moi thu (ke ca file moi va file index.json)
    git add .
    
    :: Commit voi thong bao bao gom ngay gio
    set "commit_msg=Update all files and index.json: %date% %time%"
    git commit -m "!commit_msg!"
    
    :: Push len remote
    git push
    
    echo.
    echo [OK] Da cap nhat va day toan bo len Git server!
) else (
    echo [!] Khong tim thay thu muc .git. Vui long chay 'git init' truoc.
)

pause

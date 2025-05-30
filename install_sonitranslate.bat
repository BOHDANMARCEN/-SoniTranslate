@echo off
:: ============================================================
::   ██████╗  ██████╗  ██████╗ ██████╗  █████╗ ███╗   ██╗
::   ██╔══██╗██╔═══██╗██╔═══██╗██╔══██╗██╔══██╗████╗  ██║
::   ██████╔╝██║   ██║██║   ██║██║  ██║███████║██╔██╗ ██║
::   ██╔══██╗██║   ██║██║   ██║██║  ██║██╔══██║██║╚██╗██║
::   ██████╔╝╚██████╔╝╚██████╔╝██████╔╝██║  ██║██║ ╚████║
::   ╚═════╝  ╚═════╝  ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
::
::    Автоматичний інсталятор SoniTranslate від METFARELL_Ai
::                         ver. final
:: ============================================================

title Установка SoniTranslate (остаточна версія)
set INSTALL_DIR=D:\SoniTranslate
...

@echo off
title Установка SoniTranslate (остаточна версія)

:: === 0. Шлях встановлення ===
set INSTALL_DIR=D:\SoniTranslate
set ENV_FILE=%INSTALL_DIR%\.env

:: === 1. Створення каталогу ===
echo [1/10] Створення каталогу...
mkdir "%INSTALL_DIR%" 2>nul
cd /d "%INSTALL_DIR%"

:: === 2. Клонування репозиторію ===
echo [2/10] Клонування репозиторію SoniTranslate...
git clone https://github.com/R3gm/SoniTranslate.git . 2>nul
if %errorlevel% neq 0 (
    echo [!] Git не встановлено або репозиторій вже існує.
)

:: === 3. Обробка .env ===
if not exist "%ENV_FILE%" (
    echo [3/10] Введіть ваш Hugging Face Token:
    set /p HF_TOKEN=HUGGINGFACE_TOKEN=
    echo HUGGINGFACE_TOKEN=%HF_TOKEN% > "%ENV_FILE%"
) else (
    echo [3/10] Файл .env знайдено.
)

:: === 4. Створення Conda-середовища ===
echo [4/10] Створення Conda-середовища...
call conda create -y -n sonitr python=3.10
call conda activate sonitr

:: === 5. Встановлення залежностей з requirements_base.txt (без torch) ===
echo [5/10] Встановлюємо базові залежності (без torch)...
powershell -Command "(Get-Content requirements_base.txt) | Where-Object {$_ -notmatch 'torch'} | Set-Content fixed_requirements.txt"
pip install -r fixed_requirements.txt

:: === 6. Встановлення torch вручну (CUDA 11.8) ===
echo [6/10] Встановлюємо torch з CUDA 11.8...
pip install torch==2.1.0+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

:: === 7. Встановлення сумісних версій fairseq, omegaconf, hydra-core ===
echo [7/10] Уникаємо конфліктів залежностей...
pip install omegaconf==2.0.6
pip install hydra-core==1.0.7
pip install fairseq==0.12.2

:: === 8. Встановлення решти залежностей ===
echo [8/10] Встановлюємо додаткові залежності...
pip install -r requirements_extra.txt --no-deps
conda install -y ffmpeg

:: === 9. Завантаження токена з .env ===
for /f "tokens=1,2 delims==" %%a in (%ENV_FILE%) do (
    if "%%a"=="HUGGINGFACE_TOKEN" set HF_TOKEN=%%b
)
set HF_TOKEN=%HF_TOKEN%
echo Токен Hugging Face: %HF_TOKEN%

:: === 10. Запуск програми ===
echo [10/10] Запуск інтерфейсу SoniTranslate...
python app_rvc.py

pause

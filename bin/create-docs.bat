@echo off

rem :: wget
set WGET_HOME=C:\PortableApps\wget\1.19.4

rem :: 7-zip
rem :: https://portableapps.com/apps/utilities/7-zip_portable
set ZIP7_HOME=C:\PortableApps\7-Zip\16.02\App\7-Zip64

rem :: node
set NODE_HOME=C:\PortableApps\node.js\13.14.0

rem :: php
set PHP_HOME=C:\PortableApps\php\7.2.32

rem :: wkhtmltoimage
rem :: https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox-0.12.5-1.mxe-cross-win64.7z
set WKHTMLTOPDF_HOME=C:\PortableApps\wkhtmltopdf\0.12.5

rem :: gitbook-cli
rem :: https://github.com/GitbookIO/gitbook-cli
set NPM_HOME=C:\PortableApps\npm-global\.bin
set GITBOOK_DIR=C:\PortableApps\GitBook

rem :: ebook-convert
rem :: https://portableapps.com/apps/office/calibre-portable
rem :: rem :: https://sourceforge.net/projects/portableapps/files/calibre%20Portable/calibrePortable_3.48.0.paf.exe/download
set CALIBRE_HOME=C:\PortableApps\calibre\3.48.0\App\Calibre

set PATH=%WGET_HOME%;%ZIP7_HOME%;%NODE_HOME%;%PHP_HOME%;%WKHTMLTOPDF_HOME%;%NPM_HOME%;%CALIBRE_HOME%;%PATH%

set DIR=%~dp0.
set OUTPUT_DIR=%DIR%\..

rem :: read redux tag/release semantic version number from external file
set VERSION_TXT=%DIR%\redux-version.txt
set /P redux_version=<"%VERSION_TXT%"

set FIX_MD_JS=%DIR%\assets\filter-yaml-metadata-block.js
set BOOK_JSON=%DIR%\assets\book.json
set README_MD=%DIR%\assets\README.md
set TITLE_PG_PHP=%DIR%\assets\TITLE_PAGE.php

set TEMP_DIR=%DIR%\temp
set REDUX_ZIP=%TEMP_DIR%\redux.zip
set TITLE_PG=%TEMP_DIR%\TITLE_PAGE.html

if exist "%TEMP_DIR%" rmdir /Q /S "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

rem :: https://github.com/reactjs/redux
set relative_docs_path=redux-%redux_version%/docs
wget --no-check-certificate -O "%REDUX_ZIP%" "https://github.com/reduxjs/redux/archive/v%redux_version%.zip"
7z x "%REDUX_ZIP%" -o"%TEMP_DIR%" "%relative_docs_path%" -r
cd "%TEMP_DIR%\%relative_docs_path%"

rem :: repair broken yaml metadata blocks in markdown files
node "%FIX_MD_JS%"

rem :: https://gitbookio.gitbooks.io/documentation/content/format/introduction.html
rem :: https://gitbookio.gitbooks.io/documentation/content/format/cover.html
rem :: ================
rem :: reorganize files
rem ::   SUMMARY.md = table of contents
rem ::   README.md  = title page
rem ::   cover.jpg  = cover image (1800x2360)

rename "README.md" "SUMMARY.md"
copy "%README_MD%" "README.md"
copy "%BOOK_JSON%" "book.json"
php "%TITLE_PG_PHP%" "%redux_version%" >"%TITLE_PG%"
wkhtmltoimage --width 1800 --height 2360 --format jpg --quality 94 "%TITLE_PG%" "cover.jpg"

call :ebook-convert pdf
call :ebook-convert epub
call :ebook-convert mobi
goto :done

:ebook-convert
  call gitbook "%~1" . "%OUTPUT_DIR%\redux-documentation.%~1" -- log=debug --debug
  goto :eof

:done

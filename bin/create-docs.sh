#!/usr/bin/env bash

# '1' will use 7-zip, rather than tar
use_7zip='0'

# wget
WGET_HOME='/c/PortableApps/wget/1.19.4'

# 7-zip
# https://portableapps.com/apps/utilities/7-zip_portable
if [ "$use_7zip" == '1' ]; then
  ZIP7_HOME='/c/PortableApps/7-Zip/16.02/App/7-Zip64'
fi

# node
NODE_HOME='/c/PortableApps/node.js/13.14.0'

# php
PHP_HOME='/c/PortableApps/php/7.2.32'

# wkhtmltoimage
# https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox-0.12.5-1.mxe-cross-win64.7z
WKHTMLTOPDF_HOME='/c/PortableApps/wkhtmltopdf/0.12.5'

# gitbook-cli
# https://github.com/GitbookIO/gitbook-cli
NPM_HOME='/c/PortableApps/npm-global/.bin'
export GITBOOK_DIR='/c/PortableApps/GitBook'

# ebook-convert
# https://portableapps.com/apps/office/calibre-portable
# # https://sourceforge.net/projects/portableapps/files/calibre%20Portable/calibrePortable_3.48.0.paf.exe/download
CALIBRE_HOME='/c/PortableApps/calibre/3.48.0/App/Calibre'

PATH="${WGET_HOME}:${NODE_HOME}:${PHP_HOME}:${WKHTMLTOPDF_HOME}:${NPM_HOME}:${CALIBRE_HOME}:${PATH}"
if [ "$use_7zip" == '1' ]; then
  PATH="${ZIP7_HOME}:${PATH}"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT_DIR="${DIR}/.."

# read redux tag/release semantic version number from external file
VERSION_TXT="${DIR}/redux-version.txt"
redux_version=$(cat "$VERSION_TXT")

FIX_MD_JS="${DIR}/assets/filter-yaml-metadata-block.js"
BOOK_JSON="${DIR}/assets/book.json"
README_MD="${DIR}/assets/README.md"
TITLE_PG_PHP="${DIR}/assets/TITLE_PAGE.php"

TEMP_DIR="${DIR}/temp"
if [ "$use_7zip" == '1' ]; then
  REDUX_ZIP="${TEMP_DIR}/redux.zip"
else
  REDUX_ZIP="${TEMP_DIR}/redux.tar.gz"
fi
TITLE_PG="${TEMP_DIR}/TITLE_PAGE.html"

[ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
mkdir "$TEMP_DIR"

# https://github.com/reactjs/redux
relative_docs_path="redux-${redux_version}/docs"
if [ "$use_7zip" == '1' ]; then
  wget --no-check-certificate -O "$REDUX_ZIP" "https://github.com/reduxjs/redux/archive/v${redux_version}.zip"

  7z x "$REDUX_ZIP" -o"$TEMP_DIR" "$relative_docs_path" -r
  cd "${TEMP_DIR}/${relative_docs_path}"
else
  wget --no-check-certificate -O "$REDUX_ZIP" "https://github.com/reduxjs/redux/archive/v${redux_version}.tar.gz"

  cd "$TEMP_DIR"
  tar -zxvf "$REDUX_ZIP" "$relative_docs_path"
  cd "$relative_docs_path"
fi

# repair broken yaml metadata blocks in markdown files
node "$FIX_MD_JS"

# https://gitbookio.gitbooks.io/documentation/content/format/introduction.html
# https://gitbookio.gitbooks.io/documentation/content/format/cover.html
# ================
# reorganize files
#   SUMMARY.md = table of contents
#   README.md  = title page
#   cover.jpg  = cover image (1800x2360)

mv 'README.md' 'SUMMARY.md'
cp "$README_MD" 'README.md'
cp "$BOOK_JSON" 'book.json'
php "$TITLE_PG_PHP" "$redux_version" >"$TITLE_PG"
wkhtmltoimage --width 1800 --height 2360 --format jpg --quality 94 "$TITLE_PG" 'cover.jpg'

function ebook-convert {
  gitbook "$1" . "${OUTPUT_DIR}/redux-documentation.${1}" -- log=debug --debug
}

ebook-convert pdf
ebook-convert epub
ebook-convert mobi

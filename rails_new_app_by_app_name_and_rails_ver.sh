#!/bin/bash

readonly SCRIPT_DIR=$(cd $(dirname $0); pwd)

if [ $# -eq 1 ]; then
	rails_ver="gem \"rails\""
elif [ $# -eq 2 ]; then
	rails_ver="gem \"rails\", \"${2}\""
else
	echo "シェルスクリプトの引数の数が不正です。"
	exit 1
fi

app_path="${SCRIPT_DIR}/${1}/"
mkdir -p ${app_path}

if ! [ -e ${app_path} ]; then
	echo "アプリケーションフォルダ作成に失敗しました。"
	exit 1
fi

cd ${app_path}

cat << EOS > Gemfile
source "http://rubygems.org"
${rails_ver}
EOS

if ! [ -e "${app_path}/Gemfile" ]; then
	echo "Gemfile作成に失敗しました。"
	exit 1
fi

bundle install --path vendor/bundle
exit_status=${?}
if [ $? -ne 0 ]; then
	echo "1回目のbundle installが失敗しました。（エラーコード: ${exit_status}）"
	exit 1
fi

echo "Y" | bundle exec rails new . --skip-bundle
exit_status=${?}
if [ $? -ne 0 ]; then
	echo "新規アプリケーション作成に失敗しました。（エラーコード: ${exit_status}）"
	exit 1
fi

bundle install --path vendor/bundle
exit_status=${?}
if [ $? -ne 0 ]; then
	echo "2回目のbundle installが失敗しました。（エラーコード: ${exit_status}）"
	exit 1
fi

bundle exec rails webpacker:install
exit_status=${?}
if [ $? -ne 0 ]; then
	echo "webpackerのインストールに失敗しました。（エラーコード: ${exit_status}）"
	exit 1
fi

cat << EOS > .gitignore
# Created by https://www.gitignore.io/api/rails
# Edit at https://www.gitignore.io/?templates=rails

### Rails ###
*.rbc
capybara-*.html
.rspec
/db/*.sqlite3
/db/*.sqlite3-journal
/public/system
/coverage/
/spec/tmp
*.orig
rerun.txt
pickle-email-*.html

# Ignore all logfiles and tempfiles.
/log/*
/tmp/*
!/log/.keep
!/tmp/.keep

# TODO Comment out this rule if you are OK with secrets being uploaded to the repo
config/initializers/secret_token.rb
config/master.key

# Only include if you have production secrets in this file, which is no longer a Rails default
# config/secrets.yml

# dotenv
# TODO Comment out this rule if environment variables can be committed
.env

## Environment normalization:
/.bundle
/vendor/bundle

# these should all be checked in to normalize the environment:
# Gemfile.lock, .ruby-version, .ruby-gemset

# unless supporting rvm < 1.11.0 or doing something fancy, ignore this:
.rvmrc

# if using bower-rails ignore default bower_components path bower.json files
/vendor/assets/bower_components
*.bowerrc
bower.json

# Ignore pow environment settings
.powenv

# Ignore Byebug command history file.
.byebug_history

# Ignore node_modules
node_modules/

# Ignore precompiled javascript packs
/public/packs
/public/packs-test
/public/assets

# Ignore yarn files
/yarn-error.log
yarn-debug.log*
.yarn-integrity

# Ignore uploaded files in development
/storage/*
!/storage/.keep

# End of https://www.gitignore.io/api/rails
EOS

if ! [ -e "${app_path}/.gitignore" ]; then
	echo "gitignore更新に失敗しました。"
	exit 1
fi

bundle exec rails server
exit_status=${?}
if [ $? -ne 0 ]; then
	echo "Webサーバーの起動に失敗しました。（エラーコード: ${exit_status}）"
	exit 1
fi

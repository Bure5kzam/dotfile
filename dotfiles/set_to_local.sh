#!/bin/bash

# URL_GIT_DOTFILE_REPO 변수에 저장된 값 가져오기
REPO_URL=${URL_GIT_DOTFILE_REPO:-https://github.com/Bure5kzam/dotfile.git}

cd $HOME

# dotfile 저장소 구성
git clone --bare "$REPO_URL" $HOME/.cfg || { echo "Clone failed"; exit 1; }

# config 명령어 생성
function config {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

# 중복된 파일 백업 폴더 생성
mkdir -p .config-backup

# dotfile 설정 적용
config checkout

# 실행했을 때 에러가 났으면 백업 프로세스 실행
if [ $? = 0 ]; then
  echo "Checked out config.";
else
  echo "Backing up pre-existing dot files.";
  config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;

config checkout
config config status.showUntrackedFiles no

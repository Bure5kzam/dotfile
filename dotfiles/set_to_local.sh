#!/bin/bash

# URL_GIT_DOTFILE_REPO 변수에 저장된 값 가져오기
REPO_URL=${URL_GIT_DOTFILE_REPO:-https://github.com/Bure5kzam/dotfile.git}
TODAY=$(TODAY +%Y-%m-%d_%H-%M-%S)
cd $HOME

# 이미 .cfg 디렉토리가 존재하는지 확인
if [ -d "$HOME/.cfg" ]; then
  echo ".cfg directory already exists, backing up to .config-backup"
  
  # 중복된 파일 백업 폴더 생성
  mkdir -p $HOME/.config-backup
  
  # 기존 .cfg 디렉토리를 백업 디렉토리로 이동
  mv $HOME/.cfg $HOME/.config-backup/.cfg_backup_$TODAY
fi

# dotfile 저장소 구성
git clone --bare "$REPO_URL" $HOME/.cfg || { echo "Clone failed"; exit 1; }

# config 명령어 생성
function config {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

# dotfile 설정 적용
config checkout

# 실행했을 때 에러가 났으면 백업 프로세스 실행
if [ $? = 0 ]; then
  echo "Checked out config."
else
  echo "Backing up pre-existing dot files."
  BACKUP_DIR=dotfiles_backup
  # 중복된 파일 백업 폴더 생성
  mkdir -p $HOME/$BACKUP_DIR/$TODAY
  
  # 중복된 파일을 .config-backup으로 이동
  config checkout 2>&1 | egrep "^\s+.*" | awk {'print $1'} | awk -F '/' {' print $1 '} | xargs -I{} mv {} $HOME/$BACKUP_DIR/$TODAY/{}
fi

config checkout
config config status.showUntrackedFiles no

# YouCompleteMe安装

## 升级VIM

```
sudo add-apt-repository ppa:jonathonf/vim
sudo apt-get update
sudo apt-get install vim
```

## 安装Vundle

[Vundel Github仓库](https://github.com/VundleVim/Vundle.vim)

按照readme老老实实的走，注意，这一步不能少，少了会报错：

```
Error detected while processing VimEnter Auto commands for "*": 
Unknown function: youcompleteme#Enable
```

## 编译安装

[YouCompleteMe Github仓库](https://github.com/Valloric/YouCompleteMe)

根据ubuntu Linux x64步骤进行安装

```shell
sudo apt-get install build-essential cmake
sudo apt-get install python-dev python3-dev
git clone https://github.com/Valloric/YouCompleteMe.git ~/.vim/bundle/YouCompleteMe
cd ~/.vim/bundle/YouCompleteMe
git submodule update --init --recursive         # 更新子仓库
./install.py --clang-completer                  # C-family
```

## 配置

安装完成后将`YouCompleteMe`下的`python`和`plugin`两个目录复制到`~/.vim`下，并将`YouCompleteMe/third_party/ycmd/examples/.ycm_extra_conf.py`复制到根目录下。

```shell
cd ~/.vim/bundle/YouCompleteMe
cp -r python ~/.vim
cp -r plugin ~/.vim
cp third_party/ycmd/examples/.ycm_extra_conf.py ~
```

## 默认支持C++11

```
" change the compiler to g++ to support c++11.
let g:syntastic_cpp_compiler = 'g++'
" set the options of g++ to suport c++11.
let g:syntastic_cpp_compiler_options = '-std=c++11 -stdlib=libc++' 
```

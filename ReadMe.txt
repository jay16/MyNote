windows上使用git有以下问题：

 1. Windows下生成的库与Linux下不同，文件名编码不兼容，会导致文件名乱码。
 2. Windows与Linux的库不能互相引用。
 3. 不同语言版本的Windows生成的库也不兼容，也不能互相引用。

有牛人对Git和TortoiseGit代码进行了修改，让它们都直接使用UTF-8编码来存储文件名，以保持与Linux版本一致。
修改的版本可以在http://code.google.com/p/utf8-git-on-windows/downloads下载。

想更省事的话直接使用下面的链接下载
http://utf8-git-on-windows.googlecode.com/files/Git-1.7.3.2-utf8-20110213.exe

另外，有个日本人写的这个git版本也解决了文件路径问题，它也能正常运行git svn，不会崩溃。
Git-1.7.0.2-utf8-20100725.exe from http://tmurakam.org/git/,
它的开源项目在：
https://github.com/tmurakam/4msysgit-utf8-filepath

在下次的推送或者拉取时，输入用户名和密码即可本地存储用户名密码。不用每次都输入。
git config --global credential.helper 'store'
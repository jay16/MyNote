windows��ʹ��git���������⣺

 1. Windows�����ɵĿ���Linux�²�ͬ���ļ������벻���ݣ��ᵼ���ļ������롣
 2. Windows��Linux�Ŀⲻ�ܻ������á�
 3. ��ͬ���԰汾��Windows���ɵĿ�Ҳ�����ݣ�Ҳ���ܻ������á�

��ţ�˶�Git��TortoiseGit����������޸ģ������Ƕ�ֱ��ʹ��UTF-8�������洢�ļ������Ա�����Linux�汾һ�¡�
�޸ĵİ汾������http://code.google.com/p/utf8-git-on-windows/downloads���ء�

���ʡ�µĻ�ֱ��ʹ���������������
http://utf8-git-on-windows.googlecode.com/files/Git-1.7.3.2-utf8-20110213.exe

���⣬�и��ձ���д�����git�汾Ҳ������ļ�·�����⣬��Ҳ����������git svn�����������
Git-1.7.0.2-utf8-20100725.exe from http://tmurakam.org/git/,
���Ŀ�Դ��Ŀ�ڣ�
https://github.com/tmurakam/4msysgit-utf8-filepath

���´ε����ͻ�����ȡʱ�������û��������뼴�ɱ��ش洢�û������롣����ÿ�ζ����롣
With git version before 1.7.9 

git config --global credential.helper 'store'

With git version 1.7.9 and later

.git/config
git config credential.helper cache
~/.gitconfig
git config --global credential.helper 'cache --timeout=xx'


http://gitcredentialstore.codeplex.com/
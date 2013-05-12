#encoding:utf-8  
  Dir.foreach("E:\MyWork\MyNote\CentOS\Centos5.5°²×°".encode("GBK")) do |file|
   if file!= "." or file != ".." then
      puts file 
   end
  end
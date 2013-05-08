#encoding:utf-8
  require 'open-uri'
  require 'zip/zip'
  require 'zip/zipfilesystem'
  require 'fileutils' 
  require 'nokogiri'
  
  def openfind(openfind_url)    
     #openfind_url = 'http://cndemo.openfind.com/china/epaper/2012_12'
     
     #创建根目录
     ym = Time.now.strftime("%Y-%m")
     #openfind_path = Rails.root.join("public","openfind #{ym}") 
     openfind_path = Dir.pwd+"/openfind #{ym}"
     #FileUtils.rm_r(openfind_path) if File.exist?(openfind_path)
     Dir.mkdir(openfind_path) unless File.exist?(openfind_path)
     images_path = File.join(openfind_path,"images")
     Dir.mkdir(images_path) unless File.exist?(images_path)
     
     #下载image并修改链接地址
     doc = Nokogiri::HTML(open(openfind_url).read)
     doc.css("img").each do |img|
       img_src = img.attr("src")
       next unless %w(.jpg .jpeg .gif .png).include?(File.extname(img_src).downcase)
       begin
       img_data = open(img_src){|f|f.read }
       rescue => e
        puts e.to_s
       else
         new_img = File.join(images_path,File.basename(img_src))
         open(new_img,"wb") do |f| 
           f.write(img_data)
         end
         img["src"] = File.join("images",File.basename(img_src))
       end
     end
      
     #创建index页面
     index_path = File.join(openfind_path,"index.html")
     openfind_index = File.new(index_path,'w')
     #src_code =  Nokogiri::HTML(open(openfind_url).read)
     #src_code = open(openfind_url).read
     #src_code = src_code.force_encoding('GBK')  
     #src_code = src_code.encode('UTF-8',{:invalid => :replace, :undef => :replace, :replace => ' '}) 
     openfind_index.puts(doc.to_s)

    #zf_dir = Rails.root.join("public","openfind #{Time.now.strftime('%Y-%m Template')}.zip")
    zf_dir = Dir.pwd+"/openfind #{Time.now.strftime('%Y-%m Template')}.zip"
    File.delete(zf_dir) if File.exist?(zf_dir)
    generate_zip(openfind_path,zf_dir)
     
    #if File.exist?(zf_dir)
    #  io = File.open(zf_dir)
    #  io.binmode
    #  send_data(io.read,:filename => "openfind #{Time.now.strftime('%Y-%m Template')}.zip",:disposition => 'attachment')
    #  io.close
    #else
    #end
  end

  def generate_zip(been_zip_dir,zf_dir)
    #zf_dir = Dir.pwd+"/openfind #{Time.now.strftime('%Y-%m Template')}.zip"
    Zip::ZipFile.open zf_dir, Zip::ZipFile::CREATE do |zip|  
      encrypt_zip(been_zip_dir, "", zip) 
    end  
  end  
  
  def encrypt_zip(file_path, zip_dir, zip)
    base_name = File.basename(file_path)
    if File.directory?(file_path)
      zip_dir = zip_dir.to_s.length > 0 ? File.join(zip_dir,base_name) : base_name
      zip.dir.mkdir(zip_dir)
      Dir.foreach(file_path) do |sub_file|
        encrypt_zip(File.join(file_path,sub_file), zip_dir, zip) unless sub_file == '.' or sub_file == '..'   
      end
    else
      base_name = File.join(zip_dir,base_name) if zip_dir.to_s.length > 0
      zip.add(base_name, file_path)
      #zip.file.open(File.join(zip_dir,base_name), 'w') { |f| f << file_path }  
    end 
  end

  
openfind("http://cndemo.openfind.com/china/epaper/2013_04/")    

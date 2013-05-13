#encoding:utf-8
  require 'fileutils' 
  require 'csv'
  
  
  
  def check_member(csv_dir)
    csv_log = File.open("csv_log.txt","a")
    all_totle_num   = 0
    valid_totle_num = 0
    Dir.foreach(csv_dir) do |csv_file|
      if File.extname(csv_file).downcase == ".csv" then
        all_num   = 0
        valid_num = 0
        file_path = csv_dir +"\\"+file
        CSV.foreach(file_path) do |row|
           all_num += 1
           if row[1].to_i in [1,4,5] then
             valid_num += 1
           end
        end
        csv_log.puts(file+"--all:"+all_num.to_s+"--valid:"+valid_num.to_s)
        all_totle_num   += all_num
        valid_totle_num += valid_num
      end
    end
    csv_log.puts(totle+"--all:"+all_totle_num.to_s+"--valid:"+valid_totle_num.to_s)
  end
  check_member()
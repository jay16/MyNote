#encoding: utf-8
require 'yaml/store'
require 'yaml'
require 'gtk2'



current_dir = Dir.pwd
SOLife_dir  = "E:\\MyWork\\MyNote\\"

#根据SOLife_dir显示目录
def generate_catalogue(root_dir,note_path,catalogue_array,level)
  level += 1
  if File.directory?(note_path) then
    #puts "enter:"+note_path+"-basename:"+File.basename(note_path)+"-dirname:"+File.dirname(note_path);
    if root_dir != note_path then
      catalogue_array.push(["dir",note_path,File.basename(note_path),level])
    end
    Dir.foreach(note_path) do |file|
      if file != "." and file != ".." then
        generate_catalogue(root_dir,note_path+"\\"+file,catalogue_array,level)
      end
    end
  elsif 
    #puts "file:" + note_path+"-basename:"+File.basename(note_path)+"-dirname:"+File.dirname(note_path);
    catalogue_array.push(["file",note_path,File.basename(note_path),level])
    
  end
end

catalogue = Array.new
generate_catalogue(SOLife_dir,SOLife_dir,catalogue,0)

level_one = catalogue.select { |item| item[-1] == 2 }

file = File.open("catalogue.txt","w")

#为减少压力只显示两层

level_one.each do |dir|
  file.print("-"+dir[2])
  file.print("\n")
  puts "-"+dir[2]
  level_two = catalogue.select { |item| File.dirname(item[1]) == dir[1] }
  level_two.each do |item|
    puts "  -"+item[2]
    file.print("  -"+item[2])
    file.print("\n")
  end
end

file.close

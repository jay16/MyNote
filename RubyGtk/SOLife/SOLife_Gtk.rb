#encoding: utf-8
require 'yaml/store'
require 'yaml'
require 'gtk2'



current_dir = Dir.pwd
SOLife_dir  = "E:\\MyWork\\MyNote\\"

#根据SOLife_dir显示目录
def generate_catalogue(root_dir,note_path,catalogue_array,parent_id)
  if File.directory?(note_path) then
    #puts "enter:"+note_path+"-basename:"+File.basename(note_path)+"-dirname:"+File.dirname(note_path);
    if root_dir != note_path then
    store_array.push({:file_type => "dir",:dirname => File.dirname(note_path), :basename => File.basename(note_path)})
    
    Dir.foreach(note_path) do |file|
      if file != "." and file != ".." then
        generate_catalogue(note_path+"\\"+file,store_array)
      end
    end
  elsif 
    #puts "file:" + note_path+"-basename:"+File.basename(note_path)+"-dirname:"+File.dirname(note_path);
    store_array.push(["file",:dirname => File.dirname(note_path), :basename => File.basename(note_path)})
  end
  
end

catalogue = Array.new
generate_catalogue(SOLife_dir,catalogue)
puts catalogue.to_s
file = File.open("catalogue.txt","w")
file.puts(catalogue.to_s)
file.close
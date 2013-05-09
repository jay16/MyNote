#encoding: utf-8
require 'yaml/store'
require 'yaml'
require 'gtk2'



current_dir = Dir.pwd
SOLife_dir  = "E:\\MyWork\\MyNote\\"

#根据SOLife_dir显示目录
def generate_catalogue(note_dir)
  if File.directory(note_dir) then
    puts "enter:"+note_dir
    Dir.foreach(note_dir) do |item|
      puts item
    end
  else
  end
  
end
#encoding: utf-8
require 'yaml/store'
require 'yaml'
require 'gtk2'



current_dir = Dir.pwd
SOLife_dir  = "E:\\MyWork\\MyNote\\"

#����SOLife_dir��ʾĿ¼
def generate_catalogue(note_dir)
  if File.directory(note_dir) then
    puts "enter:"+note_dir
    Dir.foreach(note_dir) do |item|
      puts item
    end
  else
  end
  
end
#encoding: utf-8
require 'yaml'
require 'yaml/store'
require 'pathname'

cur_path = Pathname.new(__FILE__).realpath
cur_dir = File.dirname(cur_path)

note_dir = File.join(cur_dir,"note")
Dir.mkdir(note_dir) unless File.exist?(note_dir)

note_load = YAML.load_file('note.yml')

note_load.each do |one|
  # Append a second toplevel row and fill in some dat
    next unless note_load[one[0]]
    one_dir = File.join(note_dir,one[0])
    Dir.mkdir(one_dir) unless File.exist?(one_dir)
    note_load[one[0]].each do |two|
      next unless note_load[one[0]][two[0]]
      next if note_load[one[0]][two[0]].class==String
      two_dir = File.join(one_dir,two[0])
      Dir.mkdir(two_dir) unless File.exist?(two_dir)
      
      note_load[one[0]][two[0]].each do |three|
       yml_file = File.join(two_dir,"#{three[0]}.yml")
       unless File.exist?(yml_file)
         db = YAML::Store.new(yml_file)
         db.transaction do
           db["content"] = "[#{one[0]}][#{two[0]}][#{three[0]}] no data"
         end
       end
      end
    end
end
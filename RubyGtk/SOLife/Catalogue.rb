#encoding: utf-8
require 'yaml/store'
require 'yaml'
require 'gtk2'



current_dir = Dir.pwd
SOLife_dir  = "E:\\MyWork\\MyNote\\"

#根据SOLife_dir显示目录
def generate_catalogue(root_dir,note_path,catalogue_array,self_id)
  if File.directory?(note_path) then
    #puts "enter:"+note_path+"-basename:"+File.basename(note_path)+"-dirname:"+File.dirname(note_path);
    if root_dir != note_path then
      catalogue_array.push(["dir",note_path,File.basename(note_path),self_id])
    end
    Dir.foreach(note_path) do |file|
      if file != "." and file != ".." then
        generate_catalogue(root_dir,note_path+"\\"+file,catalogue_array)
      end
    end
  elsif 
    #puts "file:" + note_path+"-basename:"+File.basename(note_path)+"-dirname:"+File.dirname(note_path);
    catalogue_array.push(["file",note_path,File.basename(note_path)])
    
  end
  self_id += 1
  puts self_id
end

catalogue = Array.new
generate_catalogue(SOLife_dir,SOLife_dir,catalogue,0)

catalogu_dir = catalogue.select { |item| item[0] == "dir" }

file = File.open("catalogue.txt","w")

catalogu_dir.each do |dir|
  children = catalogue.select { |item| File.dirname(item[1]) == dir[1] }

  file.print(dir[2]+"-has " + children.count.to_s + "nodes")
  file.print("\n");
  children.each do |child|
    file.print(dir[-1]+" child:" + child[-1])
    file.print("\n");
  end
end

file.close

note_load.each do |one|
  # Append a second toplevel row and fill in some data
  
  parent[0] = one[0]
    next unless note_load[one[0]]
    note_load[one[0]].each do |two|
      child = treestore.append(parent)
      child[0]  = two[0]
      next unless note_load[one[0]][two[0]]
      next if note_load[one[0]][two[0]].class==String
      
      note_load[one[0]][two[0]].each do |three|
         parchild = treestore.append(child)
         parchild[0]  = three[0]
      end
    end
end

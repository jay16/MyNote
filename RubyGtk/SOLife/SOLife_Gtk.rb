#encoding: utf-8
require 'yaml/store'
require 'yaml'
require 'gtk2'



current_dir = Dir.pwd
SOLife_dir  = "E:\\MyWork\\MyNote\\"
SOLife_name = File.basename(SOLife_dir)

#����SOLife_dir��ʾĿ¼
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

#Ϊ����ѹ��ֻ��ʾ����

trees_tore = Gtk::TreeStore.new(String, String, Integer)

level_one.each do |lo|
  tree_lo = trees_tore.append(nil)
  tree_lo[0] = lo[2] #tree_level_one
  level_two = catalogue.select { |item| File.dirname(item[1]) == lo[1] }
  level_two.each do |lt|
    tree_lt = trees_tore.append(tree_lo)
    tree_lt[0] = lt[2]
  end
end



tree_view = Gtk::TreeView.new(trees_tore)
tree_view.selection.mode = Gtk::SELECTION_SINGLE
tree_view.expand_all
tree_view.hadjustment.value=100
tree_view.columns_autosize
#SELECTION_NONE
#SELECTION_BROWSE
scrolled_view = Gtk::ScrolledWindow.new
scrolled_view.border_width = 2
scrolled_view.add(tree_view)
scrolled_view.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

renderer = Gtk::CellRendererText.new
col = Gtk::TreeViewColumn.new(SOLife_name, renderer, :text => 0)
tree_view.append_column(col)


table = Gtk::Table.new(1,    2,    true)


options = Gtk::EXPAND|Gtk::FILL
            # child, x1, x2, y1, y2, x-opt,   y-opt,   xpad, ypad
table.attach(label1,  0,  1,  0,  1, options, options, 0,    0)
table.attach(label2,  0,  1,  1,  2, options, options, 0,    0)
table.attach(name,    ,  2,  1,  2, options, options, 0,    0)


window = Gtk::Window.new("")

window.signal_connect("destroy") { Gtk.main_quit }
hbox = Gtk::HBox.new(homogeneous=false, spacing=0) 
hbox.pack_start(scrolled_view,true,true,0)
window.add(hbox)
window.show_all
Gtk.main
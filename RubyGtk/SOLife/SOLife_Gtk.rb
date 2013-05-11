#encoding: utf-8
require 'yaml/store'
require 'yaml'
require 'gtk2'
require './SOLife_Action.rb'



current_dir = Dir.pwd
SOLife_dir  = "E:\\MyWork\\MyNote\\"
SOLife_name = File.basename(SOLife_dir)

#根据SOLife_dir显示目录
def generate_catalogue(root_dir,note_path,catalogue_array,level)
  level += 1
  if File.directory?(note_path) then
    #puts "enter:"+note_path+"-basename:"+File.basename(note_path)+"-dirname:"+File.dirname(note_path);
    if root_dir != note_path then
      catalogue_array.push([File.basename(note_path),note_path,"dir",level])
    end
    Dir.foreach(note_path) do |file|
      if file != "." and file != ".." then
        generate_catalogue(root_dir,note_path+"\\"+file,catalogue_array,level)
      end
    end
  elsif 
    #puts "file:" + note_path+"-basename:"+File.basename(note_path)+"-dirname:"+File.dirname(note_path);
    catalogue_array.push([File.basename(note_path),note_path,"file",level])
    
  end
end

catalogue = Array.new
generate_catalogue(SOLife_dir,SOLife_dir,catalogue,-1)

level_one = catalogue.select { |item| item[-1] == 1 }


#为减少压力只显示一层
tree_store = Gtk::TreeStore.new(String, String, Integer)

level_one.each do |lo|
  #level one
  tree_lo = tree_store.append(nil)
  tree_lo[0] = lo[0] #tree_level_one nodename
  tree_lo[1] = lo[1] #tree_level_one nodepath
  #tree_lo[2] = lo[2] #tree_level_one nodetype
  if lo[2]=="dir" then
   tree_lt = tree_store.append(tree_lo)
   tree_lt[0] = "loading"
   tree_lt[1] = "loading"
  end
=begin
  level_two = catalogue.select { |item| File.dirname(item[1]) == lo[1] }
  level_two.each do |lt|
    tree_lt = tree_store.append(tree_lo)
    tree_lt[0] = lt[0]
    tree_lt[1] = lt[1]
    tree_lt[2] = lt[2]
  end
=end
end



tree_view = Gtk::TreeView.new(tree_store)
tree_view.selection.mode = Gtk::SELECTION_SINGLE
#tree_view.expand_all
tree_view.hadjustment.value=100
tree_view.columns_autosize
#SELECTION_NONE
#SELECTION_BROWSE
scrolled_view = Gtk::ScrolledWindow.new
scrolled_view.border_width = 2
scrolled_view.add(tree_view)
scrolled_view.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

#目录框架
renderer = Gtk::CellRendererText.new
tree_col = Gtk::TreeViewColumn.new(SOLife_name, renderer, :text => 0)
tree_view.append_column(tree_col)

#右侧水平容器
left_hbox = Gtk::HBox.new(homogeneous=false, spacing=0) 
left_hbox.pack_start(scrolled_view,true,true,0)

#记事本框架
note_book = Gtk::Notebook.new
note_label  = Gtk::Label.new("notebooxk")
#记事本内容
text_view = Gtk::TextView.new
text_view.buffer.text = "Your 1st Gtk::TextView widget!"
text_font = Pango::FontDescription.new("Monospace Normal 10")
text_view.modify_font(text_font)
#记事本填充
note_book.append_page(text_view,note_label)

#整体布局表格
table = Gtk::Table.new(1, 4,true)




options = Gtk::EXPAND|Gtk::FILL
table.attach(left_hbox,  0,  1,  0,  1, options, options, 0,    0)
table.attach(note_book,  1,  4,  0,  1, options, options, 0,    0)



window = Gtk::Window.new("")

#点击关闭
window.signal_connect("destroy") { Gtk.main_quit }
#目录被双击时，使用记事本打开
tree_view.signal_connect("row-activated") { row_activated(tree_view,tree_store,text_view,window,note_label)}
#目录被单击时，使用记事本打开
tree_view.signal_connect("cursor-changed") { row_activated(tree_view,tree_store,text_view,window,note_label) }
window.add(table)
window.set_title("SoLife")
window.border_width = 5
window.set_size_request(800, 700)
window.show_all
Gtk.main
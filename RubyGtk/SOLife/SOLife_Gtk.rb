#encoding: utf-8
require 'yaml/store'
require 'yaml'
require 'gtk2'
require 'iconv'
require './SOLife_Action.rb'


UTF8_TO_GBK = Iconv.new "gbk", "utf-8"

current_dir = Dir.pwd
SOLife_dir  = "E:\\MyWork\\MyNote\\"
SOLife_name = File.basename(SOLife_dir)

#����SOLife_dir��ʾĿ¼
def generate_catalogue(root_dir,note_path,catalogue_array,level)
  level += 1
  
  if File.directory?(note_path) and File.basename(note_path) != ".git" then
    #puts "enter:"+note_path+"-basename:"+File.basename(note_path)+"-dirname:"+File.dirname(note_path);
    if root_dir != note_path then
      catalogue_array.push([File.basename(note_path),note_path,"dir",level])
    end
    Dir.foreach(note_path) do |file|
      if file != "." and file != ".." then
        generate_catalogue(root_dir,note_path+"\\"+file,catalogue_array,level)
      end
    end
  elsif  File.basename(note_path) != ".git"
    #puts "file:" + note_path+"-basename:"+File.basename(note_path)+"-dirname:"+File.dirname(note_path);
    catalogue_array.push([File.basename(note_path),note_path,"file",level])
    
  end
end

catalogue = Array.new
generate_catalogue(SOLife_dir,SOLife_dir,catalogue,-1)

level_one = catalogue.select { |item| item[-1] == 1 }
#puts level_one.to_s

#Ϊ����ѹ��ֻ��ʾһ��
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

#Ŀ¼���
renderer = Gtk::CellRendererText.new
tree_col = Gtk::TreeViewColumn.new(SOLife_name, renderer, :text => 0)
tree_view.append_column(tree_col)

#�Ҳ�ˮƽ����
left_hbox = Gtk::HBox.new(homogeneous=false, spacing=0) 
left_hbox.pack_start(scrolled_view,true,true,0)

#���±����
note_book = Gtk::Notebook.new
note_label  = Gtk::Label.new("notebooxk")
#���±�����
text_view = Gtk::TextView.new
text_view.buffer.text = "Your 1st Gtk::TextView widget!"
text_font = Pango::FontDescription.new("Monospace Normal 10")
text_view.modify_font(text_font)

scrolled_text = Gtk::ScrolledWindow.new
scrolled_text.border_width = 2
scrolled_text.add(text_view)
scrolled_text.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
#���±����
note_book.append_page(scrolled_text,note_label)

#���岼�ֱ��
table = Gtk::Table.new(1, 24,true)

options = Gtk::EXPAND|Gtk::FILL
table.attach(left_hbox,  0,  7,  0,  1, options, options, 0,    0)
table.attach(note_book,  7,  24,  0,  1, options, options, 0,    0)

window = Gtk::Window.new("")

#����ر�
window.signal_connect("destroy") { Gtk.main_quit }
#Ŀ¼��˫��ʱ��ʹ�ü��±���
tree_view.signal_connect("row-activated") { row_activated(tree_view,tree_store,text_view,window,note_label)}
#Ŀ¼������ʱ��ʹ�ü��±���
tree_view.signal_connect("cursor-changed") { row_activated(tree_view,tree_store,text_view,window,note_label) }
#ctrl+s�����ݼ�
ctrl_s = Gtk::AccelGroup.new
ctrl_s.connect(Gdk::Keyval::GDK_S, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  save_file(tree_view,tree_store,text_view,window)
}
#ctrl+z���¼��ı���ݼ�
ctrl_z = Gtk::AccelGroup.new
ctrl_z.connect(Gdk::Keyval::GDK_Z, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  reload_file(tree_view,tree_store,text_view,window)
}
window.add_accel_group(ctrl_s)
window.add_accel_group(ctrl_z)
#�༭�ı�״̬
text_view.buffer.signal_connect("changed"){ write_statu(tree_view,tree_store,text_view,window) }


window.add(table)
window.set_title("SoLife")
window.border_width = 5
window.set_size_request(800, 680)
window.move(600,10)
window.show_all
Gtk.main
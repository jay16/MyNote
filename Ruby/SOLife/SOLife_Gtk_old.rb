#encoding: utf-8
require 'yaml/store'
require 'yaml'
require 'gtk2'
require './SOLife_Action.rb'



current_dir = Dir.pwd.to_s
SOLife_dir  = "E:\\MyWork\\MyNote\\"
SOLife_name = File.basename(SOLife_dir)


yam_save = YAML::Store.new('SOLife.yml')

#读取配置信息 笔记目录路径数组 上次关闭时点击查看文本
if File.exists?(current_dir+"\\"+"SOLife.yml") then
  am_load = YAML.load_file('SOLife.yml')
  note_dir_list = am_load["NoteDirList"]
  note_dir_list.each do |note_path|
    #检验note_path的文件夹属性，有效性
    if File.exist(note_path) and File.directory?(note_pat) then
    end
  end
else
  InitConfig_diaog(yam_save)
end

class TextEditor
  attr_accessor :text_view, :note_label, :search
end

#根据SOLife_dir显示目录
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

#catalogue = Array.new
#generate_catalogue(SOLife_dir,SOLife_dir,catalogue,-1)

#level_one = catalogue.select { |item| item[-1] == 1 }
level_one = Array.new
Dir.foreach(SOLife_dir) do |file|
  #跳过隐藏文件
  next if file=~ /^\..*/
  file_path = SOLife_dir+"\\"+file
  level_one.push([file,file_path,File.file?(file_path) ? "file" : "dir" ])
end
#删除隐藏文件
#level_one = level_one.delete_if{ |e| e=~ /^\..*/} 
#puts level_one.to_s

#为减少压力只显示一层
note_view_store = Gtk::TreeStore.new(String, String, Integer)

level_one.each do |lo|
  #level one
  tree_lo =  note_view_store.append(nil)
  #tree_level_one nodename
  tree_lo[0] = (File.file?(lo[1]) ? "F_"+lo[0] : lo[0])

  tree_lo[1] = lo[1] #tree_level_one nodepath
  #tree_lo[2] = lo[2] #tree_level_one nodetype
  if lo[2]=="dir" then
   tree_lt = note_view_store.append(tree_lo)
   tree_lt[0] = "loading"
   tree_lt[1] = "loading"
  end
end



tree_view = Gtk::TreeView.new(note_view_store)
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
#记事本内容
text_editor = TextEditor.new
text_editor.text_view = Gtk::TextView.new
text_editor.text_view.buffer.text = "Your 1st Gtk::TextView widget!"
text_font = Pango::FontDescription.new("Monospace Normal 10")
text_editor.text_view.modify_font(text_font)
text_editor.note_label  = Gtk::Label.new("notebooxk")

scrolled_text = Gtk::ScrolledWindow.new
scrolled_text.border_width = 2
scrolled_text.add(text_editor.text_view)
scrolled_text.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
#记事本填充
note_book.append_page(scrolled_text,text_editor.note_label)

#整体布局表格
table = Gtk::Table.new(1, 24,true)

options = Gtk::EXPAND|Gtk::FILL
table.attach(left_hbox,  0,  7,  0,  1, options, options, 0,    0)
table.attach(note_book,  7,  24,  0,  1, options, options, 0,    0)

window = Gtk::Window.new("")

#点击关闭
window.signal_connect("destroy") { Gtk.main_quit }
#目录被双击时，使用记事本打开
tree_view.signal_connect("row-activated") { row_activated(tree_view,note_view_store,text_editor,window)}
#目录被单击时，使用记事本打开
tree_view.signal_connect("cursor-changed") { row_activated(tree_view,note_view_store,text_editor,window) }
#ctrl+s保存文件快捷键
ctrl_s = Gtk::AccelGroup.new
ctrl_s.connect(Gdk::Keyval::GDK_S, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  save_file(tree_view,note_view_store,text_editor,window)
}
#ctrl+z重新加载文本快捷键
ctrl_z = Gtk::AccelGroup.new
ctrl_z.connect(Gdk::Keyval::GDK_Z, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  reload_file(tree_view,note_view_store,text_editor,window)
}
#ctrl+n新建文本快捷键,直接创建textview，保存时再选新文本位置与文本名称
ctrl_n = Gtk::AccelGroup.new
ctrl_n.connect(Gdk::Keyval::GDK_N, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  new_file(text_editor,window)
}
window.add_accel_group(ctrl_s)
window.add_accel_group(ctrl_z)
window.add_accel_group(ctrl_n)
#编辑文本状态
text_editor.text_view.buffer.signal_connect("changed"){ write_statu(tree_view,note_view_store,text_editor,window) }


window.add(table)
window.set_title("SoLife")
window.border_width = 5
window.set_size_request(800, 680)
window.move(600,10)
window.show_all
Gtk.main
#encoding: utf-8
require 'yaml/store'
require 'yaml'
require 'gtk2'
require './solife_action.rb'
require './solife_notebook.rb'



current_dir = Dir.pwd.to_s
SOLife_dir  = "E:\\MyWork\\MyNote\\"
SOLife_name = File.basename(SOLife_dir)

conf_path = current_dir+"\\solife.yml"

conf_save = YAML::Store.new(conf_path)
conf_load = String.new

note_dir_list    = Array.new
note_seled_dir   = String.new
note_seled_file  = String.new

def check_conf(conf_path)
  if File.exists?(conf_path) and YAML.load_file(conf_path)["NoteDirList"] then
     return true
  else
     return false
  end
end

#读取配置信息 笔记目录路径数组 上次关闭时点击查看文本
#不存在配置文件启动显示配置界面
if check_conf(conf_path) then
  conf_load       = YAML.load_file(conf_path)
  note_dir_list   = conf_load["NoteDirList"]
  note_seled_dir  = conf_load["NoteSeledDir"]
  note_seled_file = conf_load["NoteSeledFile"]
  if !note_seled_dir then
    note_seled_dir  = note_dir_list[0]
  end
else
  InitConfig_diaog(conf_save)
  if check_conf(conf_path) then
    conf_load       = YAML.load_file(conf_path)
    note_dir_list   = conf_load["NoteDirList"]
    note_seled_dir  = note_dir_list[0]
  else
    return false
  end
end


class TextEditor
  attr_accessor :text_view, :note_label, :search
end



#note_tree
note_tree_store = Gtk::TreeStore.new(String, String, Integer)

#目录框架
renderer = Gtk::CellRendererText.new
tree_col = Gtk::TreeViewColumn.new(File.basename(note_seled_dir), renderer, :text => 0)

g_note_tree(note_tree_store,note_seled_dir)

tree_note_view = Gtk::TreeView.new(note_tree_store)
tree_note_view.selection.mode = Gtk::SELECTION_SINGLE
#tree_note_view.expand_all
tree_note_view.hadjustment.value=100
tree_note_view.columns_autosize
tree_note_view.append_column(tree_col)
#SELECTION_NONE
#SELECTION_BROWSE
scrolled_notetree_note_view = Gtk::ScrolledWindow.new
scrolled_notetree_note_view.border_width = 2
scrolled_notetree_note_view.add(tree_note_view)
scrolled_notetree_note_view.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)



#根据note_dir_list数据组显示目录
scrolled_notelist_view = g_note_list(note_tree_store,note_dir_list,conf_save)

#根据note 点击记录 列表 显示目录
g_history = g_historylist_view(note_dir_list)
scrolled_history_view = g_history[0]
tree_history_view         = g_history[1]
note_history_store        = g_history[2]


left_table = Gtk::Table.new(4, 1,true)

options = Gtk::EXPAND|Gtk::FILL
left_table.attach(scrolled_notetree_note_view,  0,  1,  0,  2, options, options, 0,    0)
left_table.attach(scrolled_notelist_view,  0,  1,  2,  3, options, options, 0,    0)
left_table.attach(scrolled_history_view,  0,  1,  3,  4, options, options, 0,    0)

#左侧水平容器
left_vbox = Gtk::VBox.new(homogeneous=false, spacing=nil) 
left_vbox.pack_start_defaults(left_table)

#记事本框架
note_book = Gtk::Notebook.new
#自动生成滚动条
note_book.scrollable  = true
#标签label等宽
note_book.homogeneous = true
note_book.show_border = true
#记事本内容
text_editor = TextEditor.new
text_editor.text_view = Gtk::TextView.new
text_editor.text_view.buffer.text = "Your 1st Gtk::TextView widget!"
text_font = Pango::FontDescription.new("Monospace Normal 10")
#记事本应用字体
text_editor.text_view.modify_font(text_font)
#记事本中允许自动换行
text_editor.text_view.wrap_mode = Gtk::TextTag::WRAP_WORD
text_editor.text_view.editable =  true
text_editor.text_view.cursor_visible =  true
text_editor.text_view.left_margin = 10
text_editor.note_label  = Gtk::Label.new("notebooxk")


scrolled_text = Gtk::ScrolledWindow.new
scrolled_text.border_width = 2
scrolled_text.add(text_editor.text_view)
scrolled_text.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
#记事本填充
note_book.append_page(scrolled_text,text_editor.note_label)
#note_book.insert_page(-1,text_editor.text_view,text_editor.note_label)

#整体布局表格
table = Gtk::Table.new(1, 24,true)

options = Gtk::EXPAND|Gtk::FILL
table.attach(left_vbox,  0,  7,  0,  1, options, options, 0,    0)
table.attach(note_book,  7,  24,  0,  1, options, options, 0,    0)

window = Gtk::Window.new("")

#点击关闭
window.signal_connect("destroy") { window_exit(tree_note_view,window,conf_save) }
#目录被双击时，使用记事本打开
tree_note_view.signal_connect("row-activated") { row_activated(tree_note_view,note_tree_store,text_editor,note_history_store,window,conf_save)}
#阅读历史列表被双击时，使用记事本打开
tree_history_view.signal_connect("row-activated") { read_by_history(tree_history_view,text_editor,window,conf_save)}
#目录被单击时，使用记事本打开
#tree_note_view.signal_connect("cursor-changed") { row_activated(tree_note_view,note_tree_store,text_editor,window) }
#ctrl+s保存文件快捷键
ctrl_s = Gtk::AccelGroup.new
ctrl_s.connect(Gdk::Keyval::GDK_S, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  save_file(tree_note_view,note_tree_store,text_editor,note_history_store,window)
}
window.add_accel_group(ctrl_s)
#ctrl+z重新加载文本快捷键
ctrl_z = Gtk::AccelGroup.new
ctrl_z.connect(Gdk::Keyval::GDK_Z, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  reload_file(tree_note_view,note_tree_store,text_editor,window)
}
window.add_accel_group(ctrl_z)
#ctrl+n新建文本快捷键,直接创建textview，保存时再选新文本位置与文本名称
ctrl_n = Gtk::AccelGroup.new
ctrl_n.connect(Gdk::Keyval::GDK_N, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  new_file(text_editor,window)
}

window.add_accel_group(ctrl_n)
#ctrl+p notebook标签页向前切换P
ctrl_p = Gtk::AccelGroup.new
ctrl_p.connect(Gdk::Keyval::GDK_P, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  notebook_prepage(note_book,window)
}
window.add_accel_group(ctrl_p)
#编辑文本状态
text_editor.text_view.buffer.signal_connect("changed"){ write_statu(tree_note_view,note_tree_store,text_editor,window) }


window.add(table)
window.set_title("SoLife")
window.border_width = 5
window.set_size_request(800, 680)
window.move(600,10)
window.show_all
Gtk.main
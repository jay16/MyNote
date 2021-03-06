#encoding: utf-8
require 'yaml/store'
require 'yaml'
require 'gtk2'
require './solife_treeview.rb'
require './solife_notebook.rb'
require './solife_action.rb'
require './solife_accel.rb'



current_dir = Dir.pwd.to_s
SOLife_dir  = "E:\\MyWork\\MyNote\\"
SOLife_name = File.basename(SOLife_dir)

conf_path = current_dir+"\\solife.yml"

conf_save = YAML::Store.new(conf_path)
conf_load = String.new

note_dir_list     = Array.new
note_seled_dir    = String.new
note_seled_file   = String.new
note_history_list = Array.new

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
  #常用路径列表
  note_dir_list   = conf_load["NoteDirList"]
  #关闭前最后打开目录路径
  note_seled_dir  = conf_load["NoteSeledDir"]
  #闭关前最后打开的文件路径
  note_seled_file = conf_load["NoteSeledFile"]
  #历史点击记录列表
  note_history_list = conf_load["HistoryList"]
  if !note_seled_dir then
    note_seled_dir  = note_dir_list[0]
  end
else
  InitConfig_diaog(conf_save,conf_load)
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
note_view_store = Gtk::TreeStore.new(String, String, Integer)

#目录主要框架
renderer = Gtk::CellRendererText.new
tree_col = Gtk::TreeViewColumn.new(File.basename(note_seled_dir), renderer, :text => 0)

#更新目录内容
update_tree_view(note_view_store,note_seled_dir)

note_view_tree = Gtk::TreeView.new(note_view_store)
note_view_tree.selection.mode = Gtk::SELECTION_SINGLE
#note_view_tree.expand_all
note_view_tree.hadjustment.value=100
note_view_tree.columns_autosize
note_view_tree.append_column(tree_col)
#SELECTION_NONE
#SELECTION_BROWSE
scrolled_notenote_view_tree = Gtk::ScrolledWindow.new
scrolled_notenote_view_tree.border_width = 2
scrolled_notenote_view_tree.add(note_view_tree)
scrolled_notenote_view_tree.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)


#常用路径目录
#根据note_dir_list数据组显示目录
g_notelist_tree = g_note_list(note_view_store,note_dir_list,conf_save)
scrolled_notelist_view = g_notelist_tree[0]
note_list_tree         = g_notelist_tree[1]
note_list_store        = g_notelist_tree[2]

#点击历史路径目录
#根据note 点击记录 列表 显示目录
g_history_tree = g_historylist_view(note_dir_list)
scrolled_history_view     = g_history_tree[0]
note_history_tree         = g_history_tree[1]
note_history_store        = g_history_tree[2]


left_table = Gtk::Table.new(4, 1,true)

options = Gtk::EXPAND|Gtk::FILL
left_table.attach(scrolled_notenote_view_tree,  0,  1,  0,  2, options, options, 0,    0)
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
layout_table = Gtk::Table.new(1, 24,true)

options = Gtk::EXPAND|Gtk::FILL
layout_table.attach(left_vbox,  0,  7,  0,  1, options, options, 0,    0)
layout_table.attach(note_book,  7,  24,  0,  1, options, options, 0,    0)

window = Gtk::Window.new("")

#点击关闭
window.signal_connect("destroy") { window_exit(note_view_tree,window,conf_save) }
#目录被双击时，使用记事本打开
note_view_tree.signal_connect("row-activated") { row_activated(note_view_tree,note_view_store,text_editor,note_history_store,window,conf_save)}
#阅读历史列表被双击时，使用记事本打开
note_history_tree.signal_connect("row-activated") { 
 click_history_tree(note_view_tree,note_view_store,note_history_tree,note_history_store,text_editor,window,conf_save)
}
#目录被单击时，使用记事本打开
#note_view_tree.signal_connect("cursor-changed") { row_activated(note_view_tree,note_view_store,text_editor,window) }
#ctrl+s保存文件快捷键
ctrl_s = Gtk::AccelGroup.new
ctrl_s.connect(Gdk::Keyval::GDK_S, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  save_file(note_view_tree,note_view_store,text_editor,note_history_tree,note_history_store,window,conf_save)
}
window.add_accel_group(ctrl_s)
#ctrl+z重新加载文本快捷键
ctrl_z = Gtk::AccelGroup.new
ctrl_z.connect(Gdk::Keyval::GDK_Z, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  reload_file(note_view_tree,note_view_store,text_editor,window)
}
window.add_accel_group(ctrl_z)

#ctrl+n新建文本快捷键,直接创建textview，保存时再选新文本位置与文本名称
ctrl_n = Gtk::AccelGroup.new
ctrl_n.connect(Gdk::Keyval::GDK_N, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  new_file(text_editor,window)
}
window.add_accel_group(ctrl_n)

#ctrl+m隐藏/显示目录
ctrl_m = Gtk::AccelGroup.new
ctrl_m.connect(Gdk::Keyval::GDK_M, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  hide_show_cattree(layout_table,left_vbox,window)
}
window.add_accel_group(ctrl_m)

#F10显示帮助档
F10 = Gtk::AccelGroup.new
F10.connect(Gdk::Keyval::GDK_F10, 0, Gtk::ACCEL_VISIBLE) {
  InitConfig_diaog(conf_save,conf_load)
}
window.add_accel_group(F10)

#ctrl+p notebook标签页向前切换P
ctrl_p = Gtk::AccelGroup.new
ctrl_p.connect(Gdk::Keyval::GDK_P, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  notebook_prepage(note_book,window)
}
window.add_accel_group(ctrl_p)
#编辑文本状态
text_editor.text_view.buffer.signal_connect("changed"){ write_statu(note_view_tree,note_view_store,text_editor,window) }

#详细目录列表树 - 鼠标右键pop-up menu
note_view_popmenu = Gtk::Menu.new
note_view_popmenu.append(mitem_new_file = Gtk::MenuItem.new("New File"))
note_view_popmenu.append(mitem_new_dir = Gtk::MenuItem.new("New Dir"))
note_view_popmenu.append(mitem_add_dir_tolist = Gtk::MenuItem.new("Add Dir To Fav"))
note_view_popmenu.show_all
note_view_tree.add_events(Gdk::Event::BUTTON_PRESS_MASK)
note_view_tree.signal_connect("button_press_event") do |widget, event|
   if (event.button == 3) then
     note_view_popaction(widget,event,note_view_popmenu)
   end
end
#点击菜单项后响应-详细目录树中某常用路径添加至常用NoteList tree中
mitem_add_dir_tolist.signal_connect('activate') { |w| add_dir_tolist(note_view_tree,note_list_store,window,conf_save) }
mitem_new_file.signal_connect('activate') { |w| new_file(text_editor,window) }


note_list_popmenu = Gtk::Menu.new
note_list_popmenu.append(mitem_remove_fromlist = Gtk::MenuItem.new("Remove It"))
note_list_popmenu.show_all
note_list_tree.add_events(Gdk::Event::BUTTON_PRESS_MASK)
note_list_tree.signal_connect("button_press_event") do |widget, event|
   if (event.button == 3) then
     #只是弹出菜单项这个动作而已
     note_view_popaction(widget,event,note_list_popmenu)
   end
end
mitem_remove_fromlist.signal_connect('activate') { |w| del_dir_fromlist(note_list_tree,note_list_store,window,conf_save) }



window.add(layout_table)
window.set_title("SoLife")
window.border_width = 5
window.set_size_request(800, 680)
window.move(600,10)

#打开上次关闭前最后打开的文件,判断文件存在，并且属性是文件
if note_seled_file and File.exist?(note_seled_file) and File.file?(note_seled_file) then

  #详细目录列表中设置该文件处于选中状态
  trigger_row_activated(note_view_tree,note_view_store,text_editor,note_history_store,window,[File.basename(note_seled_file),note_seled_file],conf_save)
  #激活虚拟点击详细目录动作，加载内容
  row_activated(note_view_tree,note_view_store,text_editor,note_history_store,window,conf_save)
end

#加载点击文件历史列表目录
#过滤出当前详细目录中的点击文件路径
current_dir_list = Array.new
if note_history_list.length > 0 then
  note_history_list.select do |node|
    if node[1].include?(note_seled_dir)
      current_dir_list.push(node)
      puts "history include:#{node[1]}-#{note_seled_dir}"
    else
      puts "history not include:#{node[1]}-#{note_seled_dir}"
    end
  end
  current_dir_list.sort!{ |x,y| y[2] <=> x[2] }
  puts "current_dir_list:#{current_dir_list.length}"
  current_dir_list.each do |note_path|
    is_exist = false
    iter = note_history_store.iter_first
    if iter then
      begin
        if  iter[1] == note_path[1] then
          is_exist = true
          break
        end
      end while iter.next!
    end
    if !is_exist then
     note_store = note_history_store.append(nil)
     note_store[0] = File.basename(note_path[1]) + " - " + note_path[2].to_s
     note_store[1] = note_path[1]
     note_store[2] = note_path[2]
     puts "History Insert:#{note_path[1]}"
    end
  end
end
window.show_all
Gtk.main
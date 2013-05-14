#encoding: utf-8
require 'yaml/store'
require 'yaml'
require 'gtk2'
require './SOLife_Action.rb'



current_dir = Dir.pwd.to_s
SOLife_dir  = "E:\\MyWork\\MyNote\\"
SOLife_name = File.basename(SOLife_dir)


yam_save = YAML::Store.new('SOLife.yml')
note_dir_list = Array.new
#��ȡ������Ϣ �ʼ�Ŀ¼·������ �ϴιر�ʱ����鿴�ı�
if File.exists?(current_dir+"\\"+"SOLife.yml") then
  am_load = YAML.load_file('SOLife.yml')
  note_dir_list = am_load["NoteDirList"]
  #note_dir_list = note_dir_list.delete_if { |note_path| !File.exist?(note_path) or File.directory?(note_path)  }
  #note_dir_list.each do |note_path|
  #  #����note_path���ļ������ԣ���Ч��
  #  if !File.exist(note_path) or File.directory?(note_path) then
  #  end
  #end
else
  InitConfig_diaog(yam_save)
end

class TextEditor
  attr_accessor :text_view, :note_label, :search
end



#note_tree
note_tree_store = Gtk::TreeStore.new(String, String, Integer)

#Ŀ¼���
renderer = Gtk::CellRendererText.new
tree_col = Gtk::TreeViewColumn.new(SOLife_name, renderer, :text => 0)

g_note_tree(note_tree_store,SOLife_dir)

tree_view = Gtk::TreeView.new(note_tree_store)
tree_view.selection.mode = Gtk::SELECTION_SINGLE
#tree_view.expand_all
tree_view.hadjustment.value=100
tree_view.columns_autosize
tree_view.append_column(tree_col)
#SELECTION_NONE
#SELECTION_BROWSE
scrolled_view = Gtk::ScrolledWindow.new
scrolled_view.border_width = 2
scrolled_view.add(tree_view)
scrolled_view.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)



#����note_dir_list��������ʾĿ¼
scrolled_notelist_view = g_note_list(note_tree_store,note_dir_list)


#���ˮƽ����
left_vbox = Gtk::VBox.new(homogeneous=false, spacing=nil) 
left_vbox.pack_start_defaults(scrolled_view)
left_vbox.pack_start_defaults(scrolled_notelist_view)

#���±����
note_book = Gtk::Notebook.new
#���±�����
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
#���±����
note_book.append_page(scrolled_text,text_editor.note_label)

#���岼�ֱ��
table = Gtk::Table.new(1, 24,true)

options = Gtk::EXPAND|Gtk::FILL
table.attach(left_vbox,  0,  7,  0,  1, options, options, 0,    0)
table.attach(note_book,  7,  24,  0,  1, options, options, 0,    0)

window = Gtk::Window.new("")

#����ر�
window.signal_connect("destroy") { Gtk.main_quit }
#Ŀ¼��˫��ʱ��ʹ�ü��±���
tree_view.signal_connect("row-activated") { row_activated(tree_view,note_tree_store,text_editor,window)}
#Ŀ¼������ʱ��ʹ�ü��±���
tree_view.signal_connect("cursor-changed") { row_activated(tree_view,note_tree_store,text_editor,window) }
#ctrl+s�����ļ���ݼ�
ctrl_s = Gtk::AccelGroup.new
ctrl_s.connect(Gdk::Keyval::GDK_S, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  save_file(tree_view,note_tree_store,text_editor,window)
}
#ctrl+z���¼����ı���ݼ�
ctrl_z = Gtk::AccelGroup.new
ctrl_z.connect(Gdk::Keyval::GDK_Z, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  reload_file(tree_view,note_tree_store,text_editor,window)
}
#ctrl+n�½��ı���ݼ�,ֱ�Ӵ���textview������ʱ��ѡ���ı�λ�����ı�����
ctrl_n = Gtk::AccelGroup.new
ctrl_n.connect(Gdk::Keyval::GDK_N, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  new_file(text_editor,window)
}
window.add_accel_group(ctrl_s)
window.add_accel_group(ctrl_z)
window.add_accel_group(ctrl_n)
#�༭�ı�״̬
text_editor.text_view.buffer.signal_connect("changed"){ write_statu(tree_view,note_tree_store,text_editor,window) }


window.add(table)
window.set_title("SoLife")
window.border_width = 5
window.set_size_request(800, 680)
window.move(600,10)
window.show_all
Gtk.main
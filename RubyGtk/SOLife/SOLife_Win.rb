#encoding: utf-8
require 'yaml/store'
require 'yaml'
require 'gtk2'



current_dir = Dir.pwd
SOLife_dir  = "E:\\MyWork\\MyNote\\"

require './SOLife_Action.rb'


treestore = Gtk::TreeStore.new(String, String, Integer)


note_load.each do |one|
  # Append a second toplevel row and fill in some data
  parent = treestore.append(nil)
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

view = Gtk::TreeView.new(treestore)
view.selection.mode = Gtk::SELECTION_SINGLE
view.expand_all
view.hadjustment.value=100
view.columns_autosize
#SELECTION_NONE
#SELECTION_BROWSE
scrolled_view = Gtk::ScrolledWindow.new
scrolled_view.border_width = 2
scrolled_view.add(view)
scrolled_view.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

menu = Gtk::Menu.new
mitem1 = Gtk::MenuItem.new("CreateChild")
menu.append(mitem1)
mitem1.label="Create_Type"
menu.show_all


view.add_events(Gdk::Event::BUTTON_PRESS_MASK)
view.signal_connect("button_press_event") do |widget, event|
  if (event.button == 3)
    menu.popup(nil, nil, event.button, event.time)
  end	
end

# Create a renderer
renderer = Gtk::CellRendererText.new
# Add column using our renderer
col = Gtk::TreeViewColumn.new("Theme", renderer, :text => 0)
view.append_column(col)



#vbox = Gtk::VBox.new(homogeneous=false, spacing=nil) 
btn_save = Gtk::Button.new("save")
add_theme = Gtk::Button.new("+theme")
add_segment = Gtk::Button.new("+segment")

#search for...
entry_find      = Gtk::Entry.new
entry_find.text = "Search for ..."
btn_find       = Gtk::Button.new(Gtk::Stock::FIND)
hbox_find = Gtk::HBox.new(false, 5)
hbox_find.pack_start_defaults(entry_find)
hbox_find.pack_start_defaults(btn_find)


#vbox.pack_start(scrolled_view,true,true,0)
#vbox.pack_start(btn_save,false,false,0)
#vbox.pack_start(add_theme,false,false,0)
#vbox.pack_start(add_segment,false,false,0)

textview = Gtk::TextView.new
textview.buffer.text = "Your 1st Gtk::TextView widget!"
font = Pango::FontDescription.new("Monospace Normal 10")
textview.modify_font(font)




scrolled_win = Gtk::ScrolledWindow.new(nil,nil)
scrolled_win.border_width = 3
scrolled_win.add(textview)
scrolled_win.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
scrolled_win.set_window_placement(Gtk::CORNER_BOTTOM_RIGHT)
scrolled_win.shadow_type=(Gtk::SHADOW_ETCHED_OUT)

textview.signal_connect("size-allocate") do |widget, step, arg2|
  scrolled_win.vadjustment.value = scrolled_win.vadjustment.upper - scrolled_win.vadjustment.page_size
end

vbox_view = Gtk::VBox.new(false, 5)
vbox_view.pack_start(scrolled_win, true,  true, 0)
vbox_view.pack_start(hbox_find,         false, true, 0)

hbox = Gtk::HBox.new(homogeneous=false, spacing=0) 
#hbox.pack_start(scrolled_view,true,true,0)
#hbox.pack_start(vbox_view,true,true,0)
#hbox.pack_start(vvbox,false,false,0)

window = Gtk::Window.new("")

window.signal_connect("destroy") { window_exit(view,treestore,note_record,window) }

textview.buffer.create_tag("highlight", {"background" => "#f8d60d", "foreground" => "purple"})
btn_find.signal_connect('clicked') { search(entry_find, textview) }
view.signal_connect("row-activated") { row_activated(view,treestore,textview,window,cur_dir)}
textview.buffer.signal_connect("changed"){ write_statu(view,treestore,textview,window) }
btn_save.signal_connect("clicked") { save_file(view,treestore,textview,window,cur_dir) }
add_theme.signal_connect("clicked") { add_theme(view,note_save) }
add_segment.signal_connect("clicked") { add_segment(view,treestore,note_save) }
mitem1.signal_connect('activate') { add_node(view,treestore,note_save,note_load,cur_dir) }
view.selection.select_path(Gtk::TreePath.new(note_init["row"]["selected"]["path"]))

yaml_path = note_init["row"]["selected"]["yaml"].split(":")
textview.buffer.text = yaml_path.join(":")
yml_file = File.join(cur_dir,"note",yaml_path[0],yaml_path[1],"#{yaml_path[2]}.yml") if yaml_path.length==3
textview.buffer.text = YAML.load_file(yml_file)["content"] if yaml_path.length==3 and File.exist?(yml_file)

ag = Gtk::AccelGroup.new
#ctrl+s save
ag.connect(Gdk::Keyval::GDK_S, Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE) {
  save_file(view,treestore,textview,window,cur_dir)
}
window.add_accel_group(ag)

window.set_title("SoLife")
window.border_width = 5
window.set_size_request(800, 700)
window.set_default_size(800,700)

#window.set_window_position(Gtk::Window::POS_NONE)
window.move(500,0)
hbox.pack_start(scrolled_view,true,true,0)
hbox.pack_start(vbox_view,true,true,0)
#window.add(scrolled_view)
#window.add(vbox_view)
window.add(hbox)
window.show_all
Gtk.main
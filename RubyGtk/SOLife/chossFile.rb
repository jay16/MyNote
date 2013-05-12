#!/usr/bin/env ruby
require 'gtk2'

# It is imperative to understand what is happening in "folder_changed"
# First note, that both "folder" (dir) and "file" buttons are passed
# into the method. This is because we want the two buttons to be related. 
# The first "folder" button should provide the directory from which 
# the second button should by default pick a file.

def  folder_changed(choo_dir, window)
  dir = choo_dir.filename
  #choo_file.current_folder = dir
  window.set_title(dir)
end

def file_changed(choo_file, lab)
  file = choo_file.filename
  file = "" if file == nil
  lab.text = file
end
window = Gtk::Window.new("File Chooser Buttons")
window.border_width = 10
window.signal_connect('destroy') { Gtk.main_quit }

label = Gtk::Label.new
choo_dir_btt  = Gtk::FileChooserButton.new(
    "Choose a Folder", Gtk::FileChooser::ACTION_SELECT_FOLDER)
choo_file_btt = Gtk::FileChooserButton.new(
    "Choose a File", Gtk::FileChooser::ACTION_OPEN)

# Let's add an extra widget (a button) to the {{ dialog }}
extra_button1 = Gtk::Button.new("Extra button")
extra_button2 = Gtk::Button.new("Extra button #2")
choo_file_btt.extra_widget = extra_button1
choo_dir_btt.extra_widget  = extra_button2

choo_dir_btt.signal_connect('selection_changed') do |w|
  # puts "In choo_dir_btt(): #{w.class}=#{w}"   # <<< Gtk::FileChooserButton=choo_dir_btt
  folder_changed(w, window)
end
choo_file_btt.signal_connect('selection_changed') do |w|
  # puts "In choo_file_btt(): #{w.class}=#{w}"  # <<< w=Gtk::FileChooserButton=choo_file_btt
  file_changed(choo_file_btt, label)
end
extra_button1.signal_connect("clicked") do
  puts "extra button #1 clicked"
end
extra_button2.signal_connect("clicked") do
  puts "extra button #2 clicked"
end

choo_dir_btt.current_folder  = GLib.home_dir
# choo_file_btt.current_folder = "/tmp"  # <--- will have no effect, since callback overrides it 
# choo_file_btt.filename = "/home/iwk/wk/a_cfile.c" # <--- would work if file existed

filter1 = Gtk::FileFilter.new
filter2 = Gtk::FileFilter.new
filter1.name = "Image Files"
filter2.name = "All Files"
filter1.add_pattern('*.png')
filter1.add_pattern('*.jpg')
filter1.add_pattern('*.gif')
filter2.add_pattern('*')
choo_file_btt.add_filter(filter2) # 1st added will be the default
choo_file_btt.add_filter(filter1)

vbox = Gtk::VBox.new(true, 5)
vbox.pack_start_defaults(choo_dir_btt)
vbox.pack_start_defaults(choo_file_btt)
vbox.pack_start_defaults(label)

window.add(vbox)
window.show_all
Gtk.main
#!/usr/bin/env ruby
require 'gtk2'

# Create a new message dialogue telling the user that button was clicked.
def  folder_changed(choo_dir, choo_file)
  dir = choo_dir.filename
  choo_file.current_folder = dir
end


def button_clicked (show_label,parent)
  dialog = Gtk::Dialog.new(
      "Information",
      parent,
      Gtk::Dialog::MODAL,
      [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK ]
  )
  dialog.has_separator = false
  label = Gtk::Label.new("The button was clicked!")
  image = Gtk::Image.new(Gtk::Stock::DIALOG_INFO, Gtk::IconSize::DIALOG)
  radio1 = Gtk::RadioButton.new(Dir.pwd.to_s)
  radio2 = Gtk::RadioButton.new(radio1, "")
  choo_dir_btt  = Gtk::FileChooserButton.new(
    "Choose a Folder", Gtk::FileChooser::ACTION_SELECT_FOLDER)
  choo_dir_btt.signal_connect('selection_changed') do |w|
  # puts "In choo_dir_btt(): #{w.class}=#{w}"   # <<< Gtk::FileChooserButton=choo_dir_btt
  folder_changed(w, show_label)
end

  hbox_1 = Gtk::HBox.new(false, 5)
  hbox_1.border_width = 10
  hbox_1.pack_start_defaults(radio1);
  hbox_2 = Gtk::HBox.new(false, 5)
  hbox_2.border_width = 10
  hbox_2.pack_start_defaults(radio2);
  hbox_2.pack_start_defaults(choo_dir_btt);

  # Add the message in a label, and show everything we've added to the dialog.
  # dialog.vbox.pack_start_defaults(hbox) # Also works, however dialog.vbox
                                          # limits a single item (element).
  dialog.vbox.add(hbox_1)
  dialog.vbox.add(hbox_2)
  dialog.show_all
  dialog.run
  dialog.destroy
end

window = Gtk::Window.new
window.border_width = 10
window.set_size_request(200, -1)
window.title = "Dialogs"
window.signal_connect('delete_event') { false }
window.signal_connect('destroy') { Gtk.main_quit }

show_label =  Gtk::Label.new("The button was clicked!")

button = Gtk::Button.new("_Click Me")
button.signal_connect('clicked') { button_clicked(show_label,window) }
vbox = Gtk::VBox.new(true, 5)
vbox.add(button)
vbox.add(show_label)

window.add(vbox)
window.show_all
Gtk.main
#!/usr/bin/env ruby
require 'gtk2'

# Create a new message dialogue telling the user that button was clicked.
def button_clicked (parent)
  dialog = Gtk::Dialog.new(
      "Information",
      parent,
      Gtk::Dialog::MODAL,
      [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK ]
  )
  dialog.has_separator = false
  label = Gtk::Label.new("The button was clicked!")
  image = Gtk::Image.new(Gtk::Stock::DIALOG_INFO, Gtk::IconSize::DIALOG)

  hbox_1 = Gtk::HBox.new(false, 5)
  hbox_1.border_width = 10
  hbox_1.pack_start_defaults(image);
  hbox_1.pack_start_defaults(label);
  hbox_1 = Gtk::HBox.new(false, 5)
  hbox_1.border_width = 10
  hbox_1.pack_start_defaults(image);
  hbox_1.pack_start_defaults(label);

  # Add the message in a label, and show everything we've added to the dialog.
  # dialog.vbox.pack_start_defaults(hbox) # Also works, however dialog.vbox
                                          # limits a single item (element).
  dialog.vbox.add(hbox)
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

button = Gtk::Button.new("_Click Me")
button.signal_connect('clicked') { button_clicked(window) }

window.add(button)
window.show_all
Gtk.main
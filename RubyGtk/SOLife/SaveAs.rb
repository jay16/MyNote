#!/usr/bin/env ruby
require 'gtk2'

# Allow the user to enter a new file name and location for
# the file and set the button to the text of the location.
def button_clicked (parent, btt)
  dialog = Gtk::FileChooserDialog.new(
      "Save File As ...",
      parent,
      Gtk::FileChooser::ACTION_SAVE,
      nil,
      [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ],
      [ Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_ACCEPT ]
  )
  dialog.signal_connect('response') do |w, r|
    odg = case r
      when Gtk::Dialog::RESPONSE_ACCEPT
        filename = dialog.filename
        btt.label = filename
        "'ACCEPT' (#{r}) button pressed -- filename is {{ #{filename} }}"
      when Gtk::Dialog::RESPONSE_CANCEL;   "'CANCEL' (#{r}) button pressed"
      else; "Undefined response ID; perhaps Close-x? (#{r})"
    end
    puts odg
    dialog.destroy 
  end
  dialog.run
end

window = Gtk::Window.new("Save a File")
window.border_width = 10
window.set_size_request(200, -1)
window.signal_connect('destroy') { Gtk.main_quit }

button = Gtk::Button.new("Save As ...")
button.signal_connect('clicked') { button_clicked(window, button) }

window.add(button)
window.show_all
Gtk.main
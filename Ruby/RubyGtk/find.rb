#!/usr/bin/env ruby
require 'gtk2'

# Search for the entered string within the GtkTextView.
# Then tell the user how many times it was found.
def search(ent, txtvu)
  start = txtvu.buffer.start_iter
  first, last = start.forward_search(ent.text, Gtk::TextIter::SEARCH_TEXT_ONLY, nil)
  count = 0
  while (first)
    start.forward_char
    first, last = start.forward_search(ent.text, Gtk::TextIter::SEARCH_TEXT_ONLY, nil)
    start = first
    txtvu.buffer.apply_tag("highlight", first, last)
    count += 1
  end

  dialogue = Gtk::MessageDialog.new(
            nil,
            Gtk::Dialog::MODAL,
            Gtk::MessageDialog::INFO, 
            Gtk::MessageDialog::BUTTONS_OK,
             "The string #{ent.text} was found #{count} times!"
  )
  dialogue.run
  dialogue.destroy
end

window = Gtk::Window.new("Searching & Text Tags")
window.resizable = true
window.border_width = 10
window.signal_connect('destroy') { Gtk.main_quit }
window.set_size_request(250, 200)

textview = Gtk::TextView.new

textview.buffer.create_tag("highlight", {"background" => "#f8d60d", "foreground" => "red"})
entry      = Gtk::Entry.new
entry.text = "Search for ..."
find       = Gtk::Button.new(Gtk::Stock::FIND)

find.signal_connect('clicked') { search(entry, textview) }

scrolled_win = Gtk::ScrolledWindow.new
scrolled_win.add(textview)
scrolled_win.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

hbox = Gtk::HBox.new(false, 5)
hbox.pack_start_defaults(entry)
hbox.pack_start_defaults(find)
vbox = Gtk::VBox.new(false, 5)
vbox.pack_start(scrolled_win, true,  true, 0)
vbox.pack_start(hbox,         false, true, 0)
window.add(vbox)
window.show_all
Gtk.main
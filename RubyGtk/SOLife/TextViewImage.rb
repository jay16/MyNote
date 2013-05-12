#!/usr/bin/env ruby
require 'gtk2'

window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
window.resizable = true
window.title = "Pixbufs"
window.border_width = 10
window.signal_connect('delete_event') { Gtk.main_quit }
window.set_size_request(200, 150)

textview = Gtk::TextView.new
textview.buffer.text = " Undo\n Redo"

# Create two images and insert them into the text buffer.
undo_pb = Gdk::Pixbuf.new("intfocus_logo.png");
iter = textview.buffer.get_iter_at_line(0)
textview.buffer.insert_pixbuf(iter, undo_pb)
redo_pb = Gdk::Pixbuf.new("intfocus_logo.png");
iter = textview.buffer.get_iter_at_line(1)
textview.buffer.insert_pixbuf(iter, redo_pb)

scrolled_win = Gtk::ScrolledWindow.new
scrolled_win.border_width = 5
scrolled_win.add(textview)
scrolled_win.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS)
window.add(scrolled_win)
window.show_all
Gtk.main
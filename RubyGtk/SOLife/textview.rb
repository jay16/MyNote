#!/usr/bin/env ruby
require 'gtk2'

def destroy; Gtk.main_quit; end

window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
window.resizable = true
window.title = "Text View Properties"
window.border_width = 10
window.signal_connect('delete_event') { destroy }
window.set_size_request(250, 150)

textview = Gtk::TextView.new
font = Pango::FontDescription.new("Monospace Bold 10")
textview.modify_font(font)
textview.wrap_mode = Gtk::TextTag::WRAP_WORD
textview.justification = Gtk::JUSTIFY_RIGHT
textview.editable =  true
textview.cursor_visible =  true
textview.pixels_above_lines = 5
textview.pixels_below_lines = 5
textview.pixels_inside_wrap = 5
textview.left_margin = 10
textview.right_margin = 10
textview.buffer.text = "This is some text!\nChange me!\nPlease!"

scrolled_win = Gtk::ScrolledWindow.new
scrolled_win.border_width = 5
scrolled_win.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS)
scrolled_win.add(textview)

window.add(scrolled_win)
window.show_all
Gtk.main
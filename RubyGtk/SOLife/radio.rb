#!/usr/bin/env ruby

require 'gtk2'

window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
window.set_title  "Radio Buttons"
window.border_width = 10
window.signal_connect('delete_event') { Gtk.main_quit }

radio1 = Gtk::RadioButton.new("_I want to be clicked!")
radio2 = Gtk::RadioButton.new(radio1, "_Click me instead!")
radio3 = Gtk::RadioButton.new(radio1, "No! Click _me!")
radio4 = Gtk::RadioButton.new(radio1, "_No! Click me instead!")

vbox = Gtk::VBox.new(false, 5)
vbox.pack_start(radio1, false, true, 0)
vbox.pack_start(radio2, false, true, 0)
vbox.pack_start(radio3, false, true, 0)
vbox.pack_start(radio4, false, true, 0)

window.add(vbox)
window.show_all
Gtk.main
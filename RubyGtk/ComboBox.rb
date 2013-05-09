#!/usr/bin/ruby

# ZetCode Ruby GTK tutorial
#
# This example demonstrates the ComboBox widget
#
# author: jan bodnar
# website: www.zetcode.com
# last modified: June 2009

require 'gtk2'


class RubyApp < Gtk::Window

    def initialize
        super
    
        set_title "ComboBox"
        signal_connect "destroy" do 
            Gtk.main_quit 
        end
        
        init_ui

        set_default_size 250, 200
        set_window_position Gtk::Window::POS_CENTER
        
        show_all
    end
    
    def init_ui

        fixed = Gtk::Fixed.new
        label = Gtk::Label.new '-'
        fixed.put label, 50, 140

        cb = Gtk::ComboBox.new
        cb.signal_connect "changed" do |w, e|
            on_changed(w, e, label)
        end

        cb.append_text 'Ubuntu'
        cb.append_text 'Mandriva'
        cb.append_text 'Redhat'
        cb.append_text 'Gento'
        cb.append_text 'Mint' 

        fixed.put cb, 50, 30

        add fixed

    end

    def on_changed sender, event, label
        label.set_label sender.active_text
    end
end

Gtk.init
    window = RubyApp.new
Gtk.main
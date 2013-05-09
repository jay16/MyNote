#!/usr/bin/ruby

# ZetCode Ruby GTK tutorial
#
# This example demonstrates the
# AboutDialog dialog
#
# author: jan bodnar
# website: www.zetcode.com
# last modified: June 2009

require 'gtk2'


class RubyApp < Gtk::Window

    def initialize
        super
    
        set_title "About dialog"
        signal_connect "destroy" do 
            Gtk.main_quit 
        end
        
        init_ui

        set_default_size 300, 150
        set_window_position Gtk::Window::POS_CENTER
        
        show_all
    end
    
    def init_ui
    
        button = Gtk::Button.new "About"
        button.set_size_request 80, 30
        
        button.signal_connect "clicked" do
            on_clicked
        end
        
        fix = Gtk::Fixed.new
        fix.put button, 20, 20
   
        add fix

    end
    
    def on_clicked
        about = Gtk::AboutDialog.new
        about.set_program_name "Battery"
        about.set_version "0.1"
        about.set_copyright "(c) Jan Bodnar"
        about.set_comments "Battery is a simple tool for battery checking"
        about.set_website "http://www.zetcode.com"
        about.set_logo Gdk::Pixbuf.new "intfocus_logo.png"
        about.run
        about.destroy
    end
end

Gtk.init
    window = RubyApp.new
Gtk.main
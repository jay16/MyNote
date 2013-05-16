#!/usr/bin/ruby

# ZetCode Ruby GTK tutorial
#
# This code shows a tooltip on 
# a window and a button
#
# author: jan bodnar
# website: www.zetcode.com
# last modified: June 2009

require 'gtk2'

class RubyApp < Gtk::Window

    def initialize
        super
    
        set_title  "Tooltips"
        signal_connect "destroy" do 
            Gtk.main_quit 
        end
        
        fixed = Gtk::Fixed.new
        add fixed
       
        button = Gtk::Button.new "Button"
        button.set_size_request 80, 35      
        button.set_tooltip_text "Button widget"
  
        fixed.put button, 50, 50       

        set_tooltip_text "Window widget"
        set_default_size 250, 200
        set_window_position Gtk::Window::POS_CENTER
        
        show_all
        
    end
end

Gtk.init
    window = RubyApp.new
Gtk.main
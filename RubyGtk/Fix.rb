#!/usr/bin/ruby

# ZetCode Ruby GTK tutorial
#
# In this program, we lay out widgets
# using absolute positioning
#
# author: jan bodnar
# website: www.zetcode.com
# last modified: June 2009

require 'gtk2'


class RubyApp < Gtk::Window

    def initialize
        super
    
        set_title "Fixed"
        signal_connect "destroy" do 
            Gtk.main_quit 
        end
        
        init_ui

        set_default_size 300, 280
        set_window_position Gtk::Window::POS_CENTER
        
        show_all
    end
    
    def init_ui
    
        modify_bg Gtk::STATE_NORMAL, Gdk::Color.new(6400, 6400, 6440)
               
        begin       
            bardejov = Gdk::Pixbuf.new "bardejov.jpg"
            rotunda = Gdk::Pixbuf.new "rotunda.jpg"
            mincol = Gdk::Pixbuf.new "mincol.jpg"
        rescue IOError => e
            puts e
            puts "cannot load images"
            exit
        end
        
        image1 = Gtk::Image.new bardejov
        image2 = Gtk::Image.new rotunda
        image3 = Gtk::Image.new mincol
        
        fixed = Gtk::Fixed.new
        
        fixed.put image1, 20, 20
        fixed.put image2, 40, 160
        fixed.put image3, 170, 50
  
        add fixed
        
    end
end

Gtk.init
    window = RubyApp.new
Gtk.main
#!/usr/bin/ruby

# ZetCode Ruby GTK tutorial
#
# This example shows a menu with
# images, accelerators and a separator
#
# author: jan bodnar
# website: www.zetcode.com
# last modified: June 2009

require 'gtk2'


class RubyApp < Gtk::Window

    def initialize
        super
    
        set_title "Image menu"
        signal_connect "destroy" do 
            Gtk.main_quit 
        end
        
        init_ui

        set_default_size 250, 200
        set_window_position Gtk::Window::POS_CENTER
        
        show_all
    end
    
    def init_ui
    
        modify_bg Gtk::STATE_NORMAL, Gdk::Color.new(6400, 6400, 6440)
        
        mb = Gtk::MenuBar.new

        filemenu = Gtk::Menu.new
        filem = Gtk::MenuItem.new "File"
        filem.set_submenu filemenu
        
        agr = Gtk::AccelGroup.new
        add_accel_group agr

        newi = Gtk::ImageMenuItem.new Gtk::Stock::NEW, agr
        key, mod = Gtk::Accelerator.parse "N"
        newi.add_accelerator("activate", agr, key, 
            mod, Gtk::ACCEL_VISIBLE)
        filemenu.append newi

        openm = Gtk::ImageMenuItem.new Gtk::Stock::OPEN, agr
        key, mod = Gtk::Accelerator.parse "O"
        openm.add_accelerator("activate", agr, key, 
            mod, Gtk::ACCEL_VISIBLE)
        filemenu.append openm

        sep = Gtk::SeparatorMenuItem.new
        filemenu.append sep

        exit = Gtk::ImageMenuItem.new Gtk::Stock::QUIT, agr
        key, mod = Gtk::Accelerator.parse "Q"
        exit.add_accelerator("activate", agr, key, 
            mod, Gtk::ACCEL_VISIBLE)

        exit.signal_connect "activate" do
            Gtk.main_quit
        end
        filemenu.append exit

        mb.append filem

        vbox = Gtk::VBox.new false, 2
        vbox.pack_start mb, false, false, 0

        add vbox
    end
end

Gtk.init
    window = RubyApp.new
Gtk.main
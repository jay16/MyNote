#!/usr/bin/ruby

# ZetCode Ruby GTK tutorial
#
# This example shows a submenu
#
# author: jan bodnar
# website: www.zetcode.com
# last modified: June 2009

require 'gtk2'


class RubyApp < Gtk::Window

    def initialize
        super
    
        set_title "Submenu"
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

        mb.append filem
        
        imenu = Gtk::Menu.new

        importm = Gtk::MenuItem.new "Import"
        importm.set_submenu imenu

        inews = Gtk::MenuItem.new "Import news feed..."
        ibookmarks = Gtk::MenuItem.new "Import bookmarks..."
        imail = Gtk::MenuItem.new "Import mail..."

        imenu.append inews
        imenu.append ibookmarks
        imenu.append imail

        filemenu.append importm
        
        exit = Gtk::MenuItem.new "Exit"
        exit.signal_connect "activate" do
            Gtk.main_quit
        end
        
        filemenu.append exit

        vbox = Gtk::VBox.new false, 2
        vbox.pack_start mb, false, false, 0

        add vbox
    end
end

Gtk.init
    window = RubyApp.new
Gtk.main
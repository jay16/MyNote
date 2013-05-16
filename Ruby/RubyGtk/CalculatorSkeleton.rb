#!/usr/bin/ruby

# ZetCode Ruby GTK tutorial
#
# In this program we create a skeleton of
# a calculator. We use the Table widget. 
#
# author: jan bodnar
# website: www.zetcode.com
# last modified: June 2009

require 'gtk2'


class RubyApp < Gtk::Window

    def initialize
        super
    
        set_title "Calculator"
        signal_connect "destroy" do 
            Gtk.main_quit 
        end
        
        init_ui

        set_default_size 300, 250
        set_window_position Gtk::Window::POS_CENTER
        
        show_all
    end
    
    def init_ui
    
        vbox = Gtk::VBox.new false, 2
        
        mb = Gtk::MenuBar.new
        filemenu = Gtk::Menu.new
        file = Gtk::MenuItem.new "File"
        file.set_submenu filemenu
        mb.append file

        vbox.pack_start mb, false, false, 0

        table = Gtk::Table.new 5, 4, true

        table.attach Gtk::Button.new("Cls"), 0, 1, 0, 1
        table.attach Gtk::Button.new("Bck"), 1, 2, 0, 1
        table.attach Gtk::Label.new, 2, 3, 0, 1
        table.attach Gtk::Button.new("Close"), 3, 4, 0, 1

        table.attach Gtk::Button.new("7"), 0, 1, 1, 2
        table.attach Gtk::Button.new("8"), 1, 2, 1, 2
        table.attach Gtk::Button.new("9"), 2, 3, 1, 2
        table.attach Gtk::Button.new("/"), 3, 4, 1, 2

        table.attach Gtk::Button.new("4"), 0, 1, 2, 3
        table.attach Gtk::Button.new("5"), 1, 2, 2, 3
        table.attach Gtk::Button.new("6"), 2, 3, 2, 3
        table.attach Gtk::Button.new("*"), 3, 4, 2, 3

        table.attach Gtk::Button.new("1"), 0, 1, 3, 4
        table.attach Gtk::Button.new("2"), 1, 2, 3, 4
        table.attach Gtk::Button.new("3"), 2, 3, 3, 4
        table.attach Gtk::Button.new("-"), 3, 4, 3, 4

        table.attach Gtk::Button.new("0"), 0, 1, 4, 5
        table.attach Gtk::Button.new("."), 1, 2, 4, 5
        table.attach Gtk::Button.new("="), 2, 3, 4, 5
        table.attach Gtk::Button.new("+"), 3, 4, 4, 5

        vbox.pack_start Gtk::Entry.new, false, false, 0
        
        vbox.pack_end table, true, true, 0
        
        add vbox

    end
end

Gtk.init
    window = RubyApp.new
Gtk.main
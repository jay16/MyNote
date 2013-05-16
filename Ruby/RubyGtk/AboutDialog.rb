#!/usr/bin/env ruby
require 'gtk2'

authors = ["Author #1", "Author #2"]
documenters = ["Documenter #1", "Documenter #2"]

dialog = Gtk::AboutDialog.new

# We are not really handling the error here. The purpose
# of this blockis only to show how it could be done
begin
  logo_book = Gdk::Pixbuf.new("/tmp/logo.png")
rescue GLib::FileError => err
  print "I/O ERROR (%s): %s\n" % [err.class, err]
rescue Gdk::PixbufError => err
  print "IMAGE ERROR (%s): %s\n" % [err.class, err]
rescue => err
  print "Unexpected ERROR (%s): %s\n" % [err.class, err]
  raise # re-raise the unexpected error
else
  dialog.logo = logo_book
end

# Set application data that will be displayed in the
# main dialog.
dialog.name = "GtkAboutDialog"
dialog.version = "1.0"
dialog.copyright = "(C) 2007 Andrew Krause"
dialog.comments = "All About GtkAboutDialog"

# Set the license text, which is usually loaded from
# a file. Also, set the web site address and label.
dialog.license = "Free to all!"
dialog.website = "http://www.gtkbook.com"
dialog.website_label = "www.gtkbook.com"

# Set the application authors, documenters and translators.
dialog.authors = authors
dialog.documenters = documenters
dialog.translator_credits = "Translator #1\nTranslator #2"
# NOTE: all these properties are optional
# dialog.artists = ["Artist #1", "Artist #2"]

# dialog.show_all
dialog.run
dialog.destroy
#!/usr/bin/env ruby
require 'gtk2'

class TextEditor
  attr_accessor :textview, :search
end

# Verify that the user want to create a new document.
# If so, delete all of the text from the buffer.
def new_clicked(te)
  dialog = Gtk::MessageDialog.new(
      nil,
      Gtk::Dialog::MODAL,
      Gtk::MessageDialog::QUESTION,
      Gtk::MessageDialog::BUTTONS_YES_NO,
      "All changes will be lost. Do you want to continue?"
  )
  dialog.title = "Information"
  dialog.run do |r|
    te.textview.buffer.text = "" if r == Gtk::Dialog::RESPONSE_YES
  end
  dialog.destroy
end

# Replace the content of the current buffer with the
# content of a file.
def open_clicked(te) 
  dialog = Gtk::FileChooserDialog.new(
    "Choose a file ...",
    nil,
    Gtk::FileChooser::ACTION_OPEN,
    nil,
    [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ],
    [ Gtk::Stock::APPLY, Gtk::Dialog::RESPONSE_APPLY ]
  )
  dialog.run do |response|
    if response == Gtk::Dialog::RESPONSE_APPLY
      file = dialog.filename
      content = IO.readlines(file)
      te.textview.buffer.text = content.to_s
    end
  end
  dialog.destroy
end

# Save the content of the current buffer to a file.
def save_clicked(te)
  dialog = Gtk::FileChooserDialog.new(
    "Save the file ...",
    nil,
    Gtk::FileChooser::ACTION_SAVE,
    nil,
    [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ],
    [ Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_APPLY ]
  )
  dialog.run do |response|
    if response == Gtk::Dialog::RESPONSE_APPLY
      file = dialog.filename
      content = te.textview.buffer.text
      # Open for writing, write and close.
      File.open(file, "w") { |f| f <<  content } 
    end
  end
  dialog.destroy
end

# Copy the selected text to the clipboard and remove it from the buffer.
def cut_clicked(te)
  clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
  te.textview.buffer.cut_clipboard(clipboard, true)
end

# Copy the selected text to the clipboard.
def copy_clicked(te)
  clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
  te.textview.buffer.copy_clipboard(clipboard)
end

# Delete any selected text and insert the clipboard
# content into the document.
def paste_clicked(te)
  clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
  te.textview.buffer.paste_clipboard(clipboard, nil, true)
end

# Search for a text string from the current cursor position
# if there is no selected text, or one character after the
# cursor if there is.
def find_clicked(te)
  find = te.search.text
  first, last, success = te.textview.buffer.selection_bounds

  first = te.textview.buffer.start_iter unless success

  #                   forward_search(find, flags,    limit=(nil==entire text buffer))
  first, last = first.forward_search(find, Gtk::TextIter::SEARCH_TEXT_ONLY, last)

  # Select the instance on the screen if the string is found. 
  # Otherwise, tell the user it has failed.
  if (first)
    mark = te.textview.buffer.create_mark(nil, first, false)
    # Scrolls the Gtk::TextView the minimum distance so
    # that mark is contained within the visible area. 
    te.textview.scroll_mark_onscreen(mark)

    te.textview.buffer.delete_mark(mark)
    te.textview.buffer.select_range(first, last)
  else
    # Gtk::MessageDialog.new(parent, flags, message_type, button_type, message = nil)
    dialogue = Gtk::MessageDialog.new(
            nil,
            Gtk::Dialog::MODAL,
            Gtk::MessageDialog::INFO, 
            Gtk::MessageDialog::BUTTONS_OK,
             "The text was not found!"
    )
    dialogue.run
    dialogue.destroy
  end
  first = last = nil # camcel any previous selections
end

window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
window.resizable = true
window.title = "Simple Text Editor"
window.border_width = 10
window.signal_connect('delete_event') { Gtk.main_quit }
window.set_size_request(600, -1)

ed = TextEditor.new
ed.textview = Gtk::TextView.new
ed.search   = Gtk::Entry.new
ed.search.text = "Search for ..."

new   = Gtk::Button.new(Gtk::Stock::NEW)
open  = Gtk::Button.new(Gtk::Stock::OPEN)
save  = Gtk::Button.new(Gtk::Stock::SAVE)
cut   = Gtk::Button.new(Gtk::Stock::CUT)
copy  = Gtk::Button.new(Gtk::Stock::COPY)
paste = Gtk::Button.new(Gtk::Stock::PASTE)
find  = Gtk::Button.new(Gtk::Stock::FIND)

new.signal_connect("clicked")   { new_clicked(ed) }
open.signal_connect("clicked")  { open_clicked(ed) }
save.signal_connect("clicked")  { save_clicked(ed) }
cut.signal_connect("clicked")   { cut_clicked(ed) }
copy.signal_connect("clicked")  { copy_clicked(ed) }
paste.signal_connect("clicked") { paste_clicked(ed) }
find.signal_connect("clicked")  { find_clicked(ed) }

scrolled_win = Gtk::ScrolledWindow.new
scrolled_win.border_width = 5
scrolled_win.add(ed.textview)
scrolled_win.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS)

vbox = Gtk::VBox.new(true, 5)
vbox.pack_start(new,   false, false, 0)
vbox.pack_start(open,  false, false, 0)
vbox.pack_start(save,  false, false, 0)
vbox.pack_start(cut,   false, false, 0)
vbox.pack_start(copy,  false, false, 0)
vbox.pack_start(paste, false, false, 0)

searchbar = Gtk::HBox.new(false, 5)
searchbar.pack_start(ed.search, false, false, 0)
searchbar.pack_start(find,      false, false, 0)

table = Gtk::Table.new(2, 2, false)

table.attach(scrolled_win, 0, 1, 0, 1, 
             Gtk::EXPAND | Gtk::FILL, Gtk::EXPAND | Gtk::FILL, 5, 5)
table.attach(vbox, 1, 2, 0, 1, 
             Gtk::SHRINK, Gtk::SHRINK, 5, 5)
table.attach(searchbar, 0, 1, 1, 2,
             Gtk::FILL, Gtk::SHRINK, 5, 5)
window.add(table)
window.show_all
Gtk.main
#!/usr/bin/env ruby
require 'gtk2'

def add_product(treeview, list)
  # Create a dialog that will be used to create a new product.

  dialog = Gtk::Dialog.new(
      "Add a Product",
      nil,
      Gtk::Dialog::MODAL,
      [ Gtk::Stock::ADD,    Gtk::Dialog::RESPONSE_OK ],
      [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ]
  )
  # Create widgets that will be packed into the dialog.
  combobox = Gtk::ComboBox.new
  entry = Gtk::Entry.new

  #                         min, max, step
  spin  = Gtk::SpinButton.new(0, 100, 1)
  # Set the precision to be displayed by spin button.
  spin.digits = 0
  check = Gtk::CheckButton.new("_Buy the Product")

  # Add all of the categories to the combo box.
  list.each_with_index do |e, i|
    combobox.append_text(list[i].product) if (e.product_type == P_CATEGORY)
  end

  ### Usually, after initialiying combobox you would set the default 
  ### combobox.active = 0    # set active index (1st row)

  table = Gtk::Table.new(4, 2, false)
  table.row_spacings = 5
  table.column_spacings = 5
  table.border_width = 5

  # Pack the table that will hold the dialog widgets.
  fll_shr = Gtk::SHRINK | Gtk::FILL
  fll_exp = Gtk::EXPAND | Gtk::FILL

  table.attach(Gtk::Label.new("Category:"), 0, 1, 0, 1, fll_shr, fll_shr,  0, 0)
  table.attach(combobox,                    1, 2, 0, 1, fll_exp, fll_shr,  0, 0)
  table.attach(Gtk::Label.new("Product:"),  0, 1, 1, 2, fll_shr, fll_shr,  0, 0)
  table.attach(entry,                       1, 2, 1, 2, fll_exp, fll_shr,  0, 0)
  table.attach(Gtk::Label.new("Quantity:"), 0, 1, 2, 3, fll_shr, fll_shr,  0, 0)
  table.attach(spin,                        1, 2, 2, 3, fll_exp, fll_shr,  0, 0)
  table.attach(check,                       1, 2, 3, 4, fll_exp, fll_shr,  0, 0)

  dialog.vbox.pack_start_defaults(table)
  dialog.show_all

  dialog.run do |response|
    # If the user presses OK, verify the entries and add the product.
    if response == Gtk::Dialog::RESPONSE_OK
      quantity = spin.value
      product = entry.text
      category = combobox.active_text
      buy = check.active?

      if product == "" || category == nil
        puts "All of the fields were not correctly filled out!"
        puts "DEBUG:  prod=(#{product}), ctg=(#{category})"
        dialog.destroy
        return
      end

      model = treeview.model
      iter = model.iter_first    #<-- same as: iter = model.get_iter("0")

      # Retrieve an iterator pointing to the selected category.
      begin
        name = iter[PROD_INDEX]  #<-- same as: name=iter.get_value(PROD_INDEX)
        break if name == category
      end while iter.next!

      child = model.append(iter)

      # child[BUY_INDEX]=buy # same as: model.set_value(child, BUY_INDEX, buy)
      child[BUY_INDEX]   = buy
      child[QTY_INDEX]   = quantity
      child[PROD_INDEX]  = product

      # Add the quantity to the running total if it is to be purchased.
      if buy
        qty_value = iter[QTY_INDEX]
        qty_value += quantity
        iter[QTY_INDEX] = qty_value
      end
    end
    dialog.destroy
  end
end

def remove_row(ref, model)
  path = ref.path
  iter = model.get_iter(path)

  # Only remove the row if it is not a root row.
  parent = iter.parent
  if parent
    buy       = iter[BUY_INDEX]
    quantity  = iter[QTY_INDEX]
    pqty      = parent[QTY_INDEX]
    if buy
      pqty -= quantity
      parent[QTY_INDEX] = pqty
    end
    iter = model.get_iter(path)
    model.remove(iter)
  end
end

def remove_products(treeview)
  # Gtk::TreeRowReference.new(model, path)
  selection = treeview.selection

  paths2rm = Array.new
  selection.selected_each do |mod, path, iter|
    ref = Gtk::TreeRowReference.new(mod, path)
    paths2rm << [ref, mod]
  end
  paths2rm.each { |ref, mod| remove_row(ref, mod) }
end

# Add three columns to the GtkTreeView. All three of the
# columns will be displayed as text, although one is a boolean
# value and another is an integer.
def setup_tree_view(treeview)
  # Create a new GtkCellRendererText, add it to the tree
  # view column and append the column to the tree view.
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new("Buy", renderer, "text" => BUY_INDEX)
  treeview.append_column(column)
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new("Count", renderer, "text" => QTY_INDEX)
  treeview.append_column(column) 
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new("Product", renderer, "text" => PROD_INDEX)
  treeview.append_column(column)
end

window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
window.resizable = true
window.title = "Grocery List"
window.border_width = 10
window.signal_connect('delete_event') { Gtk.main_quit }
window.set_size_request(275, 300)

class GroceryItem
  attr_accessor :product_type, :buy, :quantity, :product
  def initialize(t,b,q,p)
    @product_type, @buy, @quantity, @product = t, b, q, p
  end
end
BUY_INDEX = 0; QTY_INDEX = 1; PROD_INDEX = 2
P_CATEGORY = 0; P_CHILD = 1

list = Array.new
list[0] = GroceryItem.new(P_CATEGORY, true,  0, "Cleaning Supplies")
list[1] = GroceryItem.new(P_CHILD,    true,  1, "Paper Towels")
list[2] = GroceryItem.new(P_CHILD,    true,  3, "Toilet Paper")
list[3] = GroceryItem.new(P_CATEGORY, true,  0, "Food")
list[4] = GroceryItem.new(P_CHILD,    true,  2, "Bread")
list[5] = GroceryItem.new(P_CHILD,    false, 1, "Butter")
list[6] = GroceryItem.new(P_CHILD,    true,  1, "Milk")
list[7] = GroceryItem.new(P_CHILD,    false, 3, "Chips")
list[8] = GroceryItem.new(P_CHILD,    true,  4, "Soda")

treeview = Gtk::TreeView.new
treeview.tooltip_text = "You can select multiple lines"

setup_tree_view(treeview)

# Create a new tree model with three columns, as Boolean, 
# integer and string.
store = Gtk::TreeStore.new(TrueClass, Integer, String)

# Avoid creation of iterators on every iteration, since they
# need to provide state information for all iterations. Hence:
# establish closure variables for iterators parent and child.
parent = child = nil

# Add all of the products to the GtkListStore.
list.each_with_index do |e, i|

  # If the product type is a category, count the quantity
  # of all of the products in the category that are going
  # to be bought.
  if (e.product_type == P_CATEGORY)
    j = i + 1

    # Calculate how many products will be bought in
    # the category.
    while j < list.size && list[j].product_type != P_CATEGORY
      list[i].quantity += list[j].quantity if list[j].buy
      j += 1
    end

    # Add the category as a new root (parent) row (element).
    parent = store.append(nil)
    # store.set_value(parent, BUY_INDEX, list[i].buy # <= same as below
    parent[BUY_INDEX]   = list[i].buy
    parent[QTY_INDEX]   = list[i].quantity
    parent[PROD_INDEX]  = list[i].product

  # Otherwise, add the product as a child row of the category.
  else
    child = store.append(parent)
    # store.set_value(child, BUY_INDEX, list[i].buy # <= same as below
    child[BUY_INDEX]   = list[i].buy
    child[QTY_INDEX]   = list[i].quantity
    child[PROD_INDEX]  = list[i].product
  end
end

# Add the tree model to the tree view
treeview.model = store
treeview.expand_all

# Allow multiple rows to be selected at the same time.
treeview.selection.mode = Gtk::SELECTION_MULTIPLE

scrolled_win = Gtk::ScrolledWindow.new
scrolled_win.add(treeview)
scrolled_win.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

add    = Gtk::Button.new(Gtk::Stock::ADD)
remove = Gtk::Button.new(Gtk::Stock::REMOVE)
remove.tooltip_text = "You can select multiple\nlines and delete them"

add.signal_connect('clicked')    { add_product(treeview, list) }
remove.signal_connect('clicked') { remove_products(treeview) }

hbox = Gtk::HBox.new(true, 5)
hbox.pack_start(add,    false, true, 0)
hbox.pack_start(remove, false, true, 0)

vbox = Gtk::VBox.new(false, 5)
vbox.pack_start(scrolled_win, true,  true, 0)
vbox.pack_start(hbox,         false, true, 0)

window.add(vbox)
window.show_all
Gtk.main
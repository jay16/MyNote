def notebook_prepage(notebook,window)
  if notebook.page == 0
    notebook.set_page(notebook.n_pages - 1)
  else
    notebook.prev_page
  end
  tab = notebook.get_nth_page(notebook.page)
  tab.child.buffer.text = "HHH"
  puts tab.child.visible_rect.to_a.to_s
  window.show_all
  notebook.show_all
  
end
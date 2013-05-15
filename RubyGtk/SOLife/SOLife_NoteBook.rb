def notebook_prepage(notebook,window)
  if notebook.page == 0
    notebook.set_page(notebook.n_pages - 1)
  else
    notebook.prev_page
  end
  text_view = notebook.get_nth_page(notebook.page)
  text_view.buffer.text = "HHH"

  window.show_all
  notebook.show_all
  
    text_view.show_all
end
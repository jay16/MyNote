def notebook_prepage(notebook,window)
  if notebook.page == 0
    notebook.set_page(notebook.n_pages - 1)
  else
    notebook.prev_page
  end
  text_view = notebook.get_nth_page(notebook.page)
  text_view.show
  puts text_view.buffer.text
  window.show_all
end
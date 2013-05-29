def hide_show_cattree(scrolled_notelist_view,window)
  puts "ctrl+m:#{scrolled_notelist_view.visible?.to_s}"
  #puts scrolled_notelist_view.class.instance_methods(false).to_s
  puts scrolled_notelist_view.methods().to_s
  #scrolled_notelist_view.visible? ? scrolled_notelist_view.set_visible(false) : scrolled_notelist_view.set_visible(true)
  scrolled_notelist_view.set_visible(false)
  scrolled_notelist_view.hide
  scrolled_notelist_view.hide_all
  #window.show_all
end
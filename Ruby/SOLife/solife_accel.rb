def hide_show_cattree(layout_table,scrolled_notelist_view,window)
  puts "ctrl+m:#{scrolled_notelist_view.visible?.to_s}"
  puts "ctrl+m:#{layout_table.homogeneous?.to_s}"
  
  if scrolled_notelist_view.visible? then
    #puts scrolled_notelist_view.class.instance_methods(false).to_s
    #puts scrolled_notelist_view.methods().to_s
    scrolled_notelist_view.set_visible(false)
    scrolled_notelist_view.hide
    scrolled_notelist_view.hide_all
    layout_table.homogeneous = false
    #window.show_all
  else
    scrolled_notelist_view.show_all
    layout_table.homogeneous = true
  end
end
#ctrl+m 显示、隐藏目录树
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

#详细目录树 右键鼠标点击菜单项响应处理
def note_view_popaction(widget,event,note_view_popmenu)
    selection = widget.selection
    iter = selection.selected 
    file_path = iter[1]
    file_type = File.file?(file_path) ? "file" : "dir"
    #puts "File Type:#{file_type}"    
    if file_type == "file" then
      
    elsif file_type == "dir" then
      note_view_popmenu.popup(nil, nil, event.button, event.time) 
    end
end

#详细目录树中某常用路径添加至常用NoteList tree中
def add_dir_tolist(note_view_tree,note_list_store,window,conf_save)
    selection = note_view_tree.selection
    iter = selection.selected 
    file_path = iter[1]
    file_type = File.file?(file_path) ? "file" : "dir"
    if file_type == "dir" then
      note_dir_list = Array.new   
      #遍历notelist所有节点，生成数组，把新添加路径添加至数组
      iter = note_list_store.iter_first
      if iter then
        begin
           note_dir_list.push(iter[1])
        end while iter.next!
        note_dir_list.push(file_path)
        #新数组写入文档
        conf_save.transaction do 
          conf_save["NoteDirList"] = note_dir_list
        end
        #常用列表树中添加新节点
        note_dir_sel = note_list_store.append(nil)
        note_dir_sel[0] = File.basename(file_path)
        window.show_all
       end
    end
end

#删除无用路径 - 详细目录树中
def del_dir_fromlist(note_view_tree,note_list_store,window,conf_save)
    selection = note_view_tree.selection
    iter = selection.selected 
    file_path = iter[1]
    file_type = File.file?(file_path) ? "file" : "dir"
    if file_type == "dir" then
      note_dir_list = Array.new   
      #遍历notelist所有节点，生成数组，把新添加路径添加至数组
      iter = note_list_store.iter_first
      if iter then
        begin
           note_dir_list.push(iter[1])
        end while iter.next!
        note_dir_list.delete(file_path)
        #新数组写入文档
        conf_save.transaction do 
          conf_save["NoteDirList"] = note_dir_list
        end
        #更新列表树
        del_note_dir(note_view_tree,note_list_store)
        window.show_all
       end
    end
end
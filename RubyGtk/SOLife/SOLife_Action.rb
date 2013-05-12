
#目录节点被点击反应
def row_activated(tree_view,tree_store,text_editor,window)
    selection = tree_view.selection
    iter = selection.selected    
    #没有选中值则返回
    return unless (iter and iter[0] != iter[1])
    
    node_name = iter[0] 
    node_path = iter[1]
    #puts node_path
    if File.file? node_path
      text_editor.note_label.text = node_name
      file_content = File.readlines(node_path).join("").to_s
      #file_content = (file_content.strip.length > 0 ? file_content : "  content is empty")
      #加载文本内容
      text_editor.text_view.buffer.text =  file_content
      #如果文本内容与控件加载内容数量不同表示文本内容格式不对
      if(text_editor.text_view.buffer.text.length == 0 and file_content.length > 0)
        #强制转换编码重新写入文本
        file = File.open(node_path+"_new","w")
        file.puts file_content.encode("UTF-8")
        file.close
        #成功写入后再删除
        puts "return:"+File.delete(node_path).to_s+"-delete:"+node_path
        #修改文件名称
        File.rename(node_path+"_new",node_path)
        file_content = File.readlines(node_path).join("").to_s
        text_editor.text_view.buffer.text =  file_content
      end

      #puts File.readlines(node_path).join('\n')
    else
      row_ref = Gtk::TreeRowReference.new(tree_store, Gtk::TreePath.new(iter.to_s))
      row_path = row_ref.path
      is_expand = tree_view.row_expanded?(row_path)
      #判断该节点目录是否展开
      if !is_expand then 
        #展开该节点目录
        tree_view.expand_row(row_path,true)
        #有父节点取得父节点，若没有，则取本身
        parent = iter #iter.parent ? iter.parent : iter

        tree_model = tree_view.model
        parent_path = tree_model.get_iter(parent.to_s)
        #该目录下第一个节点
        first_child = iter.first_child
        #若第一个节点都为loading说明该目录子节点还没有加载
        return if first_child[0] == first_child[1] and first_child[1] == "done"
        if first_child[0] == first_child[1] and first_child[1] == "loading" then
          first_child[0] = "done"
          first_child[1] = "done"
          return unless File.directory?(node_path)
          Dir.foreach(node_path) do |file|
            next if file == "." or file == ".."
            child = tree_model.append(parent_path)
            file_path = node_path+"\\"+file
            if File.directory?(file_path)  then
              child[0] = "D_"+file
              child[1] = file_path
              #文件夹目录添加Loading标识
              tree_lt = tree_store.append(child)
              tree_lt[0] = "loading"
              tree_lt[1] = "loading"
            else
              child[0] = "F_"+file
              child[1] = file_path
            end  #if
          end    #Dir.foreach
        end      #if first_child
      else
        #缩回目录 
        tree_view.collapse_row(row_path)
      end
    end
   
end

#保存文本
def save_file(tree_view,tree_store,text_editor,window) 
 selection = tree_view.selection
 if iter = selection.selected and iter[1] and File.file?(iter[1])
    file = File.open(iter[1],"w")
    file.puts text_editor.text_view.buffer.text
    file.close
    window.set_title("SoLife #{iter[1]}[saved]")
    window.show_all
 elsif text_editor.note_label.text == "new file"
   save_new_file(text_editor,window)
 else
   puts "can not save:"+iter[1]
 end
end
#重新加载文本
def reload_file(tree_view,tree_store,text_editor,window) 
 selection = tree_view.selection
 if iter = selection.selected
   if iter[1] then 
    text_editor.text_view.buffer.text = File.readlines(iter[1]).join("").to_s.encode("UTF-8")
    window.set_title("SoLife #{iter[1]}[reload]")
    window.show_all
   end
 end
end
#重新加载文本
def new_file(text_editor,window) 
  text_editor.note_label.text = "new file"
  text_editor.text_view.buffer.text = "please input content..."
end
#保存新建文本
def save_new_file(text_editor,window)
  dialog = Gtk::FileChooserDialog.new(
    "Save the file ...",
    window,
    Gtk::FileChooser::ACTION_SAVE,
    nil,
    [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ],
    [ Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_APPLY ]
  )
  dialog.run do |response|
    if response == Gtk::Dialog::RESPONSE_APPLY
      file = dialog.filename
      content = text_editor.textview.buffer.text
      # Open for writing, write and close.
      File.open(file, "w") { |f| f <<  content } 
    end
  end
  dialog.destroy
end
#编辑文本时状态
def write_statu(tree_view,tree_store,text_view,window) 
 selection = tree_view.selection
 if iter = selection.selected      
   window.set_title("SoLife #{iter[1]} [writing]")
   window.show_all
 else
 end
end

def window_exit(tree_view,tree_store,window)
     

 Gtk.main_quit
end
# Search for the entered string within the Gtktext_view.
# Then tell the user how many times it was found.
def search(ent, txtvu)
  start = txtvu.buffer.start_iter
  first, last = start.forward_search(ent.text, Gtk::TextIter::SEARCH_TEXT_ONLY, nil)
  count = 0
  while (first)
    start.forward_char
    first, last = start.forward_search(ent.text, Gtk::TextIter::SEARCH_TEXT_ONLY, nil)
    start = first
    txtvu.buffer.apply_tag("highlight", first, last)
    count += 1
  end
end

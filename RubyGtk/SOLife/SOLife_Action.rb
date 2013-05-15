

def g_note_list(note_tree_store,note_dir_list)
   #构建笔记列表树
   note_list_store = Gtk::TreeStore.new(String, String, Integer)
   note_dir_list.each do |note_path|
    note_store = note_list_store.append(nil)
    note_store[0] = note_path
   end
   tree_view = Gtk::TreeView.new(note_list_store)
   tree_view.selection.mode = Gtk::SELECTION_SINGLE
   tree_view.expand_all
   tree_view.hadjustment.value=100
   tree_view.columns_autosize
   scrolled_view = Gtk::ScrolledWindow.new
   scrolled_view.border_width = 2
   scrolled_view.add(tree_view)
   scrolled_view.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

   #笔记路径树
   renderer = Gtk::CellRendererText.new
   tree_col = Gtk::TreeViewColumn.new("Note Dir List", renderer, :text => 0)
   tree_view.append_column(tree_col)
   tree_view.signal_connect("row-activated") do
     note_path = tree_view.selection.selected[0]
     g_note_tree(note_tree_store,note_path)
   end

   return scrolled_view
end


def g_note_tree(tree_store,note_path)
  level_one = Array.new
  Dir.foreach(note_path) do |file|
    #跳过隐藏文件
    next if file=~ /^\..*/
    file_path = note_path+"\\"+file
    level_one.push([file,file_path,File.file?(file_path) ? "file" : "dir" ])
  end
   
  tree_store.clear
  level_one.each do |lo|
    #level one
    tree_lo =  tree_store.append(nil)
    #tree_level_one nodename
    tree_lo[0] = (File.file?(lo[1]) ? "F_"+lo[0] : lo[0])

    tree_lo[1] = lo[1] #tree_level_one nodepath
    #tree_lo[2] = lo[2] #tree_level_one nodetype
    if lo[2]=="dir" then
     tree_lt = tree_store.append(tree_lo)
     tree_lt[0] = "loading"
     tree_lt[1] = "loading"
    end
  end
  return tree_store
end
def test_notebook(note_book,window)
      text_editor = TextEditor.new
      text_editor.text_view = Gtk::TextView.new
      #text_editor.text_view.buffer.text = "Your 1st Gtk::TextView widget!"
      text_font = Pango::FontDescription.new("Monospace Normal 10")
      text_editor.text_view.modify_font(text_font)
      text_editor.note_label  = Gtk::Label.new("notebooxk")
      scrolled_text = Gtk::ScrolledWindow.new
      scrolled_text.border_width = 2
      scrolled_text.add(text_editor.text_view)

      note_book.insert_page(-1,scrolled_text,text_editor.note_label)
end
#目录节点被点击反应
def row_activated(tree_view,tree_store,note_book,window)
    selection = tree_view.selection
    iter = selection.selected    
    #没有选中值则返回
    return unless (iter and iter[0] != iter[1])
      
    node_name = iter[0] 
    node_path = iter[1]

    #puts node_path
    if File.file? node_path
      file_content = File.readlines(node_path).join("").to_s
      #file_content = (file_content.strip.length > 0 ? file_content : "  content is empty")
      #新建notebook标签页
      text_editor = TextEditor.new
      text_editor.text_view = Gtk::TextView.new
      #text_editor.text_view.buffer.text = "Your 1st Gtk::TextView widget!"
      text_font = Pango::FontDescription.new("Monospace Normal 10")
      text_editor.text_view.modify_font(text_font)
      text_editor.note_label  = Gtk::Label.new("notebooxk")
      scrolled_text = Gtk::ScrolledWindow.new
      scrolled_text.border_width = 2
      scrolled_text.add(text_editor.text_view)
      note_book.insert_page(-1,scrolled_text,text_editor.note_label)

      #加载文本内容
      begin
      text_editor.text_view.buffer.text =  file_content
      rescue => error
        puts "TextViewBufferText ERROR (%s): %s\n" % [error.class, error]
      else
      end

      #如果文本内容与控件加载内容数量不同表示文本内容格式不对
      if(text_editor.text_view.buffer.text.length == 0 and file_content.length > 0)
        begin
          file_content = file_content.encode("UTF-8")
        rescue => error #Encoding::InvalidByteSequenceError
          puts "FileContent ERROR (%s): %s\n" % [error.class, error]
          #显示错误提示框
          FileReadError_diaog(node_path,window)
        else 
          #强制转换编码重新写入文本
          file = File.open(node_path+"_new","w")
          file.puts file_content
          file.close
          #成功写入后,删除原始
          puts "return:"+File.delete(node_path).to_s+"-delete:"+node_path
          #修改文件名称
          File.rename(node_path+"_new",node_path)
          file_content = File.readlines(node_path).join("").to_s
          text_editor.text_view.buffer.text =  file_content       
          text_editor.note_label.text = node_name
          #鼠标悬停显示文本路径
          tooltip = Gtk::Tooltips.new
          tooltip.set_tip(text_editor.note_label,node_path,"private")
        ensure
        end
      else
        text_editor.note_label.text = node_name
        #鼠标悬停显示文本路径
        tooltip = Gtk::Tooltips.new
        tooltip.set_tip(text_editor.note_label,node_path,"private")
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
        if first_child[0] == first_child[1] and first_child[1] == "loading" then
          return unless File.directory?(node_path)
          Dir.foreach(node_path) do |file|
            next if file=~ /^\..*/
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
          
          #移除loading节点
          tree_store.remove(first_child)
        end      #if first_child
      else
        #缩回目录 
        tree_view.collapse_row(row_path)
        #tree_view.expand_row(row_path,true)
      end
    end
   window.show_all
end

#保存文本
def save_file(tree_view,tree_store,text_editor,window) 
 selection = tree_view.selection
 iter = selection.selected
 file_name = text_editor.note_label.text.split("_")[1]
 if iter and iter[1] and File.file?(iter[1]) and  file_name== File.basename(iter[1])
    file = File.open(iter[1],"w")
    file.puts text_editor.text_view.buffer.text
    file.close
    window.set_title("SoLife #{iter[1]}[saved]")
    window.show_all
 elsif text_editor.note_label.text == "new file"
   save_new_file(tree_view,tree_store,text_editor,window)
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



def save_new_file(tree_view,tree_store,text_editor,window)
  selection = tree_view.selection
  iter = selection.selected
  dialog = Gtk::Dialog.new(
      "Information",
      window,
      Gtk::Dialog::MODAL,
      [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK ]
  )
  dialog.has_separator = false
  label = Gtk::Label.new("The button was clicked!")
  image = Gtk::Image.new(Gtk::Stock::DIALOG_INFO, Gtk::IconSize::DIALOG)
  #当前被选中节点路径
  sel_dir = File.dirname(iter[1])
  radio1 = Gtk::RadioButton.new(sel_dir)
  radio1.name = "radio1"
  radio2 = Gtk::RadioButton.new(radio1, "")
  radio2.name = "radio2"
  radio1.group = radio1
  choo_dir_btt  = Gtk::FileChooserButton.new(
    "Choose a Folder", Gtk::FileChooser::ACTION_SELECT_FOLDER)
 
  new_name = Gtk::Entry.new
  hbox_0 = Gtk::HBox.new(false, 5)
  hbox_0.border_width = 10
  hbox_0.pack_start_defaults(Gtk::Label.new("NewFileName:"));
  hbox_0.pack_start_defaults(new_name);
  hbox_1 = Gtk::HBox.new(false, 5)
  hbox_1.border_width = 10
  hbox_1.pack_start_defaults(radio1);
  hbox_2 = Gtk::HBox.new(false, 5)
  hbox_2.border_width = 10
  hbox_2.pack_start_defaults(radio2);
  hbox_2.pack_start_defaults(choo_dir_btt);
  chose_label = Gtk::Label.new("Choose:")
  chose_dir = Gtk::Label.new(sel_dir)
  hbox_3 = Gtk::HBox.new(false, 5)
  hbox_3.border_width = 10
  hbox_3.pack_start_defaults(chose_label);
  hbox_3.pack_start_defaults(chose_dir);

  radio1.signal_connect('clicked') do |radio|
    chose_dir.text = sel_dir
  end
  radio2.signal_connect('clicked') do |radio|
    chose_dir.text = choo_dir_btt.filename
  end

  choo_dir_btt.signal_connect('selection_changed') do |w|
   chose_dir.text = w.filename
  end
  

  dialog.vbox.add(hbox_0) 
  dialog.vbox.add(hbox_1)
  dialog.vbox.add(hbox_2)
  dialog.vbox.add(hbox_3)
  dialog.show_all

  dialog.run do |response|
    if response == Gtk::Dialog::RESPONSE_OK
      file_path = File.join(chose_dir.text,new_name.text)
      puts file_path
      #写入到本地
      file = File.open(file_path,"w")
      file.puts text_editor.text_view.buffer.text
      file.close
      #text_editor.note_label.text="F_"+new_name.text
      #目录下添加新节点
      parent = iter.parent
      tree_model = tree_view.model
      parent_path = tree_model.get_iter(parent.to_s)
      new_note = tree_model.append(parent_path)
      new_note[0] = "F_"+new_name.text
      new_note[1] = file_path
      
     #设置新插入节点为选中点
    row_path = Gtk::TreePath.new(new_note.to_s)
    #等同下面两句
    #row_ref = Gtk::TreeRowReference.new(tree_store, Gtk::TreePath.new(iter.to_s))
    #row_path = row_ref.path
    tree_view.set_cursor(row_path,nil,true)
    #触发点击动作
    row_activated(tree_view,tree_store,text_editor,window)
    end
    dialog.destroy
  end
  
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

def FileReadError_diaog(file_path,window)
dialog = Gtk::Dialog.new(
      "FileRead Error!",
      window,
      Gtk::Dialog::MODAL,
      [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK ]
  )
  dialog.has_separator = false
  label = Gtk::Label.new("FileRead Error!")
  image = Gtk::Image.new(Gtk::Stock::DIALOG_INFO, Gtk::IconSize::DIALOG)
  entry_dir = Gtk::Entry.new
  entry_dir.text = file_path
  hbox_1 = Gtk::HBox.new(false, 5)
  hbox_1.pack_start_defaults(label);
  hbox_2 = Gtk::HBox.new(false, 5)
  hbox_2.pack_start_defaults(entry_dir);
  
  dialog.vbox.add(image)
  dialog.vbox.add(hbox_1)
  dialog.vbox.add(hbox_2)
  dialog.show_all

  dialog.run do |response|
    if response == Gtk::Dialog::RESPONSE_OK
    end
    dialog.destroy
  end
  
end

def InitConfig_diaog(yam_save)
dialog = Gtk::Dialog.new(
      "FileRead Error!",
      nil,
      Gtk::Dialog::MODAL,
      [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK ]
  )
  dialog.has_separator = false
 
   #构建笔记列表树
   tree_store = Gtk::TreeStore.new(String, String, Integer)
   
   tree_view = Gtk::TreeView.new(tree_store)
   tree_view.selection.mode = Gtk::SELECTION_SINGLE
   tree_view.expand_all
   tree_view.hadjustment.value=100
   tree_view.columns_autosize
   scrolled_view = Gtk::ScrolledWindow.new
   scrolled_view.border_width = 2
   scrolled_view.add(tree_view)
   scrolled_view.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

   #笔记路径树
   renderer = Gtk::CellRendererText.new
   tree_col = Gtk::TreeViewColumn.new("Note Dir List", renderer, :text => 0)
   tree_view.append_column(tree_col)
   tree_view.signal_connect("row-activated") { del_note_dir(tree_view,tree_store)}
  
  #选择笔记路径
  choo_dir_btt  = Gtk::FileChooserButton.new(
    "Choose a Folder", Gtk::FileChooser::ACTION_SELECT_FOLDER)
  choo_dir_btt.signal_connect('selection_changed') do |w|
   #笔记列表树中添加节点
   note_dir_sel = tree_store.append(nil)
   note_dir_sel[0] = w.filename
  end
    

  hbox_1 = Gtk::HBox.new(false, 5)
  hbox_1.pack_start_defaults(scrolled_view);
  hbox_3 = Gtk::HBox.new(false, 5)
  hbox_3.pack_start_defaults(Gtk::Label.new("Add"));
  hbox_3.pack_start_defaults(choo_dir_btt);
  
  dialog.vbox.add(hbox_1)
  dialog.vbox.add(hbox_3)
  dialog.show_all

  dialog.run do |response|
    if response == Gtk::Dialog::RESPONSE_OK
      note_dir_list = Array.new   
      #遍历tree_store
      iter = tree_store.iter_first
      begin
         note_dir_list.push(iter[0])
         puts iter[0]
      end while iter.next!
      
      yam_save.transaction do 
        yam_save["NoteDirList"] = note_dir_list
      end
    end
    dialog.destroy
  end
  
end

def del_note_dir(tree_view,tree_store)
    selection = tree_view.selection
    iter = selection.selected  
    #tree_store.remove(iter)
    tree_store.clear
end
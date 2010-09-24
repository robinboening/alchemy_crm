module ElementsControllerExtension
  
  def teasables
    @pages = Page.language_root(session[:language]).descendants
    @content = Content.find(params[:content_id])
    @element = @content.element
    @elements = Element.find_all_by_name(@content.settings[:teasable_elements])
    render :layout => false
  end
  
  def update_from_element
    begin
      @element = Element.find(params[:id])
      @source_element = Element.find(params[:source_element_id])
      if params[:link_only].blank?
        @element.update_from_element(@source_element, current_server)
      else
        teaser = @element.contents.find_by_essence_type("EssenceElementTeaser")
        if !teaser.essence.blank?
          teaser.essence.url = File.join(current_server, "#{@source_element.page.urlname}##{@source_element.name}_#{@source_element.id}")
          teaser.essence.save
        end
      end
      @page = @element.page
      render :action => "update"
    rescue
      log_error($!)
      render :update do |page|
        Alchemy::Notice.show_via_ajax(page, 'Das Element konnte nicht übernommen werden.', :error)
      end
    end
  end
  
end
Admin::ElementsController.send(:include, ElementsControllerExtension)

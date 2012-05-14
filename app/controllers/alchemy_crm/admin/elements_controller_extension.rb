# encoding: UTF-8
# Extending Alchemy::Admin::ElementsController

Alchemy::Admin::ElementsController.class_eval do

  def teasables
    @pages = Alchemy::Page.language_root_for(session[:language_id]).descendants
    @content = Content.find(params[:content_id])
    @element = @content.element
    @elements = Alchemy::Element.where(:name => @content.settings[:teasable_elements])
    render :layout => false
  end

  def fill
    @element = Alchemy::Element.find(params[:id])
    @source_element = Alchemy::Element.find(params[:source_element_id])
    @params = "?page_id=#{@source_element.page.id}&element_id=#{@source_element.id}"
    @content = @element.contents.where(:essence_type => "EssenceRichtext")
    @target_contents = []
    @source_element.contents.each do |content|
      @target_contents << @element.contents.select { |c| c.essence_type == content.essence_type && c.name == content.name }
    end
  end

  def link
    @element = Alchemy::Element.find(params[:id])
    @source_element = Alchemy::Element.find(params[:source_element_id])
    @content = @element.contents.where(:essence_type => "EssenceElementTeaser")
    @params = "?page_id=#{@source_element.page.id}&element_id=#{@source_element.id}"
  end

end

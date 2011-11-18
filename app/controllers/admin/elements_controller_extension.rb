# encoding: UTF-8
# Extending Alchemys ElementsController

ElementsController.class_eval do

	 def teasables
		@pages = Page.language_root_for(session[:language_id]).descendants
		@content = Content.find(params[:content_id])
		@element = @content.element
		@elements = Element.find_all_by_name(@content.settings[:teasable_elements])
		render :layout => false
	end

	def fill
		@element = Element.find(params[:id])
		@source_element = Element.find(params[:source_element_id])
		@params = "?page_id=#{@source_element.page.id}&element_id=#{@source_element.id}"
		@content = @element.contents.find_by_essence_type("EssenceRichtext")
		render :update do |page|
			@source_element.contents.each do |content|
				target_contents = @element.contents.select { |c| c.essence_type == content.essence_type && c.name == content.name }
				target_contents.each do |tc|
					page << "jQuery('##{tc.form_field_id}').val('#{escape_javascript(content.ingredient)}')"
					page << "tinymce.get('#{tc.form_field_id}').load();" if content.essence_type == "EssenceRichtext"
				end
			end
			page << "jQuery('##{@content.form_field_id(:url)}').val('#{@params}')"
			page.call "Alchemy.setElementDirty", "#element_#{@element.id}"
			page.call "Alchemy.PreviewWindow.refresh"
			page.call "Alchemy.closeCurrentWindow"
			Alchemy::Notice.show(page, _("Inhalte wurden übernommen"))
		end
	end

	def link
		@element = Element.find(params[:id])
		@source_element = Element.find(params[:source_element_id])
		@content = @element.contents.find_by_essence_type("EssenceElementTeaser")
		@params = "?page_id=#{@source_element.page.id}&element_id=#{@source_element.id}"
		render :update do |page|
			page.call "Alchemy.closeCurrentWindow"
		end
	end

end

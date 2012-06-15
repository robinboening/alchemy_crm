Alchemy::PagesHelper.module_eval do

  def render_page_layout(options={})
    default_options = {
      :render_format => "html"
    }
    options = default_options.merge(options)
    if @page.layout_description['newsletter']
      render :partial => "alchemy/newsletter_layouts/#{@page.page_layout.downcase}", :format => options[:render_format]
    else
      render :partial => "alchemy/page_layouts/#{@page.page_layout.downcase}", :format => options[:render_format]
    end
  rescue ActionView::MissingTemplate
    warning("PageLayout: '#{@page.page_layout}' not found. Rendering standard page_layout.")
    render :partial => "alchemy/page_layouts/standard"
  end

end

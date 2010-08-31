class Admin::TagsController < AlchemyMailingsController
  
  layout "alchemy"
  helper :tags
  
  filter_access_to :all
  
  before_filter :set_gettext_domain
  
  def index
    @tags = Tag.find(:all, :order => "name ASC")
  end
  
  def new
    @tag = Tag.new
    render :layout => false
  end
  
  def create
    @tag = Tag.new(params[:tag])
    if @tag.save
      flash[:notice] = _('New Tag Created')
      redirect_to admin_tags_path
    else
      render :action => 'new'
    end
  end
  
  def edit
    @tag = Tag.find(params[:id])
    @tags = Tag.find(:all, :order => "name ASC") - [@tag]
    render :layout => false
  end
  
  def update
    @tag = Tag.find(params[:id])
    case params[:commit]
      when "ersetzen"
      then
        @new_tag = Tag.find(params[:tag][:merge_to])
        Contact.replace_tag @tag, @new_tag
        operation_text = "Das Tag '#{@tag.name}' wurde durch das Tag '#{@new_tag.name}' ersetzt"
        @tag.destroy
    when "umbenennen"
      then
        @tag.update_attributes(params[:tag])
        @tag.save
        operation_text = "Das Tag wurde gespeichert"
    end
    render_errors_or_redirect @tag, "/admin/tags", operation_text
  end
  
  def destroy
    @tag = Tag.find(params[:id])
    if request.delete?
      @tag.destroy
      flash[:notice] = "Das Tag wurde gelöscht"
    end
    redirect_to :controller => "tags", :action => "index"
  end

protected
  
  def set_gettext_domain
    FastGettext.text_domain = 'alchemy-mailings'
  end
  
end

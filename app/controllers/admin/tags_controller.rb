# encoding: UTF-8

class Admin::TagsController < AlchemyMailingsController

  filter_access_to :all
  
  def index
    @tags = ActsAsTaggableOn::Tag.where(
      "name LIKE '%#{params[:query]}%'"
    ).paginate(
      :page => params[:page] || 1, 
      :per_page => 20
    ).order("name ASC")
  end
  
  def new
    @tag = ActsAsTaggableOn::Tag.new
    render :layout => false
  end
  
  def create
    @tag = ActsAsTaggableOn::Tag.new(params[:tag])
    if @tag.save
      flash[:notice] = _('New Tag Created')
      redirect_to admin_tags_path
    else
      render :action => 'new'
    end
  end
  
  def edit
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
    @tags = ActsAsTaggableOn::Tag.order("name ASC").all - [@tag]
    render :layout => false
  end
  
  def update
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
    case params[:commit]
      when "ersetzen"
      then
        @new_tag = ActsAsTaggableOn::Tag.find(params[:tag][:merge_to])
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
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
    if request.delete?
      @tag.destroy
      flash[:notice] = "Das Tag wurde gelöscht"
    end
    redirect_to :controller => "tags", :action => "index"
  end

end

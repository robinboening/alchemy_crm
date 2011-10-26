# encoding: UTF-8

class Admin::ContactGroupsController < AlchemyMailingsController
  
  filter_access_to :all
  
  def index
    @contact_groups = ContactGroup.where(
      ["name LIKE '%#?%'", params[:query]]
    ).paginate(
      :page => params[:page] || 1,
      :per_page => 20
    ).order("name ASC")
  end
  
  def new
    @contact_group = ContactGroup.new
    @contacts = Contact.all
    @new_tags = ActsAsTaggableOn::Tag.order("name ASC").all
    render :layout => false
  end
  
  def create
    @contact_group = ContactGroup.new(params[:contact_group])
    @contact_group.save
    render_errors_or_redirect(@contact_group, admin_contact_groups_path, "Die Gruppe wurde angelegt.")
  end
  
  def edit
    @contact_group = ContactGroup.find(params[:id])
    @contacts = Contact.all
    @old_tags = []
    @new_tags = []
    ActsAsTaggableOn::Tag.find(:all, :order => "name ASC").each{ |tag| (tag.created_at > @contact_group.updated_at) ? @new_tags << tag : @old_tags << tag }
    render :layout => false
  end
  
  def update
    @contact_group = ContactGroup.find(params[:id])
    params[:contact_group][:tag_list] = {} if params[:contact_group][:tag_list].nil?
    @contact_group.update_attributes(params[:contact_group])
    render_errors_or_redirect(@contact_group, admin_contact_groups_path, "Die Gruppe wurde gespeichert.")
  end
  
  def destroy
    @contact_group = ContactGroup.find(params[:id])
    @contact_group.destroy
    flash[:notice] = "Die Gruppe wurde gelöscht."
  end
  
  def add_filter
    filter = ContactGroupFilter.new
    render :update do |page|
      page.insert_html :bottom, "filter_container", :partial => "filter", :object => filter, :locals => {:count => params[:size]}
    end
  end
  
end

# encoding: UTF-8

class Admin::ContactGroupsController < AlchemyMailingsController
  
  filter_access_to :all
  
  def index
    @contact_groups = ContactGroup.where(
      "name LIKE '%#{params[:query]}%'"
    ).paginate(
      :page => params[:page] || 1,
      :per_page => 20
    ).order("name ASC")
  end
  
  def new
    @contact_group = ContactGroup.new
    @contacts = Contact.all
    @tags = ActsAsTaggableOn::Tag.order("name ASC").all
    render :layout => false
  end
  
  def create
    @contact_group = ContactGroup.create(params[:contact_group])
    render_errors_or_redirect(@contact_group, admin_contact_groups_path, "Die Zielgruppe wurde angelegt.")
  end
  
  def edit
    @contact_group = ContactGroup.find(params[:id])
    @contacts = Contact.all
    @tags = ActsAsTaggableOn::Tag.order("name ASC").all
    render :layout => false
  end
  
  def update
    @contact_group = ContactGroup.find(params[:id])
    @contact_group.update_attributes(params[:contact_group])
    render_errors_or_redirect(@contact_group, admin_contact_groups_path, "Die Zielgruppe wurde gespeichert.")
  end
  
  def destroy
    @contact_group = ContactGroup.find(params[:id])
    @contact_group.destroy
    flash[:notice] = "Die Zielgruppe wurde gelöscht."
  end
  
  def add_filter
    @filter = ContactGroupFilter.new
    @count = params[:size]
  end
  
end

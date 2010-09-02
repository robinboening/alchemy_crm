class Admin::ContactGroupsController < AlchemyMailingsController
  
  layout "alchemy"
  
  filter_access_to :all
  
  def index
    @contact_groups = ContactGroup.find(
      :all,
      :order => "name ASC",
      :conditions => "name LIKE '%#{params[:query]}%'"
    )
  end
  
  def new
    @contact_group = ContactGroup.new
    @contacts = Contact.find(:all)
    @new_tags = Tag.find(:all, :order => "name ASC")
    render :layout => false
  end
  
  def create
    @contact_group = ContactGroup.new(params[:contact_group])
    @contact_group.save
    @contact_group.create_contact_group_filters(params[:filters]) unless @contact_group.id.nil?
    render_errors_or_redirect(@contact_group, admin_contact_groups_path, "Die Gruppe wurde angelegt.")
  end
  
  def edit
    @contact_group = ContactGroup.find(params[:id])
    @contacts = Contact.find(:all)
    @old_tags = []
    @new_tags = []
    Tag.find(:all, :order => "name ASC").each{ |tag| (tag.created_at > @contact_group.updated_at) ? @new_tags << tag : @old_tags << tag }
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
    contact_group = ContactGroup.find(params[:id])
    filter = contact_group.contact_group_filters.build
    render :update do |page|
      page.insert_html :bottom, "filter_container", :partial => "filter", :object => filter, :locals => {:count => contact_group.contact_group_filters.size}
    end
  end
  
end

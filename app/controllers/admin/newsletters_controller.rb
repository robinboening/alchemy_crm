class Admin::NewslettersController < AlchemyController
  
  layout "alchemy"
  
  filter_access_to :all
  
  def index
    @newsletters = Newsletter.find(:all, :conditions => "name LIKE '%#{params[:query]}%'", :order => 'name ASC')
  end
  
  def new
    @newsletter = Newsletter.new
    @page_layouts = PageLayout.get_layouts_for_select(session[:language], :newsletter => true)
    @contact_groups = ContactGroup.all
    render :layout => false
  end
  
  def create
    @newsletter = Newsletter.new(params[:newsletter])
    @newsletter.save
    render_errors_or_redirect @newsletter, admin_newsletters_path, "Der Newsletter wurde angelegt."
  end
  
  def edit
    @newsletter = Newsletter.find(params[:id])
    @contact_groups = ContactGroup.find(:all, :order => "name ASC")
    @page_layouts = PageLayout.get_layouts_for_select(session[:language], :newsletter => true)
    render :layout => false
  end
  
  def update
    params[:newsletter][:contact_group_ids] ||= []
    @newsletter = Newsletter.find(params[:id])
    @newsletter.update_attributes(params[:newsletter])
    render_errors_or_redirect @newsletter, admin_newsletters_path, "Der Newsletter wurde gespeichert."
  end
  
  def destroy
    @newsletter = Newsletter.find(params[:id])
    begin
      @newsletter.destroy
      flash[:notice] = "Der Newsletter wurde gelöscht."
    rescue Exception => e
      logger.error("\n++++ ERROR: #{e}\n")
      flash[:error] = %(Es sind Fehler beim Löschen aufgetaucht. Bitte überprüfen Sie folgende Fehler: \n#{e})
    end
  end
  
end

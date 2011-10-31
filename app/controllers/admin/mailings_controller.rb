# encoding: UTF-8

class Admin::MailingsController < AlchemyMailingsController
  
  filter_access_to :all
  
  def index
		@mailings = Mailing.where(
		  "mailings.name LIKE '%#{params[:query]}%' OR mailings.subject LIKE '%#{params[:query]}%'"
		).paginate(:page => params[:page] || 1, :per_page => 30)
  end
  
  def new
    @mailing = Mailing.new
    @newsletters = Newsletter.all
    render :layout => false
  end
  
  def create
    @mailing = Mailing.create(params[:mailing])
    render_errors_or_redirect(@mailing, admin_mailings_path, "Das Mailing wurde angelegt.")
	rescue Exception => e
		exception_handler(e)
  end
  
  def copy
    @mailing = Mailing.copy(params[:id])
    @newsletters = Newsletter.all
    render :action => :new, :layout => false
  end
  
  def show
    @page = Page.find(params[:page_id])
    @mailing = Mailing.find(params[:id])
    @host = current_server
    @server = @host.gsub(/http:\/\//, '')
    @preview_mode = true
    render :layout => 'newsletters'
  end
  
  def edit
    @mailing = Mailing.find(params[:id])
    @newsletters = Newsletter.all
    render :layout => false
  end
  
  def update
    @mailing = Mailing.find(params[:id])
    @mailing.update_attributes(params[:mailing])
    render_errors_or_redirect(@mailing, :back, "Das Mailing wurde gespeichert.")
  end
  
  def destroy
    @mailing = Mailing.find(params[:id])
    @mailing.destroy
    flash[:notice] = 'Mailing wurde gelöscht'
    render :update do |page|
      page.redirect_to admin_mailings_path
      Alchemy::Notice.show(page, 'Das Mailing wurde gelöscht')
    end
  end
  
  def edit_content
    @mailing = Mailing.find(params[:id])
    @page = @mailing.page
  end
  
  def deliver
    @mailing = Mailing.find(params[:id])
    if request.post?
      @mailing.deliver!(current_server)
      flash[:notice] = "Das Mailing wurde versendet"
      redirect_to :action => 'index'
    else
      render :layout => false
    end
  end
  
end

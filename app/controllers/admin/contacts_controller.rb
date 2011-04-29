class Admin::ContactsController < AlchemyMailingsController
  
  filter_access_to :all
  
  def index
    page = params[:page] || 1
    if params[:query].blank?
      if params[:per_page] == 'all'
        @contacts = Contact.find(
          :all,
          :order => :lastname
        )
      else
        @contacts = Contact.paginate(
          :all,
          :page => page,
          :per_page => (params[:per_page] || 20),
          :order => :lastname
        )
      end
    else
      @contacts = Contact.find_by_query(
        params[:query],
        {
          :page => page,
          :per_page => (params[:per_page] || 20),
          :order => :lastname
        },
        params[:per_page] != 'all'
      )
    end
  end
  
  def new
    @contact = Contact.new
    @tags = (Tag.find(:all, :order => "name ASC") - @contact.tags)
    render :layout => false
  end
  
  def import
    if request.get?
      render :layout => false
    else
      begin
        Contact.new_from_vcard(params[:vcard])
        flash[:notice] = 'Kontakt(e) wurde importiert.'
      rescue Exception => e
        logger.error("\n++++ ERROR: #{e}\n")
        if e.record
          logger.error(e.record.inspect)
          logger.error(e.record.errors.full_messages.join("\n"))
          flash[:error] = %(Es sind Fehler beim Importieren aufgetaucht. Bitte überprüfen Sie die V-Card(s) nach folgenden Fehlern: \n#{e.record.errors.full_messages.join("\n")})
        end
      end
      redirect_to admin_contacts_path
    end
  end
  
  def create
    @contact = Contact.new(params[:contact])
    @contact.save
    render_errors_or_redirect(@contact, admin_contacts_path, "Der Kontakt wurde angelegt.")
  end
  
  def edit
    @contact = Contact.find(params[:id])
    @tags = (Tag.find(:all, :order => "name ASC") - @contact.tags)
    render :layout => false
  end
  
  def update
    @contact = Contact.find(params[:id])
    @contact.update_attributes(params[:contact])
    render_errors_or_redirect(@contact, admin_contacts_path, "Der Kontakt wurde gespeichert.")
  end
  
  def export
    @contact = Contact.find(params[:id])
    @contact.to_vcard
    send_file("#{RAILS_ROOT}/tmp/#{@contact.fullname}.vcf")
  end
  
  def destroy
    @contact = Contact.find(params[:id])
    name = @contact.fullname
    @contact.destroy
    flash[:notice] = "#{name} wurde gelöscht."
  end
  
  def auto_complete_for_contact_tag_list
    @tags = Tag.find(:all, :conditions => ['name LIKE ?', "#{params[:contact][:tag_list]}%"])
    render :inline => "<%= auto_complete_result(@tags, 'name') %>", :layout => false
  end

end

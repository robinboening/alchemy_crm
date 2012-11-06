# encoding: UTF-8

module AlchemyCrm
  module Admin
    class ContactsController < AlchemyCrm::Admin::BaseController

      include CSVMagic::ControllerActions

      csv_magic_config(
        :mapping => {
          Contact.clean_human_attribute_name(:salutation)  => :salutation,
          Contact.clean_human_attribute_name(:title)       => :title,
          Contact.clean_human_attribute_name(:firstname)   => :firstname,
          Contact.clean_human_attribute_name(:lastname)    => :lastname,
          Contact.clean_human_attribute_name(:email)       => :email,
          Contact.clean_human_attribute_name(:company)     => :company,
          Contact.clean_human_attribute_name(:address)     => :address,
          Contact.clean_human_attribute_name(:zip)         => :zip,
          Contact.clean_human_attribute_name(:city)        => :city,
          Contact.clean_human_attribute_name(:country)     => :country,
          Contact.clean_human_attribute_name(:phone)       => :phone,
          Contact.clean_human_attribute_name(:mobile)      => :mobile,
          Contact.human_attribute_name(:tag_list)          => :tag_list,
          Contact.human_attribute_name(:verified)          => :verified,
          Contact.human_attribute_name(:disabled)          => :disabled
        }
      )

      before_filter :load_tags, :only => [:new, :edit]

      def index
        if params[:query].blank?
          @contacts = Contact.scoped
        else
          search_terms = ActiveRecord::Base.sanitize("%#{params[:query]}%")
          @contacts = Contact.where(Contact::SEARCHABLE_ATTRIBUTES.map { |attribute|
            "#{Contact.table_name}.#{attribute} LIKE #{search_terms}"
          }.join(" OR "))
        end
        respond_to do |format|
          format.html {
            @contacts = @contacts.page(params[:page] || 1).per(per_page_value_for_screen_size)
          }
          format.csv {
            export_file_as(:csv)
          }
          format.xls {
            export_file_as(:xls)
          }
        end
      end

      def new
        @contact = Contact.new(:country => ::I18n.locale.to_s.upcase)
        render :layout => false
      end

      def import
        render :layout => !request.xhr?
      end

      def mass_create
        if params[:verified] == "1"
          if params[:filename] || params[:file]
            handle_file_request
          else
            @error = build_error_message(alchemy_crm_t(:missing_file))
          end
        else
          @error = build_error_message(alchemy_crm_t(:imported_contacts_not_verified))
        end
      end

      def export
        if params[:id].present?
          @contact = Contact.find(params[:id])
          @contact.to_vcard
          send_file("#{Rails.root.to_s}/tmp/#{@contact.fullname}.vcf")
        else
          render :layout => false
        end
      end

      def autocomplete_tag_list
        items = ActsAsTaggableOn::Tag.where(['LOWER(name) LIKE ?', "#{params[:term].downcase}%"])
        render :json => json_for_autocomplete(items, :name)
      end

    private

      def load_tags
        @tags = ActsAsTaggableOn::Tag.order("name ASC").all
        @tags = @tags - @contact.tags.to_a unless @contact.nil?
      end

      def build_error_message(message)
        heading = "<h1>#{alchemy_crm_t(:errors_while_importing)}</h1>".html_safe
        message = "<p>#{message}</p>".html_safe
        heading + message
      end

      # TODO: Make this with mass_create
      def create_resource_items_from_csv(*args)
        @csv_import_errors = []
        @contacts = []
        reader = CSVMagic::Reader.new(params)
        reader.each do |row|
          @contacts << contact = Contact.new(row)
          contact.verified = true
          unless contact.save
            @csv_import_errors.push [contact, contact.errors]
          end
        end
        @valid_contacts = @contacts.select(&:valid?)
        reader.remove_file if @csv_import_errors.empty?
      end

      def render_csv_import_form
        render 'import'
      end

      def handle_file_request
        if params[:fields] || !is_vcard_file?(params[:file])
          handle_csv_post_request
        else
          handle_vcf_post_request
        end
      end

      def handle_vcf_post_request
        @contacts = Contact.new_from_vcard(params[:file], true)
        if @contacts.empty?
          flash[:error] = alchemy_crm_t(:no_contacts_imported)
        elsif @contacts.detect(&:invalid?).nil?
          flash[:notice] = alchemy_crm_t(:successfully_imported_contacts)
        else
          @errors = build_error_message(alchemy_crm_t(:please_check_highlighted_vcards_on_errors))
        end
        @valid_contacts = @contacts.select(&:valid?) || []
        render :vcf_import_result
      end

      def is_vcard_file?(file)
        content = file.read
        file.rewind
        content.starts_with?("BEGIN:VCARD")
      end

      def export_file_as(format)
        @columns = AlchemyCrm::Contact::EXPORTABLE_COLUMNS
        filename = "#{AlchemyCrm::Contact.model_name.human(:count => @contacts.count)}-#{Time.now.strftime('%Y-%m-%d_%H-%M')}"
        send_data render_to_string, :type => format.to_sym, :filename => "#{filename}.#{format}"
      end

    end
  end
end

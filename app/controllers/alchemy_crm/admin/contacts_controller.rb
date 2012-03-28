# encoding: UTF-8
module AlchemyCrm
	module Admin
		class ContactsController < Alchemy::Admin::ResourcesController

			before_filter :load_tags, :only => [:new, :edit]

			def new
				@contact = Contact.new(:country => ::I18n.locale.to_s.upcase)
				render :layout => false
			end

			def import
				if request.get?
					render :import
				else
					if params[:vcard].blank?
						@errors = build_error_message(::I18n.t(:missing_vcard, :scope => :alchemy_crm))
					elsif params[:verified] == "1"
						@contacts = Contact.new_from_vcard(params[:vcard], true)
						if @contacts.detect(&:invalid?).nil?
							flash[:notice] = 'Kontakt(e) wurde(n) importiert.'
						else
							@errors = build_error_message("Bitte überprüfen Sie die markierten Visitenkarten auf Fehler.")
						end
					else
						@errors = build_error_message(::I18n.t(:imported_contacts_not_verified, :scope => :alchemy_crm))
					end
					render :import_result
				end
			end

			def export
				@contact = Contact.find(params[:id])
				@contact.to_vcard
				send_file("#{Rails.root.to_s}/tmp/#{@contact.fullname}.vcf")
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
				heading = "<h2>Es sind Fehler beim Importieren aufgetaucht!</h2>".html_safe
				heading += "<p>#{message}</p>".html_safe
			end

		end
	end
end

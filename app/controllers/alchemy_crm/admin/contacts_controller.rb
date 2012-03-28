# encoding: UTF-8
module AlchemyCrm
	module Admin
		class ContactsController < AlchemyCrm::Admin::BaseController

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
						@errors = build_error_message(alchemy_crm_t(:missing_vcard))
					elsif params[:verified] == "1"
						@contacts = Contact.new_from_vcard(params[:vcard], true)
						if @contacts.detect(&:invalid?).nil?
							flash[:notice] = alchemy_crm_t(:successfully_imported_contacts)
						else
							@errors = build_error_message(alchemy_crm_t(:please_check_highlighted_vcards_on_errors))
						end
					else
						@errors = build_error_message(alchemy_crm_t(:imported_contacts_not_verified))
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
				heading = "<h2>#{alchemy_crm_t(:errors_while_importing)}</h2>".html_safe
				heading += "<p>#{message}</p>".html_safe
			end

		end
	end
end

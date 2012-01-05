# encoding: UTF-8
module AlchemyCrm
	module Admin
		class ContactsController < Alchemy::Admin::ResourcesController

			before_filter :load_tags, :only => [:new, :edit]

			def import
				if request.get?
					render :layout => false
				else
					begin
						Contact.new_from_vcard(params[:vcard])
						flash[:notice] = 'Kontakt(e) wurde(n) importiert.'
						redirect_to admin_contacts_path
					rescue Exception => e
						exception_handler(e)
						if e.respond_to?(:record) && e.record
							logger.error(e.record.inspect)
							logger.error(e.record.errors.full_messages.join("\n"))
							flash[:error] = %(Es sind Fehler beim Importieren aufgetaucht. Bitte überprüfen Sie die V-Card(s) nach folgenden Fehlern: \n#{e.record.errors.full_messages.join("\n")})
						end
					end
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

		end
	end
end

module AlchemyMailings
  module Admin

    module ElementsController

      module InstanceMethods
        
        def fill
          if File.exists? "#{RAILS_ROOT}/config/alchemy/mailing_elements.yml"
            @mailing_elements = YAML.load_file( "#{RAILS_ROOT}/config/alchemy/mailing_elements.yml" )
          end
          @elements = Element.find_all_by_name(@mailing_elements, :include => {:contents => :essence})
          @pages = Page.find(@elements.collect { |r| r.page_id }.uniq)
          @collection = @pages.inject({}) do |result, element| 
            result[element.layout] = [] if result[element.layout].nil?
            result[element.layout] << element
            result
          end
          @element = Element.find(params[:id])
          render :layout => false
        end

        def update_from_element
          begin
            @element = Element.find(params[:id])
            @source_element = Element.find(params[:source_element_id])
            if params[:link_only].blank?
              @element.update_from_element(@source_element, get_server)
            else
              teaser = @element.all_contents_by_type("EssenceTeaserLink").first
              if !teaser.essence.blank?
                teaser.essence.url = File.join(get_server, "#{@source_element.page.urlname}##{@source_element.name}_#{@source_element.id}")
                teaser.essence.save
              end
            end
          rescue
            log_error($!)
          end
          render :action => "elements/update"
        end
        
      end

    end

  end
end
Admin::ElementsController.send(:include, AlchemyMailings::Admin::ElementsController)

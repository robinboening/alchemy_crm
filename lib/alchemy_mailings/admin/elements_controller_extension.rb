# encoding: UTF-8

module AlchemyMailings
	module Admin
		
		module ElementsControllerExtension
			
			
		end
		
	end
end

Admin::ElementsController.send(:include, AlchemyMailings::Admin::ElementsControllerExtension)

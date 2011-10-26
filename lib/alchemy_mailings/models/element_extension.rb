module AlchemyMailings
	module Models
		module ElementExtension
			
		
		end
	end
end

Element.send(:include, AlchemyMailings::Models::ElementExtension)

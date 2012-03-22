module AlchemyCrm
	module ControllerHelpers

		def self.included(c)
			c.send(:helper_method, :current_language, :current_server, :current_host)
		end

		def current_language
			@language ||= Alchemy::Language.find(@options[:language_id])
		end

		def current_server
			@current_server ||= [@options[:protocol], @options[:host]].join
		end

		def current_host
			@current_host ||= @options[:host]
		end

	end
end

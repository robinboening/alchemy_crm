# encoding: UTF-8
module AlchemyCrm
	class ContactGroupFilter < ActiveRecord::Base

		belongs_to :contact_group
		@@operators = [["enthält", "LIKE"], ["enthält nicht", "NOT LIKE"], ["ist", "="], ["ist nicht", "!="]]

		def self.operators
			@@operators
		end

		def sql_string
			return "" if column.blank? || operator.blank? || prepared_value.blank?
			"`#{Contact.table_name}`.`#{column}` #{operator} '#{prepared_value}'"
		end

	private

		def prepared_value
			operator =~ /LIKE/ ? "%#{value}%" : "#{value}"
		end

	end
end

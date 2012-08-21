# encoding: UTF-8
module AlchemyCrm
  class ContactGroupFilter < ActiveRecord::Base

    belongs_to :contact_group

    OPERATORS = [
      [::I18n.t(:like, :scope => 'alchemy_crm.contact_group_filter_operators', :default => 'Contains'), "LIKE"],
      [::I18n.t(:not_like, :scope => 'alchemy_crm.contact_group_filter_operators', :default => 'Contains not'), "NOT LIKE"],
      [::I18n.t(:equals, :scope => 'alchemy_crm.contact_group_filter_operators', :default => 'Equals'), "="],
      [::I18n.t(:equals_not, :scope => 'alchemy_crm.contact_group_filter_operators', :default => 'Equals not'), "!="]
    ]

    def self.operator_where_string(column, value)
      [
        "(`#{self.table_name}`.`column` = '#{column}' AND `#{self.table_name}`.`operator` = 'LIKE' AND '#{value}' LIKE #{self.concatinated_value_string})",
        "(`#{self.table_name}`.`column` = '#{column}' AND `#{self.table_name}`.`operator` = 'NOT LIKE' AND '#{value}' NOT LIKE #{self.concatinated_value_string})",
        "(`#{self.table_name}`.`column` = '#{column}' AND `#{self.table_name}`.`operator` = '=' AND '#{value}' = `#{self.table_name}`.`value`)",
        "(`#{self.table_name}`.`column` = '#{column}' AND `#{self.table_name}`.`operator` = '!=' AND '#{value}' != `#{self.table_name}`.`value`)"
      ].join(" OR ")
    end

    def sql_string
      return "" if column.blank? || operator.blank? || prepared_value.blank?
      "`#{Contact.table_name}`.`#{column}` #{operator} '#{prepared_value}'"
    end

  private

    def prepared_value
      operator =~ /LIKE/ ? "%#{value}%" : "#{value}"
    end

    def self.concatinated_value_string
      if self.connection_config[:adapter].match(/sqlite/)
        "('%' || `#{self.table_name}`.`value` || '%')"
      else
        "CONCAT('%', `#{self.table_name}`.`value`, '%')"
      end
    end

  end
end

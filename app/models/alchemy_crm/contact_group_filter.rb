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
        "(`#{table_name}`.`column` = '#{column}' AND `#{table_name}`.`operator` = 'LIKE' AND #{sanitize(value)} LIKE #{concatinated_value_string})",
        "(`#{table_name}`.`column` = '#{column}' AND `#{table_name}`.`operator` = 'NOT LIKE' AND #{sanitize(value)} NOT LIKE #{concatinated_value_string})",
        "(`#{table_name}`.`column` = '#{column}' AND `#{table_name}`.`operator` = '=' AND #{sanitize(value)} = `#{table_name}`.`value`)",
        "(`#{table_name}`.`column` = '#{column}' AND `#{table_name}`.`operator` = '!=' AND #{sanitize(value)} != `#{table_name}`.`value`)"
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

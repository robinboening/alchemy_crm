class ContactGroupFilter < ActiveRecord::Base
  belongs_to :contact_group
  @@operators = [["enthält", "LIKE"], ["enthält nicht", "NOT LIKE"], ["ist", "="], ["ist nicht", "!="]]
  
  def self.operators
    @@operators
  end
  
  def to_sql
    return "" if column.blank? || operator.blank? || prepared_value.blank?
    " AND #{self.column} #{self.operator} '#{prepared_value}'"
  end
  
  private
  
  def prepared_value
    (operator == "LIKE" || operator == "NOT LIKE") ? "%#{value}%" : "#{value}"
  end
  
end

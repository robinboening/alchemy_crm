class ContactGroup < ActiveRecord::Base
  acts_as_taggable
  has_many :contact_group_filters, :dependent => :destroy 
  validates_presence_of :name, :message => "Bitte geben Sie einen Namen an."
  
  def contacts
    return [] if self.tags.blank?
    options = Contact.find_options_for_find_tagged_with(self.tags)
    options[:conditions] += hash_to_sql
    Contact.find(:all, options)
  end
  
  # Baut eine Sql-Query aus dem Filter-Hash
  # Hash Format:
  # {column1 => [wert1, wert2], column2 => [wert3]}
  # Resultierenden Sql-Query:
  # "column1 = wert1 OR column1 = wert2 AND column2 = wert3"
  def hash_to_sql
    filters.inject("") do |sum, filter|
      sum << filter.to_sql
    end
  end
  
  def humanized_name
    "#{self.name} (#{self.contacts.length})"
  end
  
  def filters
    contact_group_filters
  end
  
  #deletes all contact_group_filters and creates new ones
  def create_contact_group_filters filters
    self.contact_group_filters.clear
    return if filters.nil?
    filters.values.each do |filter|
      self.contact_group_filters.create(filter)
    end
  end
  
end
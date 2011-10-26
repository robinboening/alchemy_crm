# encoding: UTF-8

class Newsletter < ActiveRecord::Base
  
  has_and_belongs_to_many :contact_groups
  has_many :mailings
  has_many :newsletter_subscriptions
  has_many :contacts, :through => :newsletter_subscriptions, :uniq => true
  validates_presence_of :name, :message => "Bitte geben Sie einen Namen an."
  before_destroy :can_delete_mailings?
  
  named_scope :subscribables, :conditions => {:public => true}
  
  def all_contacts
    (all_contact_group_contacts + verified_direct_contacts).uniq
  end
  
  def contacts_count
    self.contacts.count + contact_groups.inject(0){ |sum, cg| sum += cg.contacts.count }
  end
  
  #get all uniq contacts from my contact groups
  def all_contact_group_contacts
    self.contact_groups.inject([]){|contacts, contact_group| contacts + contact_group.contacts}.uniq
  end
  
  def humanized_name
    "#{self.name} (#{self.contacts_count})"
  end
  
  def verified_direct_contacts
    contacts.find(:all, :conditions => ["newsletter_subscriptions.verified = ? AND newsletter_subscriptions.wants = ?", true, true])
  end
  
  def can_delete_mailings?
    raise "Cannot delete Newsletter because of referencing Mailings with IDs (#{mailings.collect(&:id).join(", ")})" if(mailings.length != 0)
  end
  
  def layout_name
    AlchemyMailings::NewsletterLayout.display_name_for(self.layout)
  end
  
end

class Recipient < ActiveRecord::Base
  belongs_to :sent_mailing
  belongs_to :contact
  validates_presence_of :email
  validates_presence_of :sent_mailing_id
end

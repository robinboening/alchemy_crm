module AlchemyCrm
  class Subscription < ActiveRecord::Base

    attr_accessible :contact, :newsletter, :verified, :wants

    belongs_to :contact
    belongs_to :newsletter

  end
end

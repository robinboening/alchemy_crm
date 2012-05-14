module AlchemyCrm
  class Reaction < ActiveRecord::Base

    belongs_to :recipient
    belongs_to :page
    belongs_to :element

  end
end

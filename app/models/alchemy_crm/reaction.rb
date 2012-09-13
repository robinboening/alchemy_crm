module AlchemyCrm
  class Reaction < ActiveRecord::Base

    attr_accessible(
      :element_id,
      :page_id,
      :url
    )

    belongs_to :recipient
    belongs_to :page
    belongs_to :element

  end
end

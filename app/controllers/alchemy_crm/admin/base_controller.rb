module AlchemyCrm
  module Admin
    class BaseController < Alchemy::Admin::ResourcesController
      include I18nHelpers
    end
  end
end
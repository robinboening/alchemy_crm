Dummy::Application.routes.draw do
  mount AlchemyCrm::Engine => '/newsletter'
  mount Alchemy::Engine => '/'
end

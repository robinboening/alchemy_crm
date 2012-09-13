FactoryGirl.define do

  factory :user, :class => 'Alchemy::User' do
    email 'john@doe.com'
    login "jdoe"
    password 's3cr3t'
    password_confirmation 's3cr3t'

    factory :admin_user do
      role "admin"
    end
  end

  factory :contact, :class => 'AlchemyCrm::Contact' do
    salutation 'mr'
    firstname  'Jon'
    lastname   'Doe'
    email      'jon@doe.com'
  end

end

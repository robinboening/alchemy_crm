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

  factory :recipient, :class => 'AlchemyCrm::Recipient' do
    email  'foo@baz.org'
    contact { FactoryGirl.create :verified_contact }
  end

  factory :contact, :class => 'AlchemyCrm::Contact' do
    email       'jon@doe.com'
    firstname   'Jon'
    lastname    'Doe'
    salutation  'mr'

    factory :verified_contact do
      verified true
    end
  end

  factory :delivery, :class => 'AlchemyCrm::Delivery' do
    recipients { [FactoryGirl.create(:recipient)] }
    mailing    { FactoryGirl.create(:mailing) }
  end

  factory :mailing, :class => 'AlchemyCrm::Mailing' do
    name                       'Mailing'
    subject                    'News Mailing'
    additional_email_addresses "jim@family.com, jon@doe.com, jane@family.com, \n"
    newsletter                 { FactoryGirl.create :newsletter }
  end

  factory :newsletter, :class => 'AlchemyCrm::Newsletter' do
    name   'Newsletter'
    layout 'newsletter_layout_standard'
  end

 factory :page, :class => 'Alchemy::Page' do

   language { Alchemy::Language.get_default || FactoryGirl.create(:language) }
   sequence(:name) { |n| "A Page #{n}" }
   parent_id { (Alchemy::Page.find_by_language_root(true) || FactoryGirl.create(:language_root_page)).id }
   page_layout "standard"

   # This speeds up creating of pages dramatically. Pass :do_not_autogenerate => false to generate elements
   do_not_autogenerate true

   factory :language_root_page do
     name 'Startseite'
     language_root true
     public true
     parent_id { Alchemy::Page.root.id }
   end

   factory :public_page do
     public      true
   end

   factory :unsubscribe_page do
     public      true
     name        'Unsubscribe Page'
     page_layout 'newsletter_signout'
   end

 end

end

authorization do
  
  role :guest do
    has_permission_on :alchemy_crm_mailings, :to => [:show]
  end
  
  role :registered do
    includes :guest
  end
  
  role :author do
    includes :registered
  end
  
  role :editor do
    includes :author
  end
  
  role :admin do
    includes :editor
    has_permission_on :alchemy_crm_admin_mailings, :to => [:manage, :edit_content, :deliver, :copy]
    has_permission_on :alchemy_crm_admin_deliveries, :to => [:manage]
    has_permission_on :alchemy_crm_admin_newsletters, :to => [:manage]
    has_permission_on :alchemy_crm_admin_contacts, :to => [:manage, :import, :export, :autocomplete_tag_list]
    has_permission_on :alchemy_crm_admin_tags, :to => [:manage]
    has_permission_on :alchemy_crm_admin_contact_groups, :to => [:manage, :add_filter]
  end
  
end

privileges do
  
  privilege :manage do
    includes :index, :new, :create, :show, :edit, :update, :destroy
  end
  
end

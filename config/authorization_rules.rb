authorization do
  
  role :guest do
    has_permission_on :newsletters, :to => [:show]
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
    has_permission_on :admin_mailings, :to => [:manage, :edit_content, :deliver, :copy]
    has_permission_on :admin_sent_mailings, :to => [:manage, :pdf]
    has_permission_on :admin_newsletters, :to => [:manage]
    has_permission_on :admin_contacts, :to => [:manage, :import, :export, :auto_complete_for_contact_tag_list]
    has_permission_on :admin_tags, :to => [:manage]
    has_permission_on :admin_contact_groups, :to => [:manage, :add_filter]
  end
  
end

privileges do
  
  privilege :manage do
    includes :index, :new, :create, :show, :edit, :update, :destroy
  end
  
end

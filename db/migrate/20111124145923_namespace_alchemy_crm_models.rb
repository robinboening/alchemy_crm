class NamespaceAlchemyCrmModels < ActiveRecord::Migration

  def change
    rename_table :mailings,                     :alchemy_crm_mailings
    rename_table :newsletters,                  :alchemy_crm_newsletters
    rename_table :contacts,                     :alchemy_crm_contacts
    rename_table :sent_mailings,                :alchemy_crm_deliveries
    rename_table :recipients,                   :alchemy_crm_recipients
    rename_table :contact_groups,               :alchemy_crm_contact_groups
    rename_table :contact_group_filters,        :alchemy_crm_contact_group_filters
    rename_table :newsletter_subscriptions,     :alchemy_crm_subscriptions
    rename_table :reactions,                    :alchemy_crm_reactions
    rename_table :essence_element_teasers,      :alchemy_essence_element_teasers
    rename_table :contact_groups_newsletters,   :alchemy_contact_groups_newsletters
  end

end

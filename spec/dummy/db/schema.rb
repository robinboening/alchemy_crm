# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120327174301) do

  create_table "alchemy_contact_groups_newsletters", :id => false, :force => true do |t|
    t.integer "contact_group_id"
    t.integer "newsletter_id"
  end

  add_index "alchemy_contact_groups_newsletters", ["contact_group_id", "newsletter_id"], :name => "contact_group_newsletter_index", :unique => true

  create_table "alchemy_crm_contact_group_filters", :force => true do |t|
    t.string   "column"
    t.string   "value"
    t.string   "operator"
    t.integer  "contact_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
  end

  create_table "alchemy_crm_contact_groups", :force => true do |t|
    t.string   "name"
    t.string   "string"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.text     "cached_contact_tag_list"
  end

  create_table "alchemy_crm_contacts", :force => true do |t|
    t.string   "title"
    t.string   "salutation"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "phone"
    t.string   "mobile"
    t.string   "address"
    t.string   "zip"
    t.string   "city"
    t.string   "country"
    t.string   "organisation"
    t.string   "email_sha1"
    t.string   "email_salt"
    t.boolean  "verified",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.text     "cached_tag_list"
    t.boolean  "disabled",        :default => false
  end

  add_index "alchemy_crm_contacts", ["email"], :name => "index_alchemy_crm_contacts_on_email"
  add_index "alchemy_crm_contacts", ["email_sha1"], :name => "index_alchemy_crm_contacts_on_email_sha1"

  create_table "alchemy_crm_deliveries", :force => true do |t|
    t.string   "name"
    t.integer  "mailing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "deliver_at"
    t.datetime "delivered_at"
  end

  create_table "alchemy_crm_mailings", :force => true do |t|
    t.string   "name"
    t.string   "subject"
    t.string   "salt"
    t.string   "sha1"
    t.integer  "page_id"
    t.text     "additional_email_addresses"
    t.integer  "newsletter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
  end

  add_index "alchemy_crm_mailings", ["sha1"], :name => "index_alchemy_crm_mailings_on_sha1"

  create_table "alchemy_crm_newsletters", :force => true do |t|
    t.string   "name"
    t.string   "layout"
    t.boolean  "public",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
  end

  create_table "alchemy_crm_reactions", :force => true do |t|
    t.integer  "recipient_id"
    t.integer  "page_id"
    t.integer  "element_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "url"
  end

  add_index "alchemy_crm_reactions", ["recipient_id"], :name => "index_alchemy_crm_reactions_on_recipient_id"

  create_table "alchemy_crm_recipients", :force => true do |t|
    t.string   "email"
    t.boolean  "bounced",     :default => false
    t.boolean  "read",        :default => false
    t.boolean  "reacted",     :default => false
    t.integer  "delivery_id"
    t.integer  "contact_id"
    t.string   "message_id"
    t.datetime "read_at"
    t.datetime "bounced_at"
    t.datetime "reacted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sha1"
    t.string   "salt"
  end

  add_index "alchemy_crm_recipients", ["contact_id"], :name => "index_alchemy_crm_recipients_on_contact_id"
  add_index "alchemy_crm_recipients", ["delivery_id"], :name => "index_alchemy_crm_recipients_on_delivery_id"
  add_index "alchemy_crm_recipients", ["email"], :name => "index_alchemy_crm_recipients_on_email"
  add_index "alchemy_crm_recipients", ["message_id"], :name => "index_alchemy_crm_recipients_on_message_id"
  add_index "alchemy_crm_recipients", ["sha1"], :name => "index_alchemy_crm_recipients_on_sha1"

  create_table "alchemy_crm_subscriptions", :force => true do |t|
    t.integer "contact_id"
    t.integer "newsletter_id"
    t.boolean "wants",         :default => true
    t.boolean "verified",      :default => false
  end

  add_index "alchemy_crm_subscriptions", ["contact_id", "newsletter_id"], :name => "contact_newsletter_index", :unique => true

  create_table "alchemy_essence_element_teasers", :force => true do |t|
    t.string   "url"
    t.string   "title"
    t.string   "text"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
  end

end

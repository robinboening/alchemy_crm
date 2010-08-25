class CreateMailingRootPage < ActiveRecord::Migration
  def self.up
    root = Page.root
    unless root.blank?
      news_root = Page.create(:name => "Mailing Root", :urlname => "mailing_root", :do_not_autogenerate => true, :sitemap => false)
      news_root.move_to_child_of root
    end
  end

  def self.down
    news_root = Page.find_by_name_and_systempage("Mailing Root", true)
    unless news_root.blank?
      news_root.destroy
    end
  end
end

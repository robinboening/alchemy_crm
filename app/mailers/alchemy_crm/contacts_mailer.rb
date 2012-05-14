module AlchemyCrm
  class ContactsMailer < ActionMailer::Base

    def signup_mail(contact, page)
      @contact = contact
      @newsletter_ids = @contact.subscriptions.collect(&:newsletter_id)
      @element = page.elements.where(:name => 'newsletter_signup_mail').first
      mail(
        :from => @element.ingredient('mail_from'),
        :to => contact.email,
        :subject => @element.ingredient('subject')
      )
    end

    def signout_mail(contact, page)
      @element = page.elements.where(:name => 'newsletter_signout_mail').first
      @contact = contact
      mail(
        :from => @element.ingredient("mail_from"),
        :to => contact.email,
        :subject => @element.ingredient('subject')
      )
    end

  end
end

# encoding: UTF-8
module AlchemyCrm
  class SubscriptionsMailer < ActionMailer::Base
    default :from => AlchemyCrm::Config.get(:mail_from)

    def overview_mail(contact, element)
      @contact = contact
      @subscriptions = contact.subscriptions
      @element = element
      mail(
        :from => element.ingredient("mail_from").presence || AlchemyCrm::Config.get(:mail_from),
        :to => contact.email,
        :subject => element.ingredient("mail_subject").presence || AlchemyCrm::Config.get(:mail_from)
      )
    end

  end
end

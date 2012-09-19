# ToDos:

## After saving Newsletter

* Perhaps: Asynchronous creation of subscriptions

## Current Signout function

* should use Subscription removing

## Specs

* Fix failing specs

## Misc

* Rebase alchemy_crm v2.0 into this branch.

* Signout must be viewed.

* Signup process must be viewed.

## Investigations

* Why not creating Recipients for additional email adresses? Everyone who receives an email is a recipient. Currently we are sending mails to recipients only, so additional email addresses will be ignored.

* When a user subscribes to a newsletter for the first time, the subscription will probably not created because he is not verified. We need to create the subscription when the user verifies his contact. Do we still know the newsletter the subscription has to be created for?

* Fill recipient.email while create from contact if contact but no email is given

# ToDos:

## After saving Newsletter

* Perhaps: Asynchronous creation of subscriptions

## Current Signout function

* should use Subscription removing

## Specs

* sqlite3 throws ugly error for manually used insert statements. (see Subscription.mass_create and also Recipient.mass_create)

## Investigations

* Why not creating Recipients for additional email adresses? Everyone who recieves an email is a recipient. Currently we are sending mails to recipients only, so additional email addresses will be ignored.

## Misc

* When a user subscribes to a newsletter, the subscription will not be created because he is not verified. We need to create the subscription when the user verifies his contact.

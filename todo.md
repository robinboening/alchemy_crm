# ToDos:

## After saving Newsletter

* Perhaps: Asynchronous creation of subscriptions

## after saving ContactGroup

* Adding subscriptions after saving contact_groups

* Remove subscriptions after saving contact_groups

* Update contacts counter_cache column

## E-Mail delivering


## Misc

* Do we really need the :wants attribute on subscription? (If a user dont want to get a newsletter, he needs no subscription.)

* When a user subscribes to a newsletter, the subscription will not be created because he is not verified. We need to create the subscription when the user verifies his contact.

## SQL Indexes

* alchemy_crm_contacts: verfied + disabled => available

* on contact_group_id column on alchemy_crm_subscriptions

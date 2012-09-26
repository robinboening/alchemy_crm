# ToDos:

* Perhaps: Asynchronous creation of subscriptions??

* pending deliveries has to also count additional emails (??)

* counter cache for tag contacts_count?? -> PR for acts-as-taggable-on

* updating contact groups takes very long
 - removing tag with 32k contacts: 11641ms (DISTINCT) / 5528ms (Array#uniq)
 - adding tag with 32k contacts: 27312ms (DISTINCT) / 21447ms (Array#uniq)

* updating newsletters takes very long

* sending mails slows down the server. we should check rendering of mails and speed this up if possible.

* opening delivery statistics takes long

* newsletter edit form -> contactgroups select with js filter box like contactgroups form tag select.

* implement subscriptions handling workflow for contacts

* FIX export contact as vcf

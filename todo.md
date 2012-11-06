# TODO

## High

- FIX export contact as vcf

- Fix import of exported file
  - exported file has one new line too much

- Enhance newsletter#destroy
  - Completed 200 OK in 146564ms (Views: 101.1ms | ActiveRecord: 8199.8ms)
  - dependent destroy is surely too slow
  - Newsletter destroy confirm overlay needs a please wait overlay.

- Mass create contacts from CSV, or background task?

- Enhance delivery statistics
  - takes very long

## Low

- has pending deliveries also to count additional emails?

- implement subscriptions handling workflow for contacts

## Check

- Mailing#show
  - as anonymous
  - as contact / recipient

- unsubscribe workflow

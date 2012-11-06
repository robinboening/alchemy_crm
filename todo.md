# TODO

## High

- FIX export contact as vcf

- Fix import of exported file
  - exported file has one new line too much
  - Fix the mapper (columns in dropdowns are english)
  - Add verified as column to mapper

- Fix newsletter#destroy (hangs server if lots of contacts are subscribed)
  - dependent destroy is surely too slow

- Mass create contacts from CSV

## Low

- has pending deliveries also to count additional emails?

- opening delivery statistics takes long

- implement subscriptions handling workflow for contacts

## Check

- Mailing#show
  - as anonymous
  - as contact / recipient

- unsubscribe workflow

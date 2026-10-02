# Implementation notes — Reading List

## Agreed requirements

- Public demonstration with disposable data. No accounts, sign-in, or per-user ownership; anyone may list, view,
  add, edit, and delete any book.
- A new Book's Finished checkbox starts unchecked. The Plan authors a `false` default on `book.finished`, but the
  current release reports gap `foundation_plan.gap.field_modifier.default` (default not applied). After Compile,
  make sure the New form shows Finished unchecked and that a record created without the value stores `false`
  (for example, a migration column default plus a model default).
  - Example: open New Book, enter only Title and Author, save → the book shows Finished: No.
  - Verified 2026-10-02: the New form renders Finished unchecked and saving it stores `false`. Still open: the
    `books.finished` column has no database default and `Book.new.finished` is `nil`, so non-form creates that
    omit the value fail validation.
- The Books list shows each book's Author and Finished status beside its Title. The analyzer warned about the
  index projection, but the generated list already renders all three (verified 2026-10-02).
- Not to be published to GitHub or deployed as part of the initial build.

## Open questions

- None.

# Implementation notes — Reading List

## Agreed requirements

- Public demonstration with disposable data. No accounts, sign-in, or per-user ownership; anyone may list, view,
  add, edit, and delete any book.
- A new Book's Finished checkbox starts unchecked. The Plan authors a `false` default on `book.finished`, but the
  current release reports gap `foundation_plan.gap.field_modifier.default` (default not applied). After Compile,
  make sure the New form shows Finished unchecked and that a record created without the value stores `false`
  (for example, a migration column default plus a model default).
  - Example: open New Book, enter only Title and Author, save → the book shows Finished: No.
  - Done 2026-10-02: the New form renders Finished unchecked, and migration
    `20261002152932_change_books_finished_default` gives `books.finished` a `false` database default, so
    `Book.new.finished` is `false` and creates that omit the value store `false` (covered in
    `spec/models/book_spec.rb`). `.firstdraft/gaps.json` is the retained analysis record and is left unchanged.
- The Books list shows each book's Author and Finished status beside its Title. The analyzer warned about the
  index projection, but the generated list already renders all three (verified 2026-10-02).
- Later decision (2026-10-02): the source is in public GitHub repository `jelaniwoods/fd-reading-app` and deploys to
  Render (free web service, auto-deploy on commit) with a Neon Postgres 18 database in AWS us-east-2.
- The page background uses a subtle geometric (diamond lattice) pattern drawn from theme tokens
  (`.app-backdrop` in `app/assets/stylesheets/application.tailwind.css`); cards and the header stay solid.

## Open questions

- None.

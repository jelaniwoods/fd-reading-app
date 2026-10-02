require "rails_helper"

RSpec.describe "Book forms", type: :system do
  it "creates a record through its form" do
    existing_ids = Book.pluck(:id)

    submitted_values = {title: "title", author: "author", note: "note", finished: true}

    visit new_book_path

    within "main form" do
      fill_in "book[title]", with: submitted_values.fetch(:title)
      fill_in "book[author]", with: submitted_values.fetch(:author)
      fill_in "book[note]", with: submitted_values.fetch(:note)
      check "book[finished]"
      find("[type=submit]").click
    end
    wait_for_turbo

    record = Book.where.not(id: existing_ids).sole

    expect(record).to have_attributes(**submitted_values)
  end

  it "edits the record through its form" do
    record = create(:book, title: "title")

    submitted_values = {title: "title_updated", author: "author_updated", note: "note_updated", finished: false}

    expect(record.title).not_to eq(submitted_values.fetch(:title))

    visit edit_book_path(record)

    within "main form" do
      fill_in "book[title]", with: submitted_values.fetch(:title)
      fill_in "book[author]", with: submitted_values.fetch(:author)
      fill_in "book[note]", with: submitted_values.fetch(:note)
      uncheck "book[finished]"
      find("[type=submit]").click
    end
    wait_for_turbo

    expect(record.reload).to have_attributes(**submitted_values)
  end
end

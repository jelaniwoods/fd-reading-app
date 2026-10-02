require "rails_helper"

# == Schema Information
#
# Table name: books
#
#  id         :uuid             not null, primary key
#  author     :string           not null
#  finished   :boolean          default(FALSE), not null
#  note       :text
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
RSpec.describe Book, type: :model do
  subject { build(:book) }

  it "is valid with the required data" do
    is_expected.to be_valid
  end

  it "requires title" do
    is_expected.to validate_presence_of(:title)
  end

  it "requires author" do
    is_expected.to validate_presence_of(:author)
  end

  it "allows note to be absent" do
    is_expected.to allow_value(nil).for(:note)
  end

  it "requires finished" do
    is_expected.not_to allow_value(nil).for(:finished)
  end

  it "accepts false for finished" do
    is_expected.to allow_value(false).for(:finished)
  end

  it "starts unfinished" do
    expect(Book.new.finished).to be(false)
  end

  it "saves as unfinished when finished is omitted" do
    book = Book.create!(title: "Beloved", author: "Toni Morrison")

    expect(book.reload.finished).to be(false)
  end
end

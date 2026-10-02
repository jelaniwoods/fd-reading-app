require "rails_helper"

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
end

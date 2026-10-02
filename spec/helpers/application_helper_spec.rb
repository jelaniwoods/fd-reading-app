require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  subject(:document) { Nokogiri::HTML.fragment(helper.render(inline: "<title><%= full_page_title %></title>")) }

  [false, true].each do |native_request|
    context "with a #{native_request ? "native" : "browser"} request" do
      before { allow(helper).to receive(:hotwire_native_app?).and_return(native_request) }

      it "uses the application name when the page has no title" do
        expect(document.at_css("title").text).to eq(I18n.t("app_name"))
      end

      it "uses the application name when the page title is blank" do
        helper.content_for :title, " "

        expect(document.at_css("title").text).to eq(I18n.t("app_name"))
      end

      it "escapes page text exactly once without inserting markup" do
        page_title = %(Joe's "R&D" </title><script id="title-payload">alert(1)</script>)
        helper.content_for :title, page_title
        expected_title = native_request ? page_title : "#{page_title} · #{I18n.t("app_name")}"

        expect(document.css("title").map(&:text)).to eq([expected_title])
        expect(document.css("script#title-payload")).to be_empty
      end
    end
  end
end

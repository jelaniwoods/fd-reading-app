require "rails_helper"

RSpec.describe "errors/forbidden", type: :view do
  it "explains denied access and offers a way home" do
    render

    expect(rendered).to have_css("h1", text: I18n.t("errors.forbidden.heading"))
    expect(rendered).to have_text(I18n.t("errors.forbidden.body"))
    expect(rendered).to have_link(I18n.t("errors.back_home"), href: root_path)
  end
end

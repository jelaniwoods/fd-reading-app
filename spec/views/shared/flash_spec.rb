require "rails_helper"

RSpec.describe "shared/_flash", type: :view do
  it "renders guidance and alerts while omitting blank messages" do
    controller.flash[:notice] = "Check your email to continue"
    controller.flash[:alert] = "The request needs attention"
    controller.flash[:warning] = ""

    render partial: "shared/flash"

    expect(rendered).to have_css("#flash_notices[role='status'][aria-atomic='true']", text: controller.flash[:notice])
    expect(rendered).to have_css("#flash_alerts[role='alert'][aria-atomic='true']", text: controller.flash[:alert])
    expect(rendered).to have_css("[data-flash-message]", count: 2)
  end
end

require "rails_helper"

RSpec.describe "Baseline pages", type: :system do
  let(:baseline_pages) { ["/", "/privacy", "/terms", "/404", "/422", "/500"] }

  mode = Rails.application.config.x.ui_theme
  palettes = %w[light dark].include?(mode) ? [mode] : %w[light dark]

  palettes.each do |theme|
    it "keeps baseline pages accessible in #{theme} mode" do
      original_theme = Rails.application.config.x.ui_theme
      Rails.application.config.x.ui_theme = theme

      baseline_pages.each do |path|
        visit path
        expect(page).to have_selector("html[data-theme=#{theme}]", visible: :all)
      end
    ensure
      Rails.application.config.x.ui_theme = original_theme
    end
  end

  it "provides persistent live regions before messages arrive" do
    visit "/"

    expect(page).to have_selector("#flash_notices[role='status']", visible: :all)
    expect(page).to have_selector("#flash_alerts[role='alert']", visible: :all)
  end

  it "lets keyboard users skip navigation and focus the main content" do
    visit "/privacy"

    page.send_keys :tab
    expect(page).to have_selector("a:focus", text: I18n.t("nav.skip_to_content"))
    page.send_keys :enter

    expect(page).to have_selector("main:focus")
  end
end

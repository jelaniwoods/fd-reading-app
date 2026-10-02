require "rails_helper"

RSpec.describe "Web app manifest", type: :request do
  it "serves the application's bookmark metadata" do
    get pwa_manifest_path(format: :json)

    expect(response).to have_http_status(:ok)
    manifest = JSON.parse(response.body)
    expect(manifest.fetch("name")).to eq(I18n.t("app_name"))
    expect(manifest.fetch("display")).to eq("standalone")
    expect(manifest.fetch("icons").map { |icon| icon.fetch("sizes") }).to include("192x192", "512x512")
  end

  it "serves every icon advertised by the manifest" do
    get pwa_manifest_path(format: :json)
    icons = JSON.parse(response.body).fetch("icons")
    expect(icons).not_to be_empty

    icons.each do |icon|
      get icon.fetch("src")

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(icon.fetch("type"))
      if icon.fetch("type") == "image/png"
        expect(response.body).to start_with("\x89PNG\r\n\x1a\n".b)
        expect(response.body[16, 8].unpack("N2")).to eq(icon.fetch("sizes").split("x").map(&:to_i))
      end
    end
  end
end

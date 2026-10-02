require "rails_helper"

RSpec.describe "Error pages", type: :request do
  it "returns an HTML error for an unprocessable request" do
    get "/422"

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.media_type).to eq("text/html")
  end

  it "returns an HTML error for an internal failure" do
    get "/500"

    expect(response).to have_http_status(:internal_server_error)
    expect(response.media_type).to eq("text/html")
  end

  it "returns a JSON error to an API caller" do
    post "/422", as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to eq("error" => I18n.t("errors.unprocessable.heading"))
  end

  it "returns a JSON error for JSON input without an Accept header" do
    post "/422",
      params: JSON.generate(device: {token: "expired"}),
      headers: {"CONTENT_TYPE" => "application/json"}

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.media_type).to eq("application/json")
    expect(response.parsed_body).to eq("error" => I18n.t("errors.unprocessable.heading"))
  end

  context "with production exception rendering" do
    around do |example|
      env_config = Rails.application.env_config
      previous_show_exceptions = env_config["action_dispatch.show_exceptions"]
      previous_show_detailed_exceptions = env_config["action_dispatch.show_detailed_exceptions"]
      env_config["action_dispatch.show_exceptions"] = :all
      env_config["action_dispatch.show_detailed_exceptions"] = false
      example.run
    ensure
      env_config["action_dispatch.show_exceptions"] = previous_show_exceptions
      env_config["action_dispatch.show_detailed_exceptions"] = previous_show_detailed_exceptions
    end

    it "returns an HTML 404 for an unknown route" do
      get "/definitely-not-a-real-page"

      expect(response).to have_http_status(:not_found)
      expect(response.media_type).to eq("text/html")
    end

    it "returns an HTML 500 for an application exception" do
      with_routing do |routes|
        routes.draw do
          get "/boom", to: ->(_env) { raise "deliberate test exception" }
          match "/500", to: "errors#internal_error", via: :all
          get "/manifest", to: "rails/pwa#manifest", as: :pwa_manifest
          root "home#index"
        end

        get "/boom"

        expect(response).to have_http_status(:internal_server_error)
        expect(response.media_type).to eq("text/html")
      end
    end
  end

  it "returns a not-found response during ordinary request specs" do
    get "/definitely-not-a-real-page"

    expect(response).to have_http_status(:not_found)
  end

  it "raises unmapped exceptions during ordinary request specs" do
    with_routing do |routes|
      routes.draw { get "/broken", to: ->(_env) { nil.upcase } }

      expect { get "/broken" }.to raise_error(NoMethodError, /upcase/)
    end
  end
end

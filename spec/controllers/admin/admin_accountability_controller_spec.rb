# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe AdminAccountabilityController, type: :controller do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:organization) { create(:organization) }
      let(:admin_accountability) { true }

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user

        allow(Decidim::DecidimAwesome.config).to receive(:admin_accountability).and_return(admin_accountability)
      end

      describe "GET #index" do
        context "when admin accountability is enabled" do
          it "returns http success" do
            get :index, params: {}
            expect(response).to have_http_status(:success)
          end
        end

        context "when admin accountability is disabled" do
          let!(:admin_accountability) { :disabled }

          it "returns http success" do
            get :index, params: {}
            expect(response).to have_http_status(:found)
          end
        end
      end
    end
  end
end

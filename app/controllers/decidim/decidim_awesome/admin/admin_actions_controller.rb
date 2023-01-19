# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AdminActionsController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include Decidim::Admin::Filterable

        layout "decidim/admin/users"
        before_action do
          enforce_permission_to :edit_config, :allow_admin_accountability
        end

        def index
          @admin_actions = PaperTrail::Version.where(item_type: "Decidim::ParticipatoryProcessUserRole", event: "create")
                                              .page(params[:page]).per(params[:per_page])
        end

        def export_xls
          # TODO: export to xls
        end
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

describe "Filter Admin actions", type: :system do
  let(:user_creation_date) { 7.days.ago }
  let(:login_date) { 6.days.ago }
  let(:organization) { create :organization }
  let!(:admin) { create :user, :admin, :confirmed, organization: organization }
  let!(:resource_controller) { Decidim::DecidimAwesome::Admin::AdminAccountabilityController }
  let(:administrator) { create(:user, organization: organization, last_sign_in_at: login_date, created_at: user_creation_date) }
  let(:valuator) { create(:user, name: "Lorry", email: "test@example.org", organization: organization, created_at: user_creation_date) }
  let(:collaborator) { create(:user, organization: organization, created_at: user_creation_date) }
  let(:moderator) { create(:user, organization: organization, created_at: user_creation_date) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }

  let(:status) { true }

  include_context "with filterable context"

  before do
    allow(Decidim::DecidimAwesome.config).to receive(:allow_admin_accountability).and_return(status)
    switch_to_host(organization.host)
    login_as admin, scope: :user

    visit decidim_admin.root_path
  end

  describe "admin action list" do
    context "when there are admin actions" do
      before do
        create(:participatory_process_user_role, user: administrator, role: "admin", created_at: 4.days.ago)
        create(:participatory_process_user_role, user: valuator, role: "valuator", created_at: 3.days.ago)
        create(:participatory_process_user_role, user: collaborator, role: "collaborator", created_at: 2.days.ago)
        create(:participatory_process_user_role, user: moderator, role: "moderator", created_at: 1.day.ago)
        create(:assembly_user_role, user: administrator, role: "admin", created_at: 4.days.ago)
        create(:assembly_user_role, user: valuator, role: "valuator", created_at: 3.days.ago)
        create(:assembly_user_role, user: collaborator, role: "collaborator", created_at: 2.days.ago)
        create(:assembly_user_role, user: moderator, role: "moderator", created_at: 1.day.ago)

        click_link "Participants"
        click_link "Admin accountability"
      end

      it "shows filters", versioning: true do
        expect(page).to have_content("Filter")
        expect(page).to have_css("#q_user_name_or_user_email_cont")
        expect(page).to have_css("#q_start_gteq")
        expect(page).to have_css("#q_end_lteq")
      end

      it "displays the filter labels", versioning: true do
        find("a.dropdown").hover
        expect(page).to have_content("Participatory space type")
        expect(page).to have_content("Role type")

        find("a", text: "Participatory space type").hover
        expect(page).to have_content("Process")
        expect(page).to have_content("Assembly")

        find("a", text: "Role type").hover
        expect(page).to have_content("admin")
        expect(page).to have_content("collaborator")
        expect(page).to have_content("moderator")
        expect(page).to have_content("valuator")
      end

      context "when filtering admin_actions by PARTICIPATORY SPACE" do
        it "Assemblies space type", versioning: true do
          apply_filter("Participatory space type", "Assembly")

          within "tbody" do
            expect(page).to have_content("Assemblies >", count: 4)
          end
        end

        it "Processes space type", versioning: true do
          apply_filter("Participatory space type", "Process")

          within "tbody" do
            expect(page).to have_content("Processes >", count: 4)
          end
        end
      end

      context "when filtering admin_actions by ROLE TYPE" do
        it "Admin role type", versioning: true do
          apply_filter("Role type", "admin")

          within "tbody" do
            expect(page).to have_content("Administrator", count: 2)
          end
        end

        it "Collaborator role type", versioning: true do
          apply_filter("Role type", "collaborator")

          within "tbody" do
            expect(page).to have_content("Collaborator", count: 2)
          end
        end

        it "Moderator role type", versioning: true do
          apply_filter("Role type", "moderator")

          within "tbody" do
            expect(page).to have_content("Moderator", count: 2)
          end
        end

        it "Valuator role type", versioning: true do
          apply_filter("Role type", "valuator")

          within "tbody" do
            expect(page).to have_content("Valuator", count: 2)
          end
        end
      end

      context "when searching by name or email" do
        it "searches by name", versioning: true do
          search_by_text("Lorry")

          within "tbody" do
            expect(page).to have_content("Lorry", count: 2)
          end
        end

        it "searches by email", versioning: true do
          search_by_text("test@example.org")

          within "tbody" do
            expect(page).to have_content("test@example.org", count: 2)
          end
        end
      end

      context "when searching by date" do
        DATE_FORMAT = "%d/%m/%Y"

        def search_by_date(start_date, end_date)
          within(".filters__section") do
            fill_in("q_created_at_gteq", with: start_date.strftime(DATE_FORMAT)) if start_date.present?
            fill_in("q_created_at_lteq", with: end_date.strftime(DATE_FORMAT)) if end_date.present?
            find("*[type=submit]").click
          end
        end

        context "when the start date is earlier" do
          it "displays all entries", versioning: true do
            search_by_date(6.days.ago, "")

            within "tbody" do
              expect(page).to have_css("tr", count: 8)
            end
          end
        end

        context "when the start date is later" do
          it "displays no entries", versioning: true do
            search_by_date(1.hour.ago, "")

            within "tbody" do
              expect(page).to have_css("tr", count: 0)
            end
          end
        end

        context "when the end date is later" do
          it "displays all entries", versioning: true do
            search_by_date("", 5.days.from_now)

            within "tbody" do
              expect(page).to have_css("tr", count: 8)
            end
          end
        end

        context "when the end date is earlier" do
          it "displays no entries", versioning: true do
            search_by_date("", 6.days.ago)

            within "tbody" do
              expect(page).to have_css("tr", count: 0)
            end
          end
        end

        context "when searching in range" do
          it "displays entries in range" do
            search_by_date(3.days.ago, 2.days.ago)

            within "tbody" do
              expect(page).to have_css("tr", count: 2)
            end
          end
        end
      end
    end
  end
end

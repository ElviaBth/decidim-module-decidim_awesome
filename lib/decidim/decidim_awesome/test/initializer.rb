# frozen_string_literal: true

Decidim::DecidimAwesome.configure do |config|
  if ENV.fetch("FEATURES", nil) == "disabled"
    [
      :allow_images_in_full_editor,
      :allow_images_in_small_editor,
      :allow_images_in_proposals,
      :use_markdown_editor,
      :allow_images_in_markdown_editor,
      :auto_save_forms,
      :intergram_for_admins,
      :intergram_for_public,
      :scoped_styles,
      :proposal_custom_fields,
      :menu,
      :scoped_admins,
      :custom_redirects,
      :validate_title_min_length,
      :validate_title_max_caps_percent,
      :validate_title_max_marks_together,
      :validate_title_start_with_caps,
      :validate_body_min_length,
      :validate_body_max_caps_percent,
      :validate_body_max_marks_together,
      :validate_body_start_with_caps
    ].each do |conf|
      config.send("#{conf}=", :disabled)
    end

    config.disabled_components = [:awesome_map, :awesome_iframe]
  end
end

# frozen_string_literal: true

# Tune Proposal presenter to use markdown if configured
Decidim::Proposals::ProposalPresenter.class_eval do
  def body(links: false, extras: true, strip_tags: false)
    if respond_to? :translated_attribute
      text = translated_attribute(proposal.body)

      text = strip_tags(sanitize_text(text)) if strip_tags
    else
      # TODO: remove when 0.22 is diched
      text = proposal.body
      text = strip_tags(text) if strip_tags
    end

    renderer = Decidim::ContentRenderers::HashtagRenderer.new(text)
    text = renderer.render(links: links, extras: extras).html_safe

    if use_markdown? proposal
      text = Decidim::DecidimAwesome::ContentRenderers::MarkdownRenderer.new(text).render
      # HACK: to avoid the replacement of lines to <br> that simple_format does
      text = text.gsub(">\n", ">").gsub("\n<", "<")
    elsif links
      text = Decidim::ContentRenderers::LinkRenderer.new(text).render
    end
    text
  end

  private

  def use_markdown?(proposal)
    return false unless proposal.respond_to? :organization

    config = Decidim::DecidimAwesome::Config.new(proposal.organization)
    config.context_from_component proposal
    config.enabled_for? :use_markdown_editor
  end
end
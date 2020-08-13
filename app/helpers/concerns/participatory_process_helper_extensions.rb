# frozen_string_literal: true

# Extensions for the Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper
module ParticipatoryProcessHelperExtensions
  extend ActiveSupport::Concern

  def process_step_tag(step, past = false)
    cls = ["phases-list-item"]
    cls << "phases-list-item-past" if past

    if respond_to?(:current_component) && step.cta_path.present?
      cls << "phases-list-item-active" if step.cta_path =~ %r{^f/#{current_component.id}[^0-9]*}
    elsif !respond_to?(:current_participatory_space)
      # When displayed outside of a participatory space, the active state is
      # shown for the active step instead of the active page.
      cls << "phases-list-item-active" if step.active?
    end

    content_tag :li, class: cls.join(" ") do
      yield
    end
  end

  def process_step_link(step)
    if step.cta_path.present?
      step_url = begin
        base_url, params = decidim_participatory_processes.participatory_process_path(
          step.participatory_process
        ).split("?")

        if params.present?
          [base_url, "/", step.cta_path, "?", params].join("")
        else
          [base_url, "/", step.cta_path].join("")
        end
      end

      link_to step_url do
        yield
      end
    else
      capture do
        yield
      end
    end
  end

  def step_date_info(step)
    cta_text = translated_attribute(step.cta_text)
    return cta_text if cta_text.present?

    step_dates(step)
  end
end

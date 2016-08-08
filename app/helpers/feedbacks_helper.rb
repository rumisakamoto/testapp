# -*- encoding : utf-8 -*-
module FeedbacksHelper

  # generates feedback type label
  # ==== Args
  # _feedback_ :: target feedback
  # ==== Return
  # html of feedback type label
  def feedback_type(feedback)
    html = ""
    case feedback.feedback_type
    when Feedback::FeedbackTypes::NORMAL
      html << <<-HTML
      <span class="label label-info">#{Feedback::FeedbackTypes.to_hash[Feedback::FeedbackTypes::NORMAL]}</span>
      HTML
    when Feedback::FeedbackTypes::SUPPLEMENT
      html << <<-HTML
      <span class="label label-success">#{Feedback::FeedbackTypes.to_hash[Feedback::FeedbackTypes::SUPPLEMENT]}</span>
      HTML
    when Feedback::FeedbackTypes::CORRECTION
      html << <<-HTML
      <span class="label label-warning">#{Feedback::FeedbackTypes.to_hash[Feedback::FeedbackTypes::CORRECTION]}</span>
      HTML
    else
      html << <<-HTML
      <span class="label label-info">#{Feedback::FeedbackTypes.to_hash[Feedback::FeedbackTypes::NORMAL]}</span>
      HTML
    end
    html << <<-HTML
    <hr/>
    HTML
    html.html_safe
  end

  # generates cancel button to return article#show from feedback#edit
  # ==== Args
  # _feedback_ :: target feedback
  # ==== Return
  # html of button
  def cancel_button(feedback)
    return "" unless feedback
    caption = "<i class=\"icon-arrow-left\"></i> #{t('.cancel')}"
    button = link_to article_path(feedback.article_id), class: "btn" do
      raw caption
    end
    button
  end

  # generates feedback recommend button
  # ==== Args
  # _feedback_ :: target feedback
  # ==== Return
  # html of button to either commit or cancel recommendation
  def recommend_feedback_button(feedback)
    caption = "<i class=\"icon-thumbs-up\"> </i> #{feedback.feedback_recommendations_count}"
    if cannot?(:recommend, feedback)
      button = <<-HTML
        <a class="btn btn-primary disabled">#{raw caption}</a>
      HTML
    elsif feedback.recommended?(current_user.id)
      caption = "<i class=\"icon-thumbs-down\"> </i> #{feedback.feedback_recommendations_count}"
      button = link_to recommend_feedback_path(feedback_id: feedback.id, cancel: true), class: "btn btn-inverse cancel_recommend_feedback_btn", id: "feedback_#{feedback.id}", remote: true, method: :post do
        raw caption
      end
    else
      button = link_to recommend_feedback_path(feedback_id: feedback.id), class: "btn recommend_feedback_btn", id: "feedback_#{feedback.id}", remote: true, method: :post do
        raw caption
      end
    end
    raw button
  end

  # generates edit feedback button
  # ==== Args
  # _article_ :: target article
  # _feedback_ :: target feedback
  # ==== Return
  # html of button
  def edit_feedback_button(article, feedback)
    return "" if cannot?(:edit, feedback)
    html = <<-HTML
      <a class="btn" href="#{edit_article_feedback_path(article.id, feedback.id)}"><i class="icon-pencil"></i></a>
    HTML
    html.html_safe
  end

  # generates remove feedback button
  # ==== Args
  # _article_ :: target article
  # _feedback_ :: target feedback
  # ==== Return
  # html of button
  def remove_feedback_button(article, feedback)
    return "" if cannot?(:destroy, feedback)
    html = <<-HTML
      <a class="btn" href="#{article_feedback_path(article, feedback)}" data-confirm="Are you sure?" data-method="delete"><i class="icon-trash"></i></a>
    HTML
    html.html_safe
  end
end

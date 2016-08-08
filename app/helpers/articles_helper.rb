# -*- encoding : utf-8 -*-
module ArticlesHelper

  # generates inline-labels to display feedback count by each feedback type
  # ==== Args
  # _article_ :: target article
  # ==== Return
  # html of inline-labels
  def feedbacks_summary(article)
    feedbacks_counts = article.count_feedbacks_by_type
    html = <<-HTML
    <span align="right">
      <span class="label label-info">#{Feedback::FeedbackTypes.to_hash[Feedback::FeedbackTypes::NORMAL]}(#{feedbacks_counts[Feedback::FeedbackTypes::NORMAL]})</span> -
      <span class="label label-success">#{Feedback::FeedbackTypes.to_hash[Feedback::FeedbackTypes::SUPPLEMENT]}(#{feedbacks_counts[Feedback::FeedbackTypes::SUPPLEMENT]})</span> -
      <span class="label label-warning">#{Feedback::FeedbackTypes.to_hash[Feedback::FeedbackTypes::CORRECTION]}(#{feedbacks_counts[Feedback::FeedbackTypes::CORRECTION]})</span>
    </span>
    HTML
    html.html_safe
  end

  # generates title including search word for search result screen
  # ==== Args
  # _article_ :: search word
  # ==== Return
  # html of search result screen title
  def search_result_title(search_word)
    html = <<-HTML
    <div class="page-header">
      <h2><span class="alert alert-info">#{search_word}</span> #{t('.search_result')}</h2>
    </div>
    HTML
    html.html_safe
  end

  # generates button to move article#show for target article
  # ==== Args
  # _article_ :: target article
  # ==== Return
  # html of button
  def back_to_article_button(article)
    caption = "<i class='icon-arrow-left'></i> #{t('cancel')}"
    button = link_to article_path(article), class: "btn" do
      raw caption
    end
    button
  end

  # generates button to move article index
  # ==== Return
  # html of button
  def back_to_article_index_button
    caption = <<-HTML
    <i class='icon-arrow-left'></i> #{t('cancel')}
    HTML
    button = link_to articles_path, class: "btn" do
      raw caption
    end
    button
  end

  # generates header of article
  # ==== Args
  # _article_ :: target article
  # ==== Return
  # html of page header to show article title
  def article_title(article)
    require_linked_title = action_name == 'index' ||
                       action_name == 'show_more' ||
                          action_name == 'search' ||
                 action_name == 'articles_by_tag' ||
                 action_name == 'articles_by_user'
    link = link_to_if require_linked_title, article.title, article
    html = <<-HTML
    <div class="page-header articletitle">
      #{raw link}
    </div>
    HTML
    html.html_safe
  end

  # generates page header used in articles_by_tag
  # ==== Return
  # html of page header to show user nickname and icon
  def page_header_user
    return "" if @user.blank? || @user.nickname.blank?
    icon = <<-HTML
    <i class="icon-user"></i>
    HTML
    unless @user.icon_url.blank?
      icon = <<-HTML
      <img src="#{@user.icon_url}">
      HTML
    end
    html = <<-HTML
    <div class="page-header">
      <h2><a href="#{user_path(@user.id)}">#{icon} #{@user.nickname}</a><small>  - #{t("#{controller_name}.#{action_name}.title")}</small></h2>
    </div>
    HTML
    html.html_safe
  end

  # generates page header used in articles_by_tag
  # ==== Return
  # html of page header to show tag name and icon
  def page_header_tag
    return "" if @tag.blank? || @tag.name.blank?
    icon = <<-HTML
    <i class="icon-tag"></i>
    HTML
    unless @tag.icon_url.blank?
      icon = <<-HTML
      <img src="#{@tag.icon_url}">
      HTML
    end
    html = <<-HTML
    <div class="page-header">
      <h2>#{icon} #{@tag.name}</h2>
    </div>
    HTML
    html.html_safe
  end

  # generates tag labels related with article
  # ==== Args
  # _article_ :: target article
  # ==== Return
  # html of division including tag labels
  def related_tags(article)
    return "" if article.tags.blank?
    html = <<-HTML
      <div class="related_tag_div">
    HTML
    article.tags.each do |tag|
      icon = <<-HTML
        <i class="icon-tag icon-white"></i>
      HTML
      # unless tag.icon_url.blank?
        # icon = <<-HTML
        # <img src="#{tag.icon_url}" height="20" width="20">
        # HTML
      # end
      html << <<-HTML
      <a href="#{articles_by_tag_path(tag.id)}"><span class="label label-tag">#{icon} #{tag.name}</span></a>&nbsp;&nbsp;&nbsp;
      HTML
    end
    html << <<-HTML
      </div>
    HTML
    html.html_safe
  end

  def publicity_tag(article)
      return "" if article.publicity_level.blank?
      html = <<-HTML
      <div class="publicity">
      HTML
      case article.publicity_level
      when Accessibility::ANONYMOUS
          html << <<-HTML
          <span class="label label-inverse">#{I18n.t('accessibility.anonymous')}</span>
          HTML
      when Accessibility::MEMBER
          html << <<-HTML
          <span class="label label-inverse">#{I18n.t('accessibility.member')}</span>
          HTML
      when Accessibility::LEADER
          html << <<-HTML
          <span class="label label-inverse">#{I18n.t('accessibility.leader')}</span>
          HTML
      when Accessibility::MANAGER
          html << <<-HTML
          <span class="label label-inverse">#{I18n.t('accessibility.manager')}</span>
          HTML
      when Accessibility::ADMIN
          html << <<-HTML
          <span class="label label-inverse">#{I18n.t('accessibility.admin')}</span>
          HTML
      when Accessibility::PRIVATE
          html << <<-HTML
          <span class="label label-important">#{I18n.t('accessibility.private')}</span>
          HTML
      end
      html << <<-HTML
      </div>
      HTML
      html.html_safe
  end

  # generates checkboxes to select tags
  # ==== Args
  # _article_ :: target article
  # _tags_ :: all tags
  # ==== Return
  # html of checkboxes
  # if there are tags already selected, they are checked
  def comment_button(article)
    html = ""
    return html if action_name == 'show'# || can? :create, Feedback
    html = <<-HTML
      <a class="btn btn-primary disabled"><i class="icon-comment"></i> #{article.feedbacks_count}</a>
    HTML
    html.html_safe
  end
  def comment_label(article)
    html = <<-HTML
      <span class="label label-info"><i class="icon-comment"></i> #{article.feedbacks_count}</span>
    HTML
    html.html_safe
  end

  # generates checkboxes to select tags
  # ==== Args
  # _article_ :: target article
  # _tags_ :: all tags
  # ==== Return
  # html of checkboxes
  # if there are tags already selected, they are checked
  def tag_checkbox(article, tags)
    html = ""
    return html if tags == nil || tags.empty?
    tags.each do |tag|
      checked = ""
      if tag.selected?(article)
        checked = " checked"
      end
      html << <<-HTML
        <label for="tag_#{tag.id}" class="checkbox inline tagcheck">
          <input type="checkbox" id="tag_#{tag.id}" value="#{tag.name}" class="tagCheck"#{checked}>#{tag.name}</input>
        </label>
      HTML
    end
    html.html_safe
  end

  # gets selected tag names
  # ==== Args
  # _article_ :: target article
  # _tags_ :: all tags
  # ==== Return
  # selected tag names: [tag1][tag2][tag3]...
  def selected_tags(article, tags)
    selected_tag_name = ""
    return selected_tag_name if tags == nil || tags.empty?
    tags.each do |tag|
      if tag.selected?(article)
        selected_tag_name << "[#{tag.name}]"
      end
    end
    selected_tag_name
  end

  # article recommend button
  # ==== Args
  # _article_ :: target article
  # ==== Return
  # button html (commit button or cancel button)
  # if current user has no permission to recommend article, button will be disabled
  def recommend_button(article)
    caption = "<i class=\"icon-thumbs-up\"> </i> #{article.article_recommendations_count}"
    if cannot?(:recommend, article)
      button = <<-HTML
        <a class="btn btn-primary disabled">#{raw caption}</a>
      HTML
    elsif article.recommended?(current_user.id)
      caption = "<i class=\"icon-thumbs-down\"> </i> #{article.article_recommendations_count}"
      button = link_to recommend_article_path(article_id: article.id, cancel: true), class: "btn btn-inverse cancel_recommend_btn", id: "article_#{article.id}", remote: true, method: :post do
        raw caption
      end
    else
      button = link_to recommend_article_path(article_id: article.id), class: "btn recommend_btn", id: "article_#{article.id}", remote: true, method: :post do
        raw caption
      end
    end
    raw button
  end

  # article favorite button
  # ==== Args
  # _article_ :: target article
  # ==== Return
  # button html (commit button or cancel button)
  # if current user has no permission to favor article, button will be disabled
  def favorite_button(article)
    caption = "<i class=\"icon-bookmark\"></i> #{article.favorites_count}"
    if cannot?(:favor, article)
      button = <<-HTML
        <a class="btn btn-primary disabled">#{raw caption}</a>
      HTML
    elsif article.favored?(current_user.id)
      button = link_to favor_article_path(article_id: article.id, cancel: true), class: "btn btn-inverse cancel_favorite_btn", id: "favoritearticle_#{article.id}", remote: true, method: :post do
        raw caption
      end
    else
      button = link_to favor_article_path(article_id: article.id), class: "btn favorite_btn", id: "favoritearticle_#{article.id}", remote: true, method: :post do
        raw caption
      end
    end
    raw button
  end

  # article edit button
  # ==== Args
  # _article_ :: target article
  # ==== Return
  # button html
  # if current user has no permission to remove article, button won't be displayed
  def edit_button(article)
    return "" if cannot?(:edit, article)
    html = <<-HTML
      <a class="btn" href="#{edit_article_path(article)}"><i class="icon-pencil"></i></a>
    HTML
    html.html_safe
  end

  # article remove button
  # ==== Args
  # _article_ :: remove target article
  # ==== Return
  # remove button html
  # if current user has no permission to remove article, button won't be displayed
  def remove_button(article)
    return "" if cannot?(:destroy, article)
    html = <<-HTML
      <a class="btn" href="#{article_path(article)}" data-confirm="#{t('confirmation')}" data-method="delete"><i class="icon-trash"></i></a>
    HTML
    html.html_safe
  end
end

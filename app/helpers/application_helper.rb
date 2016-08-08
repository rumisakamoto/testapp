# -*- encoding : utf-8 -*-
module ApplicationHelper

  # generates a user who creates many articles ranking item
  # ==== Args
  # _user_ :: User model to display in ranking list
  # ==== Return
  # html of a ranking item
  def article_user_ranking_item(user)
    return "" if user.blank?
    icon = user_icon_image_tag(user, size: Settings.icon_size.very_small)
    html = <<-HTML
    <li><a href="#{user_path(user.id)}">#{icon} #{user.nickname} (#{user.articles_count})</a></li>
    HTML
    html.html_safe
  end

  # generates a user who creates many feedbacks ranking item
  # ==== Args
  # _user_ :: User model to display in ranking list
  # ==== Return
  # html of a ranking item
  def feedback_user_ranking_item(user)
    return "" if user.blank?
    icon = user_icon_image_tag(user, size: Settings.icon_size.very_small)
    html = <<-HTML
    <li><a href="#{user_path(user.id)}">#{icon} #{user.nickname} (#{user.feedbacks_count})</a></li>
    HTML
    html.html_safe
  end

  # generates a favorite article ranking item
  # ==== Args
  # _article_ :: Article model to display in ranking list
  # ==== Return
  # html of a ranking item
  def favorite_article_ranking_item(article)
    return "" if article.blank?
    icon = <<-HTML
      <i class="icon-bookmark"></i>
    HTML
    html = <<-HTML
    <li><a href="#{article_path(article.id)}">#{icon} #{article.title} (#{article.favorites_count})</a></li>
    HTML
    html.html_safe
  end

  # generates a recommended article ranking item
  # ==== Args
  # _article_ :: Article model to display in ranking list
  # ==== Return
  # html of a ranking item
  def recommended_article_ranking_item(article)
    return "" if article.blank?
    icon = <<-HTML
      <i class="icon-thumbs-up"></i>
    HTML
    html = <<-HTML
    <li><a href="#{article_path(article.id)}">#{icon} #{article.title} (#{article.article_recommendations_count})</a></li>
    HTML
    html.html_safe
  end

  # generates a tag ranking item
  # ==== Args
  # _tag_ :: Tag model to display in ranking list
  # ==== Return
  # html of a ranking item
  def tag_ranking_item(tag)
    return "" if tag.blank?
    icon = <<-HTML
      <i class="icon-tag"></i>
    HTML
    unless tag.icon_url.blank?
      width, height = Settings.icon_size.very_small.split("x")
      icon = <<-HTML
      <img src="#{tag.icon_url}" height="#{height}" width="#{width}"/>
      HTML
    end
    html = <<-HTML
    <li><a href="#{articles_by_tag_path(tag.id)}">#{icon} #{tag.name} (#{tag.article_tag_rels_count})</a></li>
    HTML
    html.html_safe
  end

  # generates 'more' link to show rest of ranking list
  # if you need to add a new ranking, add a 'when' sentence to generate a 'more' link in this method.
  # ==== Args
  # _model_list_ :: sorted models to display as ranking
  # _ranking_type_ :: string specifying ranking type written in Toppage
  # ==== Return
  # html of 'more' link
  def more_ranking_link(model_list, ranking_type)
    return "" if model_list.blank? || model_list.next_page.blank? || ranking_type.blank?
    more_ranking_link_id = "#{Toppage::Ranking::MoreLink::ID_PREFIX}#{ranking_type}#{Toppage::Ranking::MoreLink::ID_SUFFIX}"
    link = ""
    param_name = "#{ranking_type}#{Toppage::Ranking::MoreLink::PAGE_PARAM_SUFFIX}".to_sym
    case ranking_type
    when Toppage::Ranking::Type::TAGS
      link = link_to t("more"), more_tags_ranking_path(param_name => model_list.next_page), id: more_ranking_link_id, remote: true
    when Toppage::Ranking::Type::RECOMMENDED_ARTICLES
      link = link_to t("more"), more_recommended_articles_ranking_path(param_name => model_list.next_page), id: more_ranking_link_id, remote: true
    when Toppage::Ranking::Type::FAVORITE_ARTICLES
      link = link_to t("more"), more_favorite_articles_ranking_path(param_name => model_list.next_page), id: more_ranking_link_id, remote: true
    when Toppage::Ranking::Type::ARTICLE_USERS
      link = link_to t("more"), more_article_users_ranking_path(param_name => model_list.next_page), id: more_ranking_link_id, remote: true
    when Toppage::Ranking::Type::FEEDBACK_USERS
      link = link_to t("more"), more_feedback_users_ranking_path(param_name => model_list.next_page), id: more_ranking_link_id, remote: true
    end
    raw link
  end

  # generates a ranking item
  # if you need to add a new ranking, implement an appropriate ranking item generation method
  # and add a 'when' sentence to generate a ranking item calling it to this method.
  # ==== Args
  # _model_ :: a model to display as a ranking item
  # _ranking_type_ :: string specifying ranking type written in Toppage
  # ==== Return
  # html of a ranking item to display right side layout
  def ranking_item(model, ranking_type)
    return "" if model.blank? || ranking_type.blank?
    item = ""
    case ranking_type
    when Toppage::Ranking::Type::TAGS
      item = tag_ranking_item(model) if model.instance_of? Tag
    when Toppage::Ranking::Type::RECOMMENDED_ARTICLES
      item = recommended_article_ranking_item(model) if model.instance_of? Article
    when Toppage::Ranking::Type::FAVORITE_ARTICLES
      item = favorite_article_ranking_item(model) if model.instance_of? Article
    when Toppage::Ranking::Type::ARTICLE_USERS
      item = article_user_ranking_item(model) if model.instance_of? User
    when Toppage::Ranking::Type::FEEDBACK_USERS
      item = feedback_user_ranking_item(model) if model.instance_of? User
    end
    raw item
  end

  # generates ranking list of specified models with rankig type
  # ==== Args
  # _model_list_ :: sorted models to display as ranking
  # _ranking_type_ :: string specifying ranking type written in Toppage
  # ==== Return
  # html of ranking to display right side layout
  def ranking_list(model_list, ranking_type)
    return "" if model_list.blank? || ranking_type.blank?
    ranking_item_list = ""
    model_list.each do |model|
      ranking_item_list << ranking_item(model, ranking_type)
    end
    ranking_item_list.html_safe
  end

  # generates title of layout side menu
  # ==== Args
  # _resource_key_ :: resource key of locale file
  # ==== Return
  # html of side menu title
  def side_menu_title(resource_key)
    return "" if resource_key.blank?
    html = <<-HTML
    <h3>#{t(resource_key)}</h3>
    HTML
    html.html_safe
  end

  # generates elapsed time to display
  # ==== Args
  # _time_ :: start date
  # ==== Return
  # elapsed time with 'ago'
  def since_updated(time)
    return "" if time.blank?
    time_ago = time_ago_in_words(time) << t('time_ago')
    time_ago
  end

  # generates page header div
  # ==== Return
  # html of page header div (header text will be resource which has key controller_name.action_name.title in locale file)
  def page_title
    title = t("#{controller_name}.#{action_name}.title")
    html = <<-HTML
    <div class="page-header">
      <h1>#{title}</h1>
    </div>
    HTML
    html.html_safe
  end

  # generates user icon and nickname for page header
  # How to indicate size "32x32"
  # ==== Args
  # _size_ :: icon image size
  # _user_ :: target user
  # ==== Return
  # html of user icon and nickname (it will be link to user's page if user is valid
  def user_icon(size, user)
    iconname = icon_name(user)
    icon = user_icon_image_tag(iconname, size: size)
    icon << " "
    icon << nickname(user)
    return icon unless user
    link = link_to user_path(user.id) do
      icon
    end
    link
  end

  # generates user icon and nickname for page header
  # ==== Args
  # _user_ :: target user
  # ==== Return
  # html of user icon and nickname
  def user_icon_large(user)
     icon = user_icon_image_tag(icon_name(user), size: Settings.icon_size.large)
     icon << raw("<font size='#{Settings.font_size_addition.large}'> #{nickname(user)}</font>")
     raw icon
  end

  # returns icon url of specified user
  # ==== Args
  # _user_ :: target user
  # ==== Return
  # url of user's icon image if user valid, if not, it will be url of guest image
  def icon_name(user)
    iconname = (!user.blank? && !user.icon_url.blank?)? user.icon_url : Settings.icon.user.guest_image
    iconname
  end

  # returns nickname of specified user
  # ==== Args
  # _user_ :: target user
  # ==== Return
  # nickname if user is valid, if not, it will be guest name
  def nickname(user)
    nickname = (!user.blank? && !user.nickname.blank?)? user.nickname : I18n.t('guest_name')
    nickname
  end

  # returns " error" string if there is a validation error on specified attribute of model
  # in order to mark the control responding to the attribute using twitter-bootstrap
  # ==== Args
  # _model_ :: model to validate
  # _attr_name_ :: attribute name
  # ==== Return
  # " error" if the attribute has validation error, if not, it will be empty
  def mark_error(model, attr_name)
    if model.errors.any? && model.errors.get(attr_name) && model.errors.get(attr_name) != ""
      return ' error'
    end
    return ''
  end

  # generates image tag for user icon
  # ==== Args
  # _image_ :: target model instance or image path string
  # _options_ :: optional parameter hash
  # ==== Options
  # _size_ :: Supplied as "{Width}x{Height}", so "30x45" becomes width="30" and height="45". :size will be ignored if the value is not in the correct format.
  # ==== Return
  # html of img
  def user_icon_image_tag(image, options = {})
    return "" if image.blank?
    raise ArgumentError.new "invalid parameter" if !image.instance_of? String and !image.respond_to?(:icon_url)
    size = options.delete(:size) || Settings.icon_size.medium
    icon_url = Settings.icon.user.default_image_url
    if image.respond_to?(:icon_url) && !image.icon_url.blank?
      icon_url = image.icon_url
    elsif image.instance_of? String
      icon_url = image
    end
    image_tag(icon_url, size: size, alt: Settings.icon.user.alt_text)
  end

  # generates model validation error message div
  # ==== Args
  # _resource_ :: target model
  # ==== Return
  # html of error message div
  def error_messages(resource)
    return "" if resource.blank? || resource.errors.blank? #resource.errors.empty?
    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    html = <<-HTML
      <div class="alert alert-block alert-error">
        <a class="close" data-dismiss="alert">&times;</a>
        <h4 class="alert-heading">#{t('error_title')}</h4>
        <ul>#{messages}</ul>
      </div>
    HTML
    html.html_safe
  end

  # generates error message label of ajax
  # ==== Args
  # _resource_key_ :: ajax error message resource key
  # ==== Return
  # html of ajax error message label
  def ajax_error_messages(resource_key)
    return "" if resource_key.blank?
    html = <<-HTML
    <span class="label label-important">#{t(resource_key)}#{t('error_ajax')}</span>
    HTML
    html.html_safe
  end

  # generates notice message div from global notice
  # ==== Return
  # html of notice message div
  def notice_messages
    return "" if notice.blank?

    message = notice.class == Array ? notice.map { |msg| content_tag(:li, msg) }.join : "<li>#{notice.to_s}</li>"

    html = <<-HTML
      <div class="alert alert-block alert-info">
        <a class="close" data-dismiss="alert">&times;</a>
        <h4 class="alert-heading">#{t('notice_title')}</h4>
        <ul>#{message}</ul>
      </div>
    HTML
    html.html_safe
  end

  # generates alert message div
  # ==== Args
  # _*alert_message_ :: alert message array
  # ==== Return
  # html of alert message div
  def alert_messages(*alert_message)
    # delete invalid message
    alert_message.reject! { |msg| msg.blank? } unless alert_message.blank?
    alert_message = [] if alert_message.blank?
    # delete invalid system alert message
    if alert.class == Array && !alert.blank?
      system_alert = alert.reject { |msg| msg.blank? }
    elsif !alert.blank?
      system_alert = alert
    end
    # concatinate alerts
    unless system_alert.blank?
      if system_alert.class == Array
        alert_message += system_alert
      else
        alert_message << system_alert
      end
    end

    return "" if alert_message.blank?

    message = alert_message.class == Array ? alert_message.map { |msg| content_tag(:li, msg) }.join : "<li>#{alert_message.to_s}</li>"

    html = <<-HTML
      <div class="alert alert-block">
        <a class="close" data-dismiss="alert">&times;</a>
        <h4 class="alert-heading">#{t('alert_title')}</h4>
        <ul>#{message}</ul>
      </div>
    HTML
    html.html_safe
  end

end

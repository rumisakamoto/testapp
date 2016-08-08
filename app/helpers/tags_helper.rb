module TagsHelper

  # generates back button
  # ==== Return
  # html of back button
  def back_button
    caption = <<-HTML
    <i class="icon-arrow-left"></i> #{t('cancel')}
    HTML
    button = link_to tags_path, class: "btn" do
      raw caption
    end
    button
  end

  # generates tag icon
  # ==== Args
  # _tag_ :: target tag
  # ==== Return
  # html of tag icon image if it has icon_url
  # unless icon_url, icon will be default
  def tag_icon(tag)
    return "" if tag.blank?
    icon = <<-HTML
    <i class="icon-tag"></i>
    HTML
    unless tag.icon_url.blank?
      icon = <<-HTML
      <img src="#{tag.icon_url}" width="20" height="20">
      HTML
    end
    icon.html_safe
  end

  # generates tag remove button
  # ==== Args
  # _tag_ :: target tag
  # ==== Return
  # html of button
  # if the tag has any article, button will be disabled
  def tag_remove_button(tag)
    return "" if tag.blank? || tag.article_tag_rels_count > 0
    btn_class = "btn"
    # btn_class << " disabled" if tag.article_tag_rels_count > 0
    icon = <<-HTML
    <i class="icon-remove"></i>
    HTML
    button = link_to tag, class: btn_class, confirm: t('confirmation'), method: :delete do
      raw icon
    end
    button
  end

end

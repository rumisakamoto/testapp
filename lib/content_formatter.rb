# -*- encoding : utf-8 -*-
require 'pukipa'

module ContentFormatter

  module WikiNotationTypes
    NONE = 0
    MARKDOWN = 1
    TEXTILE = 2
    PUKIWIKI = 3
    def self.to_hash
      {
        NONE => I18n.t('notation_type.none'),
        MARKDOWN => I18n.t('notation_type.markdown'),
        TEXTILE => I18n.t('notation_type.textile'),
        PUKIWIKI => I18n.t('notation_type.pukiwiki')
      }
    end
  end

  def notation_types
    WikiNotationTypes.to_hash
  end

  def self.to_html(content, notation_type)
    if notation_type && notation_type.instance_of?(String) && notation_type.match(/[0-3]/)
      notation_type = notation_type.to_i
    else
      notation_type = 0
    end
    contentClass = Struct.new(:content, :notation_type)
    obj = contentClass.new(content, notation_type)
    obj.extend(ContentFormatter)
    obj.to_html
  end

  def to_html
    html_content = ""
    case notation_type
    when WikiNotationTypes::MARKDOWN#notation_types[:markdown]
      html_content = markdown(content)
    when WikiNotationTypes::TEXTILE#notation_types[:textile]
      html_content = textile(content)
    when WikiNotationTypes::PUKIWIKI#notation_types[:pukiwiki]
      html_content = pukiwiki(content)
    else # none
      content.gsub!("\r\n", "\n")
      content.gsub!("\n", "<br/>")
      html_content = content #markdown(content)
    end
    format_table!(prettify!(html_content))
  end

  private

  def markdown(content)
    RDiscount.new(content, :fold_lines, :autolink, :smart).to_html
  end

  def textile(content)
    RedCloth.new(content).to_html
  end

  def pukiwiki(content)
    PukiWikiParser.new().to_html(content, [])
  end

  def prettify!(html_content)
	html_content.gsub!("<pre>", '<pre class="prettyprint linenums:1">')
    html_content
  end

  def format_table!(html_content)
    html_content.gsub!("<table>", '<table class="table table-bordered table-striped">')
    html_content
  end

end


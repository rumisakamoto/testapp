# -*- encoding : utf-8 -*-

::Date::DATE_FORMATS.merge!(
  :short_jp  => "%-m月%-d日",
  :short_jp2 => lambda { |date| date.strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[date.wday]})") },
  :long_jp   => "%Y年%-m月%-d日",
  :long_jp2  => lambda { |date| date.strftime("%Y年%-m月%-d日(#{%w(日 月 火 水 木 金 土)[date.wday]})") },
  :slash     => "%Y/%m/%d"
)
::Time::DATE_FORMATS.merge!(
  :short_jp  => "%-m月%-d日 %H時%M分",
  :short_jp2 => lambda { |time| time.strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[time.wday]}) %H時%M分") },
  :long_jp   => "%Y年%-m月%-d日 %H時%M分",
  :long_jp2  => lambda { |time| time.strftime("%Y年%-m月%-d日(#{%w(日 月 火 水 木 金 土)[time.wday]}) %H時%M分%S秒") },
  :time_jp   => "%H時%M分",
  :slash     => "%Y/%m/%d %H:%M:%S"
)


class Toppage
  module Ranking
    module MoreLink
      ID_PREFIX = "more_"
      ID_SUFFIX = "_ranking_link"
      PAGE_PARAM_SUFFIX = "_ranking_page"
    end
    module Type
      TAGS = "tags"
      RECOMMENDED_ARTICLES = "recommended_articles"
      FAVORITE_ARTICLES = "favorite_articles"
      ARTICLE_USERS = "article_users"
      FEEDBACK_USERS = "feedback_users"
    end
    module PerPage
      USERS = 5
      ARTICLES = 5
      TAGS = 10
    end
  end
end

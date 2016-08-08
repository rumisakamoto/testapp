# -*- encoding : utf-8 -*-
require 'rubygems'

class User < ActiveRecord::Base
  authenticates_with_sorcery!

  PER_PAGE = 10

  module AuthenticationMethod
    LDAP = Settings.authentication.methods.ldap
    APP = Settings.authentication.methods.app
    AD = Settings.authentication.methods.ad
  end

  validates :username, presence: { on: :create }, uniqueness: { case_sensitive: false }
  validates :password, confirmation: true, presence: { if: :password_required? }
  validates :password_confirmation, presence: { if: :password_required? }
  validates :email, presence: { on: :create }
  validates :role_id, presence: { on: :create }
  validates :nickname, presence: { on: :create }
  validates :admin_password, confirmation: true, presence: { if: :admin_password_required? }
  validates :admin_password_confirmation, presence: { if: :admin_password_required? }
  validate  :admin_authenticated?
  validate  :password_valid?, if: :password_required?

  default_scope -> { where(deleted_at: nil) }
  scope :heavy_users, -> { where('articles_count > 0').order('articles_count desc') }
  scope :heavy_feedback_users, -> { where('feedbacks_count > 0').order('feedbacks_count desc') }
  scope :find_by_username, lambda { |username| where(username: username) }
  scope :anonymous, -> { where(username: Settings.user.anonymous.username) }
  scope :find_by_username_and_crypted_password, lambda { |username, password| where(username: username).where(crypted_password: password) }

  # for batch ranking
  scope :heavy_users_on_last_month, -> {
      joins("inner join (select user_id, count(*) as articles_count_last_month from articles a where a.publicity_level <> #{Accessibility::PRIVATE} and a.created_at between '#{1.month.ago.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")}' and '#{1.day.ago.end_of_day.strftime("%Y-%m-%d %H:%M:%S")}' group by a.user_id) t on (t.user_id = users.id)").order("articles_count_last_month desc").limit(Settings.ranking.item_count)
  }

  def remember_me
    @remember_me
  end
  def remember_me=(value)
    @remember_me = value
  end
  def require_password
    @require_password
  end
  def require_password=(value)
    @require_password = value
  end
  def require_admin_password
    @require_admin_password
  end
  def require_admin_password=(value)
    @require_admin_password = value
  end
  def admin_username
    @admin_username
  end
  def admin_username=(value)
    @admin_username = value
  end
  def admin_password
    @admin_password
  end
  def admin_password=(value)
    @admin_password = value
  end
  def admin_password_confirmation
    @admin_password_confirmation
  end
  def admin_password_confirmation=(value)
    @admin_password_confirmation = value
  end

  has_many :articles
  has_many :feedbacks
  has_many :favorites
  has_many :article_recommendations
  has_many :feedback_recommendations
  has_many :favorite_articles, through: :favorites, source: :article
  has_many :recommend_articles, through: :article_recommendations, source: :article
  belongs_to :role

  # ユーザのロールが管理者かどうかを返します。
  # ==== Args
  # ==== Return
  # 管理者なら true, そうでない場合は false
  def admin?
    role.name == Settings.role.admin
  end

  # override: authenticates username and password by LDAP
  # this method is called by Sorcery::login
  # ==== Args
  # _*credentials_ :: [0]:username, [1]:password, [2]:remember_me assumed
  # ==== Return
  # authenticated user object, otherwise nil
  #def self.authenticate(*credentials)
  #  raise ArgumentError, I18n.t('user.authentication.arg_count_error') if credentials.size < 2
  #  credentials[0].downcase! if @sorcery_config.downcase_username_before_authenticating

  #  username = credentials[0]
  #  password = credentials[1]

  #  Rails.logger.debug "ユーザ認証を開始します。"

  #  # find authenticated user
  #  user = find_or_create_authenticated_user(username, password)

  #  Rails.logger.debug "ユーザ認証を終了します。"

  #  set_encryption_attributes()

  #  # get password salt
  #  _salt = user.send(@sorcery_config.salt_attribute_name) if user && !@sorcery_config.salt_attribute_name.nil? && !@sorcery_config.encryption_provider.nil?
  #  # validate password of found user
  #  if user && @sorcery_config.before_authenticate.all? {|c| user.send(c)} && credentials_match?(user.send(@sorcery_config.crypted_password_attribute_name),credentials[1],_salt)
  #    Rails.logger.info "ユーザ #{username} のログインに成功しました。"
  #    return user
  #  else
  #    Rails.logger.error "ユーザ #{username} のログインに失敗しました。"
  #  end
  #  nil
  #end

  # finds or creates authenticated user according to system authentication
  # ==== Args
  # _username_ :: username to authenticate
  # _password_ :: password to authenticate
  # ==== Return
  # authenticated user object, otherwise nil
  def self.find_or_create_authenticated_user(username, password)
    user_info = select_user(username, password)
    if user_info.blank?
      Rails.logger.debug "user information not found."
      return nil
    end
    Rails.logger.debug "user information found: #{user_info.inspect}"
    # if user_inf has email key, authentication method is ldap or activedirectory
    if user_info.instance_of?(Hash) && user_info.key?(:email)
      return update_or_create(user_info)
    end
    user_info
  end

  #
  # find user by username and password on ldap server or ad server or DB.
  # ==== Args
  # _username_ :: username
  # _password_ :: password
  # ==== Returns
  # authenticated user info hash when authentication method is either ldap or activedirectory.
  # When it is application authentication, User entity will be returned.
  # If authentication failed, nil will be returned.
  #
  def self.select_user(username, password)
    # admin login
    if Settings.user.admin.username.eql?(username) && Settings.user.admin.password.eql?(password)
      Rails.logger.debug "admin authentication"
      return sorcery_adapter.find_by_credentials([username, password])
    end
    # common user login
    case Settings.authentication.setting
    when AuthenticationMethod::AD
      Rails.logger.debug "start activedirectory authentication"
      return ActiveDirectoryAuthenticator::authenticate(username, password)
    when AuthenticationMethod::LDAP
      Rails.logger.debug "start ldap authentication"
      return LdapAuthenticator::authenticate(username, password)
    when AuthenticationMethod::APP
      Rails.logger.debug "start application authentication"
      return sorcery_adapter.find_by_credentials([username, password])
    else # apply application authentication if there is no authentication setting on config/application.yml
      Rails.logger.debug "no authentication setting"
      return sorcery_adapter.find_by_credentials([username, password])
    end
  end

  #
  # creates a new user record if given user_info specifies a new user information
  # otherwise, updates a user record by user_info
  # ==== Args
  # _user_info_ :: user information
  # ==== Return
  # User object
  #
  def self.update_or_create(user_info)
    Rails.logger.debug "start db operation for user_info: #{user_info.inspect}"
    return nil if user_info.blank? || !user_info.any?

    # find user authorized by LDAP on app DB
    user = find_by_username(user_info[:username]).first
    Rails.logger.debug "user is found on db: #{user.inspect}" if user
    Rails.logger.debug "user is not found on db." unless user
    ActiveRecord::Base.transaction do
      if user
        user_info.delete(:username); user_info.delete(:nickname)
        user_info.delete(:email) if user_info[:email].blank?
        Rails.logger.debug "### compare entered password with one on db:"
        Rails.logger.debug user[:crypted_password].eql? Config.new.encryption_provider.encrypt(user_info[:password], user[:salt])
        Rails.logger.debug "##################################"
        # update user's password (email if it is not blank)
        user.update_attributes!(user_info)
        Rails.logger.debug "authorized user info updated: #{user.inspect}"
      else
        # create authenticated user on app DB if app DB has no the user's record
        role = Role.find_by_name(Settings.role.default).first
        Rails.logger.debug "initial role: #{role.inspect}"
        #user_info[:role_id] = role.id
        user = new
        user.username = user_info[:username]
        user.password = user_info[:password]
        user.password_confirmation = user_info[:password]
        user.nickname = user_info[:nickname]
        user.email = user_info[:email]
        user.role_id = role.id
        Rails.logger.debug "user will be created: #{user.inspect}"
        user.save!
        Rails.logger.debug "a new user created on app DB: #{user.inspect}"
      end
    end
    user
  end


  # validates user object
  # ==== Args
  # _user_ :: user objet to validate
  # ==== Return
  # true if user object is valid (not nil, has id accessor, id not nil, id is natural number)
  def self.valid?(user)
    return !(user.blank? || !defined?(user.id) || user.id.blank? || user.id <= 0)
  end

  # determines whether specified user can login
  # ==== Args
  # _username_ :: username
  # ==== Return
  # true if specified user can login, otherwise false
  def self.can_login?(username)
    user = User.find_by_username(username).first
    if user && user.role.accessibility.value == Accessibility::INACTIVE
      return false
    end
    return true
  end

  # deletes logically itself
  def delete!
    ActiveRecord::Base.transaction do
      inactive = Accessibility.inactive.first
      inactive_role = Role.find_by_accessibility_id(inactive.id)
      self.role_id = inactive_role.id
      self.require_password = false
      self.save!
    end
  end

  # gets whether itself needs username input
  def username_required?
    return (new_record? || require_username)
  end

  # gets whether itself needs password input
  def password_required?
    return (new_record? || require_password)
  end

  # gets whether itself needs admin password
  def admin_password_required?
    return (require_admin_password)
  end

  # counts the user's articles which have more than one recommendation
  def article_recommended_count
    article_recommended_count = 0
    self.articles.each do |article|
      article_recommended_count = article_recommended_count + article.article_recommendations_count
    end
    article_recommended_count
  end

  # counts the user's feedbacks which have more than one recommendation
  def feedback_recommended_count
    feedback_recommended_count = 0
    self.feedbacks.each do |feedback|
      feedback_recommended_count = feedback_recommended_count + feedback.feedback_recommendations_count
    end
    feedback_recommended_count
  end

  private

  # set error message if entered password is invalid
  def password_valid?
    if self.password.blank? || self.password_confirmation.blank? || !self.password.eql?(self.password_confirmation)
      return
    end
    if new_record?
      return
    end

    unless User.authenticate(self.username, self.password)
      logger.debug "password authentication failed."
      errors.add(:password)
      errors.add(:password_confirmation)
    end
  end

  # set error message if itself is not admin user
  def admin_authenticated?
    if admin_password_required? && !self.admin_username.blank? && !self.admin_password.blank? && !User.authenticate(self.admin_username, self.admin_password)
      errors.add(:admin_password, I18n.t('user.admin_authentication_error'))
    end
  end

end

# -*- encoding : utf-8 -*-
class Ability
  include CanCan::Ability

  OPT_COND_PUB_LEVEL = 'publicity_level'
  OPT_COND_USER_ID = 'user_id'
  OPT_COND_ID = 'id'
  OPT_COND_CANNOT = 'cannot'

  def initialize(user)
    # user not logged in will be also filtered by sorcery
    user = User.anonymous.first if user.blank?

    # ユーザのroleに設定されている権限に応じてcanメソッドを実行する
    user.role.permissions.each do |permission|
      # optional_conditionカラムの値に応じて権限を設定する
      case permission.optional_condition
      when OPT_COND_PUB_LEVEL
        begin
          # ユーザのroleに設定されているアクセス権以下の公開レベルの対象オブジェクトに対して指定されたアクションを実行できるよう設定する
          can permission.action_name.to_sym, permission.class_name.constantize do |object|
            defined?(object.publicity_level) &&
            (user.role.accessibility.value >= object.publicity_level ||
             (object.publicity_level == Accessibility::PRIVATE && object.user_id == user.id))
          end
        rescue => e
          Rails.logger.error "ユーザ #{user.id} の権限 #{OPT_COND_PUB_LEVEL} 設定中にエラーが発生しました。"
          Rails.logger.error e
        end
      when OPT_COND_USER_ID
        begin
          # 対象オブジェクトのuser_idがユーザIDに等しい場合、指定されたアクションを実行できるよう設定する
          can permission.action_name.to_sym, permission.class_name.constantize do |object|
            defined?(object.user_id) && user.id == object.user_id
          end
        rescue => e
          Rails.logger.error "ユーザ #{user.id} の権限 #{OPT_COND_USER_ID} 設定中にエラーが発生しました。"
          Rails.logger.error e
        end
      when OPT_COND_ID
        begin
          # 対象オブジェクトのidがユーザIDに等しい場合、指定されたアクションを実行できるよう設定する
          can permission.action_name.to_sym, permission.class_name.constantize do |object|
            defined?(object.id) && user.id == object.id
          end
        rescue => e
          Rails.logger.error "ユーザ #{user.id} の権限 #{OPT_COND_ID} 設定中にエラーが発生しました。"
          Rails.logger.error e
        end
      when OPT_COND_CANNOT
        begin
          # ユーザの権限にoptional_condition = cannotが設定されていたら、対象オブジェクトに対し指定されたアクションを実行できないよう設定する
          cannot permission.action_name.to_sym, permission.class_name.constantize
        rescue => e
          Rails.logger.error "ユーザ #{user.id} の権限 #{OPT_COND_CANNOT} 設定中にエラーが発生しました。"
          Rails.logger.error e
        end
      else
        begin
          # optional_conditionの指定がない場合、対象オブジェクトに対し指定されたアクションを実行できるよう設定する
          can permission.action_name.to_sym, permission.class_name.constantize
        rescue => e
          Rails.logger.error "ユーザ #{user.id} の権限設定中にエラーが発生しました。"
          Rails.logger.error e
        end
      end
    end
  end
end

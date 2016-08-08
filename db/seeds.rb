# -*- encoding : utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#
# 注意! rake db:seed する前に、必ず Settings.authentication.setting を application にしてください
# 管理者ユーザレコードを作成する際にLDAP認証エラーが発生してしまいます
#
ActiveRecord::Base.transaction do
  anonymous_accessibility = Accessibility.where(name: Settings.accessibility.anonymous, value: Accessibility::ANONYMOUS).first_or_create!
  member_accessibility = Accessibility.where(name: Settings.accessibility.member, value: Accessibility::MEMBER).first_or_create!
  leader_accessibility = Accessibility.where(name: Settings.accessibility.leader, value: Accessibility::LEADER).first_or_create!
  manager_accessibility = Accessibility.where(name: Settings.accessibility.manager, value: Accessibility::MANAGER).first_or_create!
  admin_accessibility = Accessibility.where(name: Settings.accessibility.admin, value: Accessibility::ADMIN).first_or_create!
  private_accessibility = Accessibility.where(name: Settings.accessibility.private, value: Accessibility::PRIVATE).first_or_create!
  inactive_accessibility = Accessibility.where(name: Settings.accessibility.inactive, value: Accessibility::INACTIVE).first_or_create!

  admin_role = Role.where(name: Settings.role.admin, accessibility_id: admin_accessibility.id).first_or_create!
  manager_role = Role.where(name: Settings.role.manager, accessibility_id: manager_accessibility.id).first_or_create!
  leader_role = Role.where(name: Settings.role.leader, accessibility_id: leader_accessibility.id).first_or_create!
  member_role = Role.where(name: Settings.role.member, accessibility_id: member_accessibility.id).first_or_create!
  anonymous_role = Role.where(name: Settings.role.anonymous, accessibility_id: anonymous_accessibility.id).first_or_create!
  inactive_role = Role.where(name: Settings.role.inactive, accessibility_id: inactive_accessibility).first_or_create!

  # inactive cannot login
  p = Permission.where(action_name: 'create', class_name: 'LoginForm', optional_condition: Ability::OPT_COND_CANNOT).first_or_create!
  RolePermissionRel.where(role_id: inactive_role.id, permission_id: p.id).first_or_create!

  # users except inactives can login
  p = Permission.where(action_name: 'create', class_name: 'LoginForm').first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!


  # anonymous permissions
  p = Permission.where(action_name: 'show', class_name: 'User').first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'index', class_name: 'Article').first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'show', class_name: 'Article', optional_condition: Ability::OPT_COND_PUB_LEVEL).first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'show_more', class_name: 'Article').first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'favorite_articles', class_name: 'Article').first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'recommend_articles', class_name: 'Article').first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'recommended_feedbacks', class_name: 'Article').first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'recommended_articles', class_name: 'Article').first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'articles_by_user', class_name: 'Article').first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'articles_by_tag', class_name: 'Article').first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'search', class_name: 'Article').first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'recently_created_articles', class_name: 'Article', optional_condition: Ability::OPT_COND_PUB_LEVEL).first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!

  # admin permissions
  RolePermissionRel.where(role_id: admin_role.id, permission_id: Permission.where(action_name: 'manage', class_name: 'User').first_or_create!.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: Permission.where(action_name: 'manage', class_name: 'Article').first_or_create!.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: Permission.where(action_name: 'manage', class_name: 'Feedback').first_or_create!.id).first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: Permission.where(action_name: 'manage', class_name: 'Tag').first_or_create!.id).first_or_create!

  # other login user permissions
  p = Permission.where(action_name: 'edit', class_name: 'User', optional_condition: Ability::OPT_COND_ID).first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'update', class_name: 'User', optional_condition: Ability::OPT_COND_ID).first_or_create!
  RolePermissionRel.where(role_id: anonymous_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'preview', class_name: 'Article').first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'favor', class_name: 'Article').first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'recommend', class_name: 'Article').first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'new', class_name: 'Article').first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'create', class_name: 'Article').first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'edit', class_name: 'Article', optional_condition: Ability::OPT_COND_USER_ID).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'update', class_name: 'Article', optional_condition: Ability::OPT_COND_USER_ID).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'destroy', class_name: 'Article', optional_condition: Ability::OPT_COND_USER_ID).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'preview', class_name: 'Feedback').first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'favor', class_name: 'Feedback').first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'recommend', class_name: 'Feedback').first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'new', class_name: 'Feedback').first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'create', class_name: 'Feedback').first_or_create!
  RolePermissionRel.where(role_id: admin_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'edit', class_name: 'Feedback', optional_condition: Ability::OPT_COND_USER_ID).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'update', class_name: 'Feedback', optional_condition: Ability::OPT_COND_USER_ID).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!
  p = Permission.where(action_name: 'destroy', class_name: 'Feedback', optional_condition: Ability::OPT_COND_USER_ID).first_or_create!
  RolePermissionRel.where(role_id: manager_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: leader_role.id, permission_id: p.id).first_or_create!
  RolePermissionRel.where(role_id: member_role.id, permission_id: p.id).first_or_create!

  User.where(username: 'anonymous').first_or_create!(username: 'anonymous', password: 'anonymous', password_confirmation: 'anonymous', email: 'anonymous@example.com', nickname: 'anonymous nickname', role_id: anonymous_role.id)
  User.where(username: 'admin').first_or_create!(username: 'admin', password: 'admin', password_confirmation: 'admin', email: 'admin@example.com', nickname: 'admin nickname', role_id: admin_role.id)
  if Rails.env.development?
    #User.create(username: 'sakamoto', password: 'sakamoto', password_confirmation: 'sakamoto', email: 'sakamoto@example.com', nickname: 'rumi', role_id: leader_role.id)
    #User.create(username: 'testuser1', password: 'testuser1', password_confirmation: 'testuser1', email: 'test_user1@example.com', nickname: 'user1', role_id: manager_role.id)
  end
end

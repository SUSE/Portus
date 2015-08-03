FactoryGirl.define do

  factory :activity_team_create, class: PublicActivity::Activity do
    owner_type "User"
    key "team.create"
    trackable_type "Team"
  end

  factory :activity_team_add_member, class: PublicActivity::Activity do
    owner_type "User"
    key "team.add_member"
    trackable_type "Team"
    recipient_type "User"
  end

  factory :activity_team_remove_member, class: PublicActivity::Activity do
    owner_type "User"
    key "team.remove_member"
    trackable_type "Team"
    recipient_type "User"
  end

  factory :activity_team_change_member_role, class: PublicActivity::Activity do
    owner_type "User"
    key "team.change_member_role"
    trackable_type "Team"
    recipient_type "User"
  end

  factory :activity_namespace_create, class: PublicActivity::Activity do
    owner_type "User"
    key "namespace.create"
    trackable_type "Namespace"
  end

  factory :activity_namespace_public, class: PublicActivity::Activity do
    owner_type "User"
    key "namespace.public"
    trackable_type "Namespace"
  end

  factory :activity_namespace_private, class: PublicActivity::Activity do
    owner_type "User"
    key "namespace.private"
    trackable_type "Namespace"
  end

  factory :activity_repository_push, class: PublicActivity::Activity do
    owner_type "User"
    key "repository.push"
    trackable_type "Repository"
    recipient_type "Tag"
  end

end

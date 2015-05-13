require 'rails_helper'

describe PublicActivity::ActivityPolicy do

  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:activity_owner) { create(:user) }
  let(:registry) { create(:registry) }
  let(:namespace) { create(:namespace, registry: registry, team: team) }
  let(:team) { create(:team, owners: [user] ) }
  let(:repository) { create(:repository, namespace: namespace) }
  let(:tag) { create(:tag, repository: repository) }

  subject { described_class }

  describe 'scope' do
    it 'returns pertinent team activities' do
      activities = [
        create_activity_team_create(team, activity_owner),
        create_activity_team_add_member(team, activity_owner, another_user),
        create_activity_team_change_member_role(
          team, activity_owner, another_user, 'viewer', 'owner'),
        create_activity_team_remove_member(team, activity_owner, another_user)
      ]

      #ignored events, not related with a team the user is member of
      create_activity_team_create(create(:team), another_user)

      expect(Pundit.policy_scope(user, PublicActivity::Activity).to_a).to match_array(activities)
    end

    it 'returns pertinent namespace events' do
      namespace2 = create(:namespace,
                          registry: registry,
                          team: create(:team,
                                       owners: [another_user]))

      activities = [
        create(:activity_namespace_create,
               trackable_id: namespace.id,
               owner_id: activity_owner.id),
        create(:activity_namespace_public,
               trackable_id: namespace.id,
               owner_id: activity_owner.id),
        create(:activity_namespace_private,
               trackable_id: namespace.id,
               owner_id: activity_owner.id),
        # all the public/private events are shown, even the ones
        # involving namespaces the user does not control
        create(:activity_namespace_public,
               trackable_id: namespace2.id,
               owner_id: activity_owner.id),
        create(:activity_namespace_private,
               trackable_id: namespace2.id,
               owner_id: activity_owner.id)
      ]

      create(:activity_namespace_create,
             trackable_id: namespace2.id,
             owner_id: activity_owner.id)

      expect(Pundit.policy_scope(user, PublicActivity::Activity).to_a).to match_array(activities)
    end

    it 'returns pertinent tag events' do
      namespace2 = create(:namespace,
                          registry: registry,
                          team: create(:team,
                                       owners: [another_user]))
      private_tag = create(:tag, repository: create(:repository, namespace: namespace2) )

      public_namespace = create(:namespace,
                                registry: registry,
                                public: true,
                                team: create(:team,
                                             owners: [another_user],
                                             namespaces: [namespace2] ))
      public_tag = create(:tag, repository: create(:repository, namespace: public_namespace) )

      activities = [
        create(:activity_tag_push,
               trackable_id: tag.id,
               owner_id: activity_owner.id),
        # Tag made inside of public namespaces are shown even
        # if the user does not control their namespace
        create(:activity_tag_push,
               trackable_id: public_tag.id,
               owner_id: activity_owner.id)
      ]

      create(:activity_namespace_create,
             trackable_id: private_tag.id,
             owner_id: activity_owner.id)

      expect(Pundit.policy_scope(user, PublicActivity::Activity).to_a).to match_array(activities)
    end

    it 'mixes different types of activities' do
      activities = [
        create_activity_team_create(team, activity_owner),
        create(:activity_namespace_create,
               trackable_id: namespace.id,
               owner_id: activity_owner.id),
        create(:activity_tag_push,
               trackable_id: tag.id,
               owner_id: activity_owner.id)
      ]

      expect(Pundit.policy_scope(user, PublicActivity::Activity).to_a).to match_array(activities)
     end
  end

  private

  def create_activity_team_create(team, activity_owner)
    create(:activity_team_create,
           trackable_id: team.id,
           owner_id: activity_owner.id)
  end

  def create_activity_team_add_member(team, event_owner, new_member)
    create(:activity_team_add_member,
           trackable_id: team.id,
           owner_id: event_owner.id,
           recipient_id: new_member.id)
  end

  def create_activity_team_remove_member(team, event_owner, old_member)
    create(:activity_team_remove_member,
           trackable_id: team.id,
           owner_id: event_owner.id,
           recipient_id: old_member.id)
  end

  def create_activity_team_change_member_role(team, event_owner, member, old_role, new_role)
    create(:activity_team_change_member_role,
           trackable_id: team.id,
           owner_id: event_owner.id,
           recipient_id: member.id,
           parameters: { old_role: old_role, new_role: new_role })
  end

end

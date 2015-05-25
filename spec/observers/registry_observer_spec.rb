require 'rails_helper'

describe RegistryObserver do

  before :each do
    @admin = create(:user, admin: true)
    @user  = create(:user)

    expect(Namespace.count).to be(0)
  end

  describe 'after_create' do

    before :each do
      create(:registry)
    end

    it 'all users have a personal namespace' do
      User.all.each do |user|
        expect(Namespace.find_by(name: user.username)).not_to be(nil)
      end
    end

  end
end

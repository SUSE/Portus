require 'rails_helper'

describe UserObserver do

  let(:user) { build(:user) }

  describe 'after_create' do

    it 'calls create_personal_namespace! on a user' do
      expect(user).to receive(:create_personal_namespace!)
      described_class.instance.after_create(user)
    end

  end

end

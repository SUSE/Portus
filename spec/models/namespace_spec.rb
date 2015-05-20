require 'rails_helper'

describe Namespace do

  it { should have_many(:repositories) }
  it { should belong_to(:team) }
  it { should validate_presence_of(:name) }
  it { should allow_value('test1', '1test', 'another-test').for(:name) }
  it { should_not allow_value('TesT1', '1Test', 'another_test!').for(:name) }

  context 'sanitize name' do
    it 'replaces white spaces with underscores' do
      expect(Namespace.sanitize_name('the qa team')).to eq('the_qa_team')
    end

    it 'downcase all letters' do
      expect(Namespace.sanitize_name('QA')).to eq('qa')
    end

    it 'remove unsupported chars' do
      expect(Namespace.sanitize_name('qa, developers & others')).to eq('qa_developers__others')
    end
  end

  context 'global namespace' do
    it 'must be public' do
      namespace = create(:namespace, global: true, public: true)
      namespace.public = false
      expect(namespace.save).to be false
    end
  end

end

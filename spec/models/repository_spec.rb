require 'rails_helper'

describe Repository do

  it { should belong_to(:namespace) }
  it { should have_many(:tags) }

  describe 'handle push event' do

    let(:tag) { 'latest' }
    let(:repository_name) { 'busybox' }

    context 'event does not match regexp of manifest' do

      let(:event) do
        {
          'target' => {
            'repository' => repository_name,
            'url' =>  "http://registry.test.lan/v2/#{repository_name}/wrong/#{tag}"
          }
        }
      end

      it 'sends event to logger' do
        error_msg = 'Cannot find tag inside of event url: http://registry.test.lan/v2/busybox/wrong/latest'
        expect(Rails.logger).to receive(:error).with(error_msg)
        Repository.handle_push_event(event)
      end

    end


    context 'when dealing with a top level repository' do
      let(:event) do
        {
          'target' => {
            'repository' => repository_name,
            'url' =>  "http://registry.test.lan/v2/#{repository_name}/manifests/#{tag}"
          }
        }
      end

      context 'when the repository is not known by Portus' do
        it 'should create repository and tag objects' do
          repository = Repository.handle_push_event(event)

          expect(repository).not_to be_nil
          expect(Namespace.count).to eq 0
          expect(Repository.count).to eq 1
          expect(Tag.count).to eq 1

          expect(repository.namespace).to be_nil
          expect(repository.name).to eq(repository_name)
          expect(repository.tags.count).to eq 1
          expect(repository.tags.first.name).to eq tag
        end
      end

      context 'when a new version of an already known repository' do
        it 'should create a new tag' do
          repository = create(:repository, name: repository_name)
          repository.tags << Tag.new(name: '1.0.0')

          repository = Repository.handle_push_event(event)

          expect(repository).not_to be_nil
          expect(Namespace.count).to eq 0
          expect(Repository.count).to eq 1
          expect(Tag.count).to eq 2

          expect(repository.namespace).to be_nil
          expect(repository.name).to eq(repository_name)
          expect(repository.tags.count).to eq 2
          expect(repository.tags.map(&:name)).to include('1.0.0', tag)
        end
      end
    end

    context 'when the repository is inside of namespace' do
      let(:namespace_name) { 'SUSE' }
      let(:event) do
        {
          'target' => {
            'repository' => "#{namespace_name}/#{repository_name}",
            'url' =>  "http://registry.test.lan/v2/#{namespace_name}/#{repository_name}/manifests/#{tag}"
          }
        }
      end

      context 'when the namespaceis not known by Portus' do
        it 'should create a namespace with a tagged repository' do
          create(:namespace, name: 'openSUSE')

          repository = Repository.handle_push_event(event)

          expect(repository).not_to be_nil
          expect(Namespace.count).to eq 2
          expect(Repository.count).to eq 1
          expect(Tag.count).to eq 1

          expect(repository.namespace.name).to eq(namespace_name)
          expect(repository.name).to eq(repository_name)
          expect(repository.tags.count).to eq(1)
          expect(repository.tags.first.name).to eq(tag)
        end
      end

      context 'when the namespace is known by Portus' do
        before :each do
          create(:namespace, name: namespace_name)
        end

        it 'should create repository and tag objects when the repository is unknown to portus' do
          repository = Repository.handle_push_event(event)

          expect(repository).not_to be_nil
          expect(Repository.count).to eq 1
          expect(Repository.count).to eq 1
          expect(Tag.count).to eq 1

          expect(repository.namespace.name).to eq(namespace_name)
          expect(repository.name).to eq(repository_name)
          expect(repository.tags.count).to eq 1
          expect(repository.tags.first.name).to eq tag
        end

        it 'should create a new tag when the repository is already known to portus' do
          repository = create(:repository, name: repository_name)
          repository.tags << Tag.new(name: '1.0.0')

          repository = Repository.handle_push_event(event)

          expect(repository).not_to be_nil
          expect(Repository.count).to eq 1
          expect(Repository.count).to eq 1
          expect(Tag.count).to eq 2

          expect(repository.namespace.name).to eq(namespace_name)
          expect(repository.name).to eq(repository_name)
          expect(repository.tags.count).to eq 2
          expect(repository.tags.map(&:name)).to include('1.0.0', tag)
        end
      end
    end
  end
end

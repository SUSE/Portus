require 'rails_helper'

describe Repository do

  it { should belong_to(:namespace) }
  it { should have_many(:tags) }

  describe 'handle push event' do

    let(:tag) { 'latest' }
    let(:repository_name) { 'busybox' }
    let(:registry) { create(:registry) }
    let(:user) { create(:user) }

    context 'event does not match regexp of manifest' do

      let(:event) do
        e = attributes_for(:raw_push_manifest_event).stringify_keys
        e['target']['repository'] = repository_name
        e['target']['url'] = "http://registry.test.lan/v2/#{repository_name}/wrong/#{tag}"
        e['request']['host'] = registry.hostname
        e
      end

      it 'sends event to logger' do
        error_msg = 'Cannot find tag inside of event url: http://registry.test.lan/v2/busybox/wrong/latest'
        expect(Rails.logger).to receive(:error).with(error_msg)
        expect do
          Repository.handle_push_event(event)
        end.to change(Repository, :count).by(0)
      end

    end

    context 'event comes from an unknown registry' do
      before :each do
        @event = attributes_for(:raw_push_manifest_event).stringify_keys
        @event['target']['repository'] = repository_name
        @event['target']['url'] = "http://registry.test.lan/v2/#{repository_name}/manifests/#{tag}"
        @event['request']['host'] = 'unknown-registry.test.lan'
        @event['actor']['name'] = user.username

        @global_namespace = Namespace.new(name: nil, registry: registry)
        @global_namespace.save(validate: false)
      end

      it 'sends event to logger' do
        expect(Rails.logger).to receive(:info)
        expect do
          Repository.handle_push_event(@event)
        end.to change(Repository, :count).by(0)
      end
    end

    context 'event comes from an unknown user' do
      before :each do
        @event = attributes_for(:raw_push_manifest_event).stringify_keys
        @event['target']['repository'] = repository_name
        @event['target']['url'] = "http://registry.test.lan/v2/#{repository_name}/manifests/#{tag}"
        @event['request']['host'] = registry.hostname
        @event['actor']['name'] = 'a_ghost'

        @global_namespace = Namespace.new(name: nil, registry: registry)
        @global_namespace.save(validate: false)
      end

      it 'sends event to logger' do
        expect(Rails.logger).to receive(:error)
        expect do
          Repository.handle_push_event(@event)
        end.to change(Repository, :count).by(0)
      end

    end

    context 'when dealing with a top level repository' do
      before :each do
        @event = attributes_for(:raw_push_manifest_event).stringify_keys
        @event['target']['repository'] = repository_name
        @event['target']['url'] = "http://registry.test.lan/v2/#{repository_name}/manifests/#{tag}"
        @event['request']['host'] = registry.hostname
        @event['actor']['name'] = user.username

        @global_namespace = Namespace.new(name: nil, registry: registry)
        @global_namespace.save(validate: false)
      end

      context 'when the repository is not known by Portus' do
        it 'should create repository and tag objects' do
          repository = nil
          expect do
            repository = Repository.handle_push_event(@event)
          end.to change(Namespace, :count).by(0)

          expect(repository).not_to be_nil
          expect(Repository.count).to eq 1
          expect(Tag.count).to eq 1

          expect(repository.namespace).to eq(@global_namespace)
          expect(repository.name).to eq(repository_name)
          expect(repository.tags.count).to eq 1
          expect(repository.tags.first.name).to eq tag
        end

        it 'tracks the event' do
          repository = nil
          expect do
            repository = Repository.handle_push_event(@event)
          end.to change(PublicActivity::Activity, :count).by(1)

          activity = PublicActivity::Activity.last
          expect(activity.key).to eq('tag.push')
          expect(activity.owner).to eq(user)
          expect(activity.trackable).to eq(repository.tags.last)
        end
      end

      context 'when a new version of an already known repository' do
        before :each do
          repository = create(:repository, name: repository_name)
          repository.tags << Tag.new(name: '1.0.0')
        end

        it 'should create a new tag' do
          repository = nil
          expect do
            repository = Repository.handle_push_event(@event)
          end.to change(Namespace, :count).by(0)

          expect(repository).not_to be_nil
          expect(Namespace.count).to eq 2
          expect(Repository.count).to eq 1
          expect(Tag.count).to eq 2

          expect(repository.namespace).to eq(@global_namespace)
          expect(repository.name).to eq(repository_name)
          expect(repository.tags.count).to eq 2
          expect(repository.tags.map(&:name)).to include('1.0.0', tag)
        end

        it 'tracks the event' do
          repository = nil
          expect do
            repository = Repository.handle_push_event(@event)
          end.to change(PublicActivity::Activity, :count).by(1)

          activity = PublicActivity::Activity.last
          expect(activity.key).to eq('tag.push')
          expect(activity.owner).to eq(user)
          expect(activity.trackable).to eq(repository.tags.find_by(name: tag))
        end
      end
    end

    context 'not global repository' do
      let(:namespace_name) { 'suse' }

      before :each do
        @event = attributes_for(:raw_push_manifest_event).stringify_keys
        @event['target']['repository'] = "#{namespace_name}/#{repository_name}"
        @event['target']['url'] = "http://registry.test.lan/v2/#{namespace_name}/#{repository_name}/manifests/#{tag}"
        @event['request']['host'] = registry.hostname
        @event['actor']['name'] = user.username
      end

      context 'when the namespace is not known by Portus' do
        it 'does not create the namespace' do
          repository = Repository.handle_push_event(@event)
          expect(repository).to be_nil
        end
      end

      context 'when the namespace is known by Portus' do
        before :each do
          @namespace = create(:namespace, name: namespace_name, registry: registry)
        end

        it 'should create repository and tag objects when the repository is unknown to portus' do
          repository = Repository.handle_push_event(@event)

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
          repository = create(:repository, name: repository_name, namespace: @namespace)
          repository.tags << Tag.new(name: '1.0.0')

          repository = Repository.handle_push_event(@event)

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

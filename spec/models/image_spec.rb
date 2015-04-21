require 'rails_helper'

describe Image do

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
        Image.handle_push_event(event)
      end

    end


    context 'when dealing with a top level image' do
      let(:event) do
        {
          'target' => {
            'repository' => repository_name,
            'url' =>  "http://registry.test.lan/v2/#{repository_name}/manifests/#{tag}"
          }
        }
      end

      context 'when the image is not known by Portus' do
        it 'should create image and tag objects' do
          image = Image.handle_push_event(event)

          expect(image).not_to be_nil
          expect(Repository.count).to eq 0
          expect(Image.count).to eq 1
          expect(Tag.count).to eq 1

          expect(image.namespace).to be_nil
          expect(image.name).to eq(image_name)
          expect(image.tags.count).to eq 1
          expect(image.tags.first.name).to eq tag
        end
      end

      context 'when a new version of an already known image' do
        it 'should create a new tag' do
          image = create(:image, name: image_name)
          image.tags << Tag.new(name: '1.0.0')

          image = Image.handle_push_event(event)

          expect(image).not_to be_nil
          expect(Repository.count).to eq 0
          expect(Image.count).to eq 1
          expect(Tag.count).to eq 2

          expect(image.namespace).to be_nil
          expect(image.name).to eq(image_name)
          expect(image.tags.count).to eq 2
          expect(image.tags.map(&:name)).to include('1.0.0', tag)
        end
      end
    end

    context 'when the image is inside of namespace' do
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
        it 'should create a namespace with a tagged image' do
          create(:namespace, name: 'openSUSE')

          image = Image.handle_push_event(event)

          expect(image).not_to be_nil
          expect(Namespace.count).to eq 2
          expect(Image.count).to eq 1
          expect(Tag.count).to eq 1

          expect(image.namespace.name).to eq(namespace_name)
          expect(image.name).to eq(image_name)
          expect(image.tags.count).to eq(1)
          expect(image.tags.first.name).to eq(tag)
        end
      end

      context 'when the namespace is known by Portus' do
        before :each do
          create(:namespace, name: namespace_name)
        end

        it 'should create image and tag objects when the image is unknown to portus' do
          image = Image.handle_push_event(event)

          expect(image).not_to be_nil
          expect(Repository.count).to eq 1
          expect(Image.count).to eq 1
          expect(Tag.count).to eq 1

          expect(image.namespace.name).to eq(namespace_name)
          expect(image.name).to eq(image_name)
          expect(image.tags.count).to eq 1
          expect(image.tags.first.name).to eq tag
        end

        it 'should create a new tag when the image is already known to portus' do
          image = create(:image, name: image_name)
          image.tags << Tag.new(name: '1.0.0')

          image = Image.handle_push_event(event)

          expect(image).not_to be_nil
          expect(Repository.count).to eq 1
          expect(Image.count).to eq 1
          expect(Tag.count).to eq 2

          expect(image.namespace.name).to eq(namespace_name)
          expect(image.name).to eq(image_name)
          expect(image.tags.count).to eq 2
          expect(image.tags.map(&:name)).to include('1.0.0', tag)
        end
      end
    end
  end
end

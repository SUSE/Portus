require 'rails_helper'

RSpec.describe Image, type: :model do
  describe 'handle push event' do
    let(:tag) { 'latest' }
    let(:image_name) { 'busybox' }

    context 'when dealing with a top level image' do
      let(:event) {
        {
          'target' => {
            'repository' => image_name,
            'url' =>  "http://registry.test.lan/v2/#{image_name}/manifests/#{tag}"
          }
        }
      }

      context "when the image is not known by Portus" do
        it 'should create image and tag objects' do
          image = Image.handle_push_event(event)

          expect(image).not_to be_nil
          expect(Repository.count).to eq 0
          expect(Image.count).to eq 1
          expect(Tag.count).to eq 1

          expect(image.repository).to be_nil
          expect(image.name).to eq(image_name)
          expect(image.tags.count).to eq 1
          expect(image.tags.first.name).to eq tag
        end
      end

      context "when a new version of an already known image" do
        it 'should create a new tag' do
          image = create(:image, name: image_name)
          image.tags << Tag.new(name: '1.0.0')

          image = Image.handle_push_event(event)

          expect(image).not_to be_nil
          expect(Repository.count).to eq 0
          expect(Image.count).to eq 1
          expect(Tag.count).to eq 2

          expect(image.repository).to be_nil
          expect(image.name).to eq(image_name)
          expect(image.tags.count).to eq 2
          expect(image.tags.map(&:name)).to include('1.0.0', tag)
        end
      end
    end

    context 'when the image is inside of repository' do
      let(:repository_name) { 'SUSE' }
      let(:event) {
        {
          'target' => {
            'repository' => "#{repository_name}/#{image_name}",
            'url' =>  "http://registry.test.lan/v2/#{repository_name}/#{image_name}/manifests/#{tag}"
          }
        }
      }

      context 'when the repository is not known by Portus' do
        it 'should create a repository with a taggd image' do
          create(:repository, name: 'openSUSE')

          image = Image.handle_push_event(event)

          expect(image).not_to be_nil
          expect(Repository.count).to eq 2
          expect(Image.count).to eq 1
          expect(Tag.count).to eq 1

          expect(image.repository.name).to eq(repository_name)
          expect(image.name).to eq(image_name)
          expect(image.tags.count).to eq(1)
          expect(image.tags.first.name).to eq(tag)
        end
      end

      context 'when the repository is known by Portus' do
        before :each do
          create(:repository, name: repository_name)
        end

        it 'should create image and tag objects when the image is unknown to portus' do
          image = Image.handle_push_event(event)

          expect(image).not_to be_nil
          expect(Repository.count).to eq 1
          expect(Image.count).to eq 1
          expect(Tag.count).to eq 1

          expect(image.repository.name).to eq(repository_name)
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

          expect(image.repository.name).to eq(repository_name)
          expect(image.name).to eq(image_name)
          expect(image.tags.count).to eq 2
          expect(image.tags.map(&:name)).to include('1.0.0', tag)
        end
      end
    end
  end
end

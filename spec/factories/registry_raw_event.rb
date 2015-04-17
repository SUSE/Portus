require_relative '../support/models/registry_raw_event'

FactoryGirl.define do
  factory :raw_push_manifest_event, class: RegistryRawEvent do
    action "push"
    target ({
      'repository' => 'foo/busybox',
      'url' =>  'http://registry.test.lan/v2/foo/manifests/latest'
    })
  end

  factory :raw_push_layer_event, class: RegistryRawEvent do
    action "push"
    target ({
      'repository' => 'foo/busybox',
      'url' =>  'http://registry.test.lan/v2/foo/layer/123'
    })
  end

  factory :raw_pull_event, class: RegistryRawEvent do
    action "pull"
    target ({
      'repository' => 'foo/busybox',
      'url' =>  'http://registry.test.lan/v2/foo/manifests/latest'
    })
  end
end

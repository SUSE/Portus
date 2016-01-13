namespace :sshipway do
  desc "Create registry"
  task :registry, [:registryname, :hostport, :withssl] => :environment do |_, args|
    args.each do |k, v|
      if v.empty?
        puts "You have to provide a value for `#{k}'"
        exit(-1)
      end
    end

    @registry = Registry.new(
       name:     args["registryname"],
       hostname: args["hostport"],
       use_ssl:  args["withssl"]
    )

    if @registry.save
       Namespace.update_all(registry_id: @registry.id)
       puts "Registry was successfully created."
    else
       puts @registry.errors.full_messages
       exit(-1)
    end
  end
end

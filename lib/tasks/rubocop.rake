if Rails.env.development?
  require "rubocop/rake_task"

  desc "Run Rubocop linting tool"
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.fail_on_error = true
  end
end

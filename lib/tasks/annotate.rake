# frozen_string_literal: true

if Rails.env.development? && ENV["CI"].blank?
  require "annotate"
  require "portus/db"

  if Portus::DB.mysql?
    task :set_annotation_options do
      ::Annotate.set_defaults(
        position_in_routes:   "before",
        position_in_class:    "before",
        position_in_test:     "before",
        position_in_fixture:  "before",
        position_in_factory:  "before",
        show_indexes:         "true",
        simple_indexes:       "false",
        model_dir:            "app/models",
        include_version:      "false",
        require:              "",
        exclude_tests:        "false",
        exclude_fixtures:     "false",
        exclude_factories:    "false",
        ignore_model_sub_dir: "false",
        skip_on_db_migrate:   "false",
        format_bare:          "true",
        format_rdoc:          "false",
        format_markdown:      "false",
        sort:                 "false",
        force:                "false",
        trace:                "false",
        routes:               "false"
      )
    end

    ::Annotate.load_tasks
  end

  namespace :portus do
    desc "Annotate models with a proper exit code"
    task annotate_and_exit: :environment do
      exit 0 if ENV["TRAVIS"] && !Portus::DB.mysql?

      output = `bundle exec rake annotate_models`
      print output

      exit 1 if output.match?(/Annotated \(\d+\)/)
    end
  end
end

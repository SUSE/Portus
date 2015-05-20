
namespace :db do
  task :sqlite_to_postgresql do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create:all'].invoke

    sqlite   = "sqlite://db/#{Rails.env}.sqlite3"
    postgres = "postgres://postgres@localhost/portus_#{Rails.env}"
    `bundle exec sequel -C #{sqlite} #{postgres}`
  end
end


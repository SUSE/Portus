# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_14_173309) do

  create_table "activities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "trackable_type"
    t.integer "trackable_id"
    t.string "owner_type"
    t.integer "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.integer "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "index_activities_on_key"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type"], name: "index_activities_on_trackable_type"
  end

  create_table "application_tokens", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "application", null: false
    t.string "token_hash", null: false
    t.string "token_salt", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_application_tokens_on_user_id"
  end

  create_table "comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "body"
    t.integer "repository_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["repository_id"], name: "index_comments_on_repository_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "namespaces", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
    t.integer "registry_id", null: false
    t.boolean "global", default: false
    t.text "description"
    t.integer "visibility"
    t.index ["name", "registry_id"], name: "index_namespaces_on_name_and_registry_id", unique: true
    t.index ["registry_id"], name: "index_namespaces_on_registry_id"
    t.index ["team_id"], name: "index_namespaces_on_team_id"
  end

  create_table "registries", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "hostname", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "use_ssl"
    t.string "external_hostname"
    t.index ["hostname"], name: "index_registries_on_hostname", unique: true
    t.index ["name"], name: "index_registries_on_name", unique: true
  end

  create_table "registry_events", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "event_id", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.text "data"
  end

  create_table "repositories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "namespace_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "marked", default: false
    t.text "description"
    t.index ["name", "namespace_id"], name: "index_repositories_on_name_and_namespace_id", unique: true
    t.index ["namespace_id"], name: "index_repositories_on_namespace_id"
  end

  create_table "scan_results", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "vulnerability_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vulnerability_id", "tag_id"], name: "index_scan_results_on_vulnerability_id_and_tag_id"
  end

  create_table "stars", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "repository_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repository_id"], name: "index_stars_on_repository_id"
    t.index ["user_id"], name: "index_stars_on_user_id"
  end

  create_table "tags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", default: "latest", null: false
    t.integer "repository_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "digest"
    t.string "image_id", default: ""
    t.boolean "marked", default: false
    t.string "username"
    t.integer "scanned", default: 0
    t.bigint "size"
    t.datetime "pulled_at"
    t.index ["repository_id"], name: "index_tags_on_repository_id"
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "team_users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.index ["team_id"], name: "index_team_users_on_team_id"
    t.index ["user_id"], name: "index_team_users_on_user_id"
  end

  create_table "teams", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false
    t.text "description"
    t.integer "ldap_group_checked", default: 0
    t.datetime "checked_at"
    t.index ["name"], name: "index_teams_on_name", unique: true
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "admin", default: false
    t.boolean "enabled", default: true
    t.string "ldap_name"
    t.integer "failed_attempts", default: 0
    t.datetime "locked_at"
    t.integer "namespace_id"
    t.string "display_name"
    t.string "provider"
    t.string "uid"
    t.boolean "bot", default: false
    t.integer "ldap_group_checked", default: 0
    t.index ["display_name"], name: "index_users_on_display_name", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["namespace_id"], name: "index_users_on_namespace_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "vulnerabilities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "scanner", default: "", null: false
    t.string "severity", default: "", null: false
    t.string "link", default: "", null: false
    t.string "fixed_by", default: "", null: false
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["name"], name: "index_vulnerabilities_on_name", unique: true
  end

  create_table "webhook_deliveries", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "webhook_id"
    t.string "uuid"
    t.integer "status"
    t.text "request_header"
    t.text "request_body"
    t.text "response_header"
    t.text "response_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["webhook_id", "uuid"], name: "index_webhook_deliveries_on_webhook_id_and_uuid", unique: true
    t.index ["webhook_id"], name: "index_webhook_deliveries_on_webhook_id"
  end

  create_table "webhook_headers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "webhook_id"
    t.string "name"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["webhook_id", "name"], name: "index_webhook_headers_on_webhook_id_and_name", unique: true
    t.index ["webhook_id"], name: "index_webhook_headers_on_webhook_id"
  end

  create_table "webhooks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "namespace_id"
    t.string "url"
    t.string "username"
    t.string "password"
    t.integer "request_method"
    t.integer "content_type"
    t.boolean "enabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.index ["namespace_id"], name: "index_webhooks_on_namespace_id"
  end

  add_foreign_key "comments", "repositories"
  add_foreign_key "stars", "repositories"
  add_foreign_key "stars", "users"
  add_foreign_key "users", "namespaces"
  add_foreign_key "webhook_deliveries", "webhooks"
  add_foreign_key "webhook_headers", "webhooks"
  add_foreign_key "webhooks", "namespaces"
end

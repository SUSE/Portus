
name  = ENV['ADMIN_NAME']     || 'portus_admin'
email = ENV['ADMIN_EMAIL']    || 'admin@example.com'
pass  = ENV['ADMIN_PASSWORD'] || '12341234'

User.create!(username: name, email: email, password: pass, admin: true)

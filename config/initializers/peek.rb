if defined? Peek
  Peek.into Peek::Views::Git, nwo: "suse/portus"
  Peek.into Peek::Views::GC
  Peek.into Peek::Views::PerformanceBar

  case ActiveRecord::Base.configurations[Rails.env]["adapter"]
  when "mysql2" then Peek.into Peek::Views::Mysql2
  when "postgresql" then Peek.into Peek::Views::PG
  end
end

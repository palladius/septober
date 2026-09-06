# db/seeds.rb
puts "== Seeding Septober database =="

palladius = User.find_or_initialize_by(username: "palladius")
palladius.email = "palladiusbonton@gmail.com"
palladius.password = "septober"
palladius.password_confirmation = "septober"
palladius.admin = true
palladius.save!
puts "✓ User palladius (palladiusbonton@gmail.com) created with password: septober"

# Sub-Agents
agents_data = [
  { username: "palladius.ermete", icon: "🚛", host: "cloudrun", email: "palladiusbonton+ermete@gmail.com" },
  { username: "palladius.lobby",  icon: "🦞", host: "mini-lobby", email: "palladiusbonton+lobby@gmail.com" },
  { username: "palladius.pux",    icon: "🐾", host: "pupurabbux", email: "palladiusbonton+pux@gmail.com" }
]

agents_data.each do |data|
  agent = User.find_or_initialize_by(username: data[:username])
  agent.parent_id = palladius.id
  agent.is_agent = true
  agent.agent_icon = data[:icon]
  agent.agent_host = data[:host]
  agent.email = data[:email]
  agent.password = "secret123"
  agent.password_confirmation = "secret123"
  agent.save!
  puts "✓ Sub-agent #{data[:icon]} #{data[:username]} created"
end

# Guest
guest = User.find_or_initialize_by(username: "guest")
guest.email = "guest@example.com"
guest.password = "seed-guest"
guest.password_confirmation = "seed-guest"
guest.save!
puts "✓ User guest created with password: seed-guest"

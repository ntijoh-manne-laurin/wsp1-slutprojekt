require 'time'

class Login
  def self.db
    return @db if @db

    @db = SQLite3::Database.new("db/data.sqlite")
    @db.results_as_hash = true

    return @db
  end

  def self.log(ip)
    db.execute('INSERT INTO loginAttempts (ip, time) VALUES (?,?)', [ip, Time.now.to_s])
  end

  def self.safe?(ip)
    prev_attempts = db.execute('SELECT * FROM loginAttempts WHERE ip=? ORDER BY time DESC', [ip])[0..9]
    p prev_attempts

    current_time = Time.now
    prev_attempts.each {|attempt| return true if current_time - Time.parse(attempt["time"]) > 5}
    return false
  end

end
class User
  def self.db
		return @db if @db

		@db = SQLite3::Database.new("db/data.sqlite")
		@db.results_as_hash = true

		return @db
	end

  def self.get_by_id(id)
    return db.execute('SELECT * FROM users WHERE id=?', id).first
  end

  def self.get_by_name(name)
    return db.execute('SELECT * FROM users WHERE name=?', name).first
  end

  def self.new(name, password) 
    hashed_password = BCrypt::Password.create(password)

    db.execute('INSERT INTO users (name, password, type) VALUES (?,?,?)', [name, hashed_password, 0])
  end

end
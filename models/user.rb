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

  def self.getall
    return db.execute('SELECT * FROM USERS')
  end

  def self.register(name, password)
    hashed_password = BCrypt::Password.create(password)

    db.execute('INSERT INTO users (name, password, type) VALUES (?,?,?)', [name, hashed_password, 0])
  end

  def self.new(name, password, type) 
    hashed_password = BCrypt::Password.create(password)

    db.execute('INSERT INTO users (name, password, type) VALUES (?,?,?)', [name, hashed_password, type])
  end

  def self.is_admin?(user)
    if user.nil? 
      return false 
    else 
      return user['type'] == 2
    end
  end

  def self.destroy(id)
    db.execute('DELETE FROM users WHERE id=?', id)
  end

  def self.update(id, name, password, type)
    hashed_password = BCrypt::Password.create(password)

    db.execute('UPDATE users SET name=?, password=?, type=? WHERE id=?', [name, hashed_password, type, id])
  end

end
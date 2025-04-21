require 'sqlite3'

class Seeder

  def self.seed!
    drop_table
    create_table
    populate
    db.close
  end

  def self.drop_table
    db.execute('DROP TABLE IF EXISTS item;')
    db.execute('DROP TABLE IF EXISTS user;')
    db.execute('DROP TABLE IF EXISTS cart;')
  end

  def self.create_table
    db.execute('CREATE TABLE IF NOT EXISTS item (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      price FLOAT,
      category TEXT)')

    db.execute('CREATE TABLE IF NOT EXISTS user (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      email TEXT NOT NULL,
      password TEXT NOT NULL,
      type TEXT NOT NULL)')
      
    db.execute('CREATE TABLE IF NOT EXISTS cart (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id FLOAT,
      item_id FLOAT)')
  end

  def self.populate
    db.execute('INSERT INTO item (name, description, category, price) VALUES ("grunka", "grön och går att äta", "grönsak", 10)')
    db.execute('INSERT INTO item (name, description, category, price) VALUES ("grön borr", "grön och kan borra", "grön sak",  20)')
    db.execute('INSERT INTO item (name, description, category, price) VALUES ("buske", "grön och typ buskig", "grönska", 30)')

    db.execute('INSERT INTO user (username, email, password, type) VALUES ("Guest", "", "", "guest")')

  end



  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/item.sqlite')
    @db.results_as_hash = true
    @db
  end

end

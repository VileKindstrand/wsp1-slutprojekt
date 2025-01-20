require 'sqlite3'

class Seeder

  def self.seed!
    ####################item######################
    db.execute('DROP TABLE IF EXISTS item;')
    db.execute('CREATE TABLE IF NOT EXISTS item (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      description TEXT,
      price FLOAT,
      category TEXT)')
    db.execute('INSERT INTO item (name, description, category, price) VALUES ("grunka", "grön och går att äta", "grönsak", 10)')
    db.execute('INSERT INTO item (name, description, category, price) VALUES ("grön borr", "grön och kan borra", "grön sak",  20)')
    db.execute('INSERT INTO item (name, description, category, price) VALUES ("buske", "grön och typ buskig", "grönska", 30)')
    ##################rate#####################
  end


  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/item.sqlite')
    @db.results_as_hash = true
    @db
  end

end

require_relative "../config/environment.rb"
require "pry"


class Student

  attr_accessor :name, :grade
  attr_reader :id

  DB = {:conn => SQLite3::Database.new("db/students.db")}

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create(name, grade)
    new_student = self.new(name, grade)
    new_student.save
  end

  def self.new_from_db(row)
    new_stud = self.new(row[1],row[2],row[0])
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    unless @id
      sql_insert = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?,?)
      SQL

      DB[:conn].execute(sql_insert, self.name, self.grade)

      sql_get_last_id = <<-SQL
        SELECT last_insert_rowid() FROM students
      SQL

      @id = DB[:conn].execute(sql_get_last_id)[0][0]
    else
      self.update
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE students.name = ?
    SQL

    self.new_from_db(DB[:conn].execute(sql,name).flatten)
  end

  def update
    sql_update = <<-SQL
      UPDATE students
      SET (name , grade) = (?, ?)
      WHERE students.id = ?
    SQL

    DB[:conn].execute(sql_update, self.name, self.grade, self.id)

  end




end

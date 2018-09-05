require 'sqlite3'
require 'singleton'


class QuestionsDatabase < SQLite3::Database
  include Singleton
  
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Users
  attr_reader :fname, :lname, :name, :id
  
  def initialize(options)
    @fname = options['fname']
    @lname = options['lname']
    @name = "#{fname} #{lname}"
    @id = options['id']
  end
  
  def authored_replies
    Replies.find_by_user_id(@id)
  end
  
  def authored_questions 
    arr = Questions.find_by_author_id(@id)
  end
  
  def self.find_by_id(id)
    users = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      users
    WHERE
      id = ?
    SQL
    return nil if users.empty?
    Users.new(users.first)
  end
  
  def self.find_by_name(fname, lname)
    users = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
      fname = ? AND lname = ?
    SQL
    return nil if users.empty?
    Users.new(users.first)
    # users.map { |user| User.new(user) }
  end
end

class Questions
  def self.find_by_author_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      questions
    WHERE
      user_id = ?
    SQL
    return nil if results.empty?
    results.map { |result| Questions.new(result) }
  end
  
  def self.find_by_id(id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM questions WHERE id = ?
    SQL
    return nil if questions.empty?
    Questions.new(questions.first)
  end
  
  def self.find_by_title(title)
    titles = QuestionsDatabase.instance.execute(<<-SQL, title)
      SELECT * FROM questions WHERE title = ? 
    SQL
    return nil if titles.empty?
    titles.map {|title| Questions.new(title)}
    
  end
  
  attr_reader :title, :body, :user_id, :id
    
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end
  
  def author
    user = Users.find_by_id(@user_id)
    user.name
  end
  
  def replies
    Replies.find_by_user_id(@user_id)
  end
end

class Replies
  def self.find_by_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      replies
    WHERE
      user_id = ?
    SQL
    return nil if results.empty?
    results.map { |result| Replies.new(result) }
  end
  
  def self.find_by_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      replies
    WHERE
      question_id = ?
    SQL
    return nil if results.empty?
    results.map { |result| Replies.new(result) }
  end
  
  def self.find_by_id(id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM replies WHERE id = ?
    SQL
    return nil if replies.empty?
    Replies.new(replies.first)
  end
  
  attr_reader :id, :question_id, :parent_reply, :user_id, :body
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply = options['parent_reply']
    @user_id = options['user_id']
    @body = options['body']
  end 
  
  def author 
    Users.find_by_id(@user_id)
  end 
  
  def question 
    Questions.find_by_id(@question_id)
  end 
  
  def parent_reply
    result = Replies.find_by_id(@parent_reply)
    result.nil? ? "This reply was to an original question" : result
  end 
  
  def child_replies 
    QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM replies WHERE parent_reply = ?
    SQL
        
  end 
end

class QuestionFollows
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM question_follows WHERE id = ?
    SQL
    return nil if results.empty?
    QuestionFollows.new(results.first)
  end
  
  def self.followers_for_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      users
    JOIN
      questions
    ON
      questions.user_id = users.id
    JOIN
      replies
    ON
      replies.user_id = users.id
    WHERE
      questions.id = ? OR replies.question_id = ?
    SQL
    result
  end
  
  def self.followed_questions_for_user_id(user_id)
    
  end
  
  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
  
end

class QuestionLikes
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM question_likes WHERE id = ?
    SQL
    return nil if results.empty?
    Questions.new(results.first)
  end
  
  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end 
end
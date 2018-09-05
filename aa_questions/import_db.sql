DROP TABLE IF EXISTS users;
DROP TABLE if exists questions;
DROP TABLE if exists question_follows;
DROP TABLE if exists replies;
DROP TABLE if exists question_likes;

PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,-- foreign key
  parent_reply INTEGER,-- foreign key
  user_id INTEGER NOT NULL,-- foreign key
  body TEXT NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (parent_reply) REFERENCES replies(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id) 
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Eric', 'Lopez'),
  ('Brett', 'Kalbacher');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('Class Start Time', 'What time do we start class?', (SELECT id FROM users WHERE fname = "Eric" AND lname = "Lopez")),
  ('Second Question', 'What''s for lunch?', (SELECT id FROM users WHERE fname = "Eric" AND lname = "Lopez")),
  ('Happy Hour?', 'I really hope that there are some extra Lagunitas!!', (SELECT id FROM users WHERE fname = 'Brett' AND lname = 'Kalbacher'));
  
INSERT INTO 
  replies (question_id, parent_reply, user_id, body)
VALUES 
  ((SELECT id FROM questions WHERE title = 'Class Start Time'), NULL, (SELECT id FROM users WHERE fname = "Eric" AND lname = "Lopez"), 'It starts at 9am!!'),
  ((SELECT id FROM questions WHERE title = 'Class Start Time'), NULL, (SELECT id FROM users WHERE fname = "Eric" AND lname = "Lopez"), 'Oh Wait I think it''s at 10 LOL'),
  ((SELECT id FROM questions WHERE title = 'Class Start Time'), 2, (SELECT id FROM users WHERE fname = "Brett" AND lname = "Kalbacher"), 'I see what you did there, you sneaky dude, you!');
    

  INSERT INTO
    question_likes (user_id, question_id)
  VALUES 
    ((SELECT id FROM users WHERE fname = 'Brett' AND lname = 'Kalbacher'),(SELECT id FROM questions WHERE title = 'Class Start Time'));
    
  
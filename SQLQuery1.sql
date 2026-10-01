CREATE TABLE bot_sessions (
    session_id VARCHAR(50) PRIMARY KEY,
    user_id INT NOT NULL,
    platform VARCHAR(20) DEFAULT 'web',
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE chat_messages (
    message_id INT IDENTITY(1,1) PRIMARY KEY,
    session_id VARCHAR(50) FOREIGN KEY REFERENCES bot_sessions(session_id),
    sender VARCHAR(10) CHECK (sender IN ('user', 'bot')),
    message_text NVARCHAR(MAX) NOT NULL,
    sent_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE response_evaluations (
    eval_id INT IDENTITY(1,1) PRIMARY KEY,
    message_id INT FOREIGN KEY REFERENCES chat_messages(message_id),
    score INT CHECK (score BETWEEN 0 AND 100),
    is_safe BIT DEFAULT 1,
    evaluated_at DATETIME DEFAULT GETDATE()
);

INSERT INTO bot_sessions (session_id, user_id, platform) 
VALUES ('sess_101', 5501, 'mobile');

INSERT INTO chat_messages (session_id, sender, message_text)
VALUES 
    ('sess_101', 'user', N'გამარჯობა, დახმარება მჭირდება'),
    ('sess_101', 'bot', N'გამარჯობა! რით შემიძლია დაგეხმაროთ?');

INSERT INTO response_evaluations (message_id, score, is_safe)
VALUES (2, 95, 1);
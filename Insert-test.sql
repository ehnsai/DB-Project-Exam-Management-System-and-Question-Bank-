INSERT INTO Roles (RoleName, Description)
VALUES
(N'Admin', N'System Administrator'),
(N'Instructor', N'Exam Creator and Teacher'),
(N'Student', N'Exam Participant'),
(N'Assistant', N'Exam Assistant'),
(N'Evaluator', N'Answer Evaluator');
GO

INSERT INTO Users
(
    RoleID,
    FirstName,
    LastName,
    NationalCode,
    Username,
    Email,
    Password,
    PhoneNO,
    AcademicDegree,
    HireDate
)
VALUES
(1,N'Ali',N'Ahmadi','0012345678',N'ali.admin',
N'ali.admin@test.com','123456','09121234567',
N'Master','2020-01-10'),

(2,N'Reza',N'Mohammadi','0023456789',N'reza.teacher',
N'reza.teacher@test.com','123456','09122345678',
N'PhD','2019-05-15'),

(3,N'Sara',N'Karimi','0034567890',N'sara.student',
N'sara.student@test.com','123456','09123456789',
N'Bachelor','2022-09-01'),

(3,N'Maryam',N'Hosseini','0045678901',N'maryam.student',
N'maryam.student@test.com','123456','09124567890',
N'Bachelor','2023-02-20'),

(5,N'Hassan',N'Rezaei','0056789012',N'hassan.eval',
N'hassan.eval@test.com','123456','09125678901',
N'Master','2021-07-12');
GO

INSERT INTO Subjects
(
    SubjectCode,
    SubjectName,
    Description
)
VALUES
('DB101',N'Database',N'Database Concepts'),
('PRG101',N'Programming',N'Programming Fundamentals'),
('AI101',N'Artificial Intelligence',N'AI Basics'),
('NET101',N'Computer Networks',N'Network Concepts'),
('SE101',N'Software Engineering',N'Software Development');
GO

INSERT INTO QuestionCategories
(
    SubjectID,
    CategoryName,
    Description
)
VALUES
(1,N'SQL',N'SQL Questions'),
(1,N'Database Design',N'ER and Normalization'),
(2,N'CSharp',N'C# Programming'),
(3,N'Machine Learning',N'ML Questions'),
(4,N'TCP/IP',N'Network Protocols');
GO

INSERT INTO QuestionTypes
(
    TypeName
)
VALUES
(N'Multiple Choice'),
(N'True/False'),
(N'Essay'),
(N'Short Answer'),
(N'Fill Blank');
GO

INSERT INTO DifficultyLevels
(
    LevelName,
    LevelOrder
)
VALUES
(N'Easy',1),
(N'Medium',2),
(N'Hard',3),
(N'Very Hard',4),
(N'Expert',5);
GO

INSERT INTO Tags
(
    TagName
)
VALUES
(N'SQL'),
(N'Normalization'),
(N'Programming'),
(N'Algorithm'),
(N'Network');
GO

INSERT INTO Questions
(
    CategoryID,
    TypeID,
    LevelID,
    CreatedBy,
    QuestionText,
    DefaultScore,
    CorrectAnswer,
    Explanation
)
VALUES

(1,1,1,2,
N'Which command is used to retrieve data from database?',
2,
N'SELECT',
N'SELECT statement retrieves data from tables.'),

(2,3,2,2,
N'Explain database normalization and its advantages.',
5,
NULL,
N'Normalization reduces data redundancy.'),

(3,1,2,2,
N'Which keyword is used to create a class in C#?',
2,
N'class',
N'class keyword defines a new class.'),

(4,2,3,2,
N'Machine learning is a subset of Artificial Intelligence.',
1,
N'True',
N'ML is part of AI.'),

(5,4,1,2,
N'What protocol is responsible for reliable communication?',
2,
N'TCP',
N'TCP provides reliable transmission.');
GO

INSERT INTO QuestionOptions
(
    QuestionID,
    OptionText,
    IsCorrect,
    DisplayOrder
)
VALUES

-- Question 1
(1,N'SELECT',1,1),
(1,N'UPDATE',0,2),
(1,N'DELETE',0,3),
(1,N'INSERT',0,4),

-- Question 3
(3,N'class',1,1),
(3,N'function',0,2),
(3,N'method',0,3),
(3,N'object',0,4),

-- Question 4
(4,N'True',1,1),
(4,N'False',0,2),

-- Question 5
(5,N'TCP',1,1),
(5,N'UDP',0,2);
GO

INSERT INTO QuestionAttachments
(
    QuestionID,
    FileName,
    FilePath,
    FileType
)
VALUES

(1,
N'sql_diagram.png',
N'/files/sql_diagram.png',
N'PNG'),

(2,
N'normalization.pdf',
N'/files/normalization.pdf',
N'PDF'),

(3,
N'csharp_class.docx',
N'/files/csharp_class.docx',
N'DOCX'),

(4,
N'ml_intro.pdf',
N'/files/ml_intro.pdf',
N'PDF'),

(5,
N'tcp_protocol.png',
N'/files/tcp_protocol.png',
N'PNG');

GO

INSERT INTO QuestionTags
(
    QuestionID,
    TagID
)
VALUES

(1,1),
(2,2),
(3,3),
(4,4),
(5,5);

GO

INSERT INTO ExamTypes
(
    TypeName,
    Description
)
VALUES

(N'Midterm',
N'Midterm Examination'),

(N'Final',
N'Final Examination'),

(N'Quiz',
N'Short Quiz'),

(N'Practice',
N'Practice Test'),

(N'Online',
N'Online Assessment');

GO

INSERT INTO Exams
(
    SubjectID,
    ExamTypeID,
    CreatedBy,
    Title,
    DurationMinutes,
    PassingScore,
    HasNegativeMarking,
    IsRandomized,
    StartTime,
    EndTime,
    Description
)
VALUES

(1,
1,
2,
N'Database Midterm Exam',
60,
10,
1,
0,
DATEADD(HOUR,-1,GETDATE()),
DATEADD(HOUR,2,GETDATE()),
N'SQL and Database concepts'),

(2,
2,
2,
N'CSharp Final Exam',
90,
12,
0,
0,
DATEADD(DAY,-1,GETDATE()),
DATEADD(DAY,1,GETDATE()),
N'C# programming final exam'),

(3,
3,
2,
N'AI Quiz',
30,
5,
0,
0,
DATEADD(DAY,-2,GETDATE()),
DATEADD(DAY,2,GETDATE()),
N'Artificial Intelligence quiz'),

(4,
4,
2,
N'Network Practice Test',
45,
8,
1,
1,
DATEADD(DAY,1,GETDATE()),
DATEADD(DAY,3,GETDATE()),
N'TCP/IP practice exam'),

(5,
5,
2,
N'Software Engineering Online Exam',
60,
10,
0,
0,
DATEADD(DAY,-3,GETDATE()),
DATEADD(DAY,3,GETDATE()),
N'Software engineering exam');

GO

INSERT INTO ExamQuestions
(
    ExamID,
    QuestionID,
    QuestionScore,
    NegativeScore,
    DisplayOrder
)
VALUES

(1,
1,
2,
0.5,
1),

(2,
3,
2,
0,
1),

(3,
4,
1,
0,
1),

(4,
5,
2,
0.5,
1),

(5,
2,
5,
0,
1);

GO

INSERT INTO ExamParticipants
(
    ExamID,
    StudentID,
    Status,
    StartTime,
    SubmitTime,
    TotalScore,
    IsPassed,
    GradedBy,
    GradedAt
)
VALUES

(1,
3,
'Graded',
DATEADD(MINUTE,-50,GETDATE()),
DATEADD(MINUTE,-10,GETDATE()),
2,
0,
5,
GETDATE()),


(1,
4,
'Submitted',
DATEADD(MINUTE,-40,GETDATE()),
GETDATE(),
1,
0,
NULL,
NULL),


(2,
3,
'Graded',
DATEADD(DAY,-1,GETDATE()),
DATEADD(DAY,-1,GETDATE()),
15,
1,
5,
GETDATE()),


(3,
4,
'InProgress',
GETDATE(),
NULL,
NULL,
NULL,
NULL,
NULL),


(5,
3,
'Registered',
NULL,
NULL,
NULL,
NULL,
NULL,
NULL);

GO

INSERT INTO StudentAnswers
(
    ParticipantID,
    ExamQuestionID,
    SelectedOptionID,
    TextAnswer,
    IsCorrect,
    Score
)
VALUES


(1,
1,
1,
NULL,
1,
2),


(2,
1,
2,
NULL,
0,
-0.5),


(3,
2,
5,
NULL,
1,
2),


(4,
4,
10,
NULL,
1,
2),


(5,
5,
NULL,
N'Normalization reduces redundancy',
NULL,
NULL);

GO

INSERT INTO ExamSessions
(
    ParticipantID,
    LoginTime,
    LogoutTime,
    DisconnectCount
)
VALUES

(1,
DATEADD(MINUTE,-60,GETDATE()),
DATEADD(MINUTE,-5,GETDATE()),
0),


(2,
DATEADD(MINUTE,-50,GETDATE()),
GETDATE(),
1),


(3,
DATEADD(DAY,-1,GETDATE()),
DATEADD(DAY,-1,GETDATE()),
0),


(4,
GETDATE(),
NULL,
2),


(5,
GETDATE(),
NULL,
0);

GO


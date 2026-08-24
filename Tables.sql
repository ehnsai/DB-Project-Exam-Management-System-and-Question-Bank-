DROP TABLE IF EXISTS AuditLogs;
DROP TABLE IF EXISTS ExamSessions;
DROP TABLE IF EXISTS StudentAnswers;
DROP TABLE IF EXISTS ExamParticipants;
DROP TABLE IF EXISTS ExamQuestions;
DROP TABLE IF EXISTS Exams;
DROP TABLE IF EXISTS ExamTypes;
DROP TABLE IF EXISTS QuestionTags;
DROP TABLE IF EXISTS QuestionAttachments;
DROP TABLE IF EXISTS QuestionOptions;
DROP TABLE IF EXISTS Questions;
DROP TABLE IF EXISTS Tags;
DROP TABLE IF EXISTS DifficultyLevels;
DROP TABLE IF EXISTS QuestionTypes;
DROP TABLE IF EXISTS QuestionCategories;
DROP TABLE IF EXISTS Subjects;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Roles;
GO




CREATE TABLE Roles
(
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL
);

CREATE TABLE Users
(
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    RoleID INT NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    NationalCode VARCHAR(10) NOT NULL UNIQUE,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Password NVARCHAR(100) NOT NULL,
    PhoneNO VARCHAR(15) NULL,
    AcademicDegree NVARCHAR(30) NULL,
    HireDate DATE NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID),

    CONSTRAINT CHK_Users_NationalCode_Len CHECK (LEN(NationalCode) = 10),
    CONSTRAINT CHK_Users_NationalCode_Digits CHECK (NationalCode NOT LIKE '%[^0-9]%'),
    CONSTRAINT CHK_Users_Email_Format CHECK (Email LIKE '%_@_%._%'),
    CONSTRAINT CHK_Users_Phone_Len CHECK (PhoneNO IS NULL OR LEN(PhoneNO) >= 10),
    CONSTRAINT CHK_Users_Phone_Digits CHECK (PhoneNO IS NULL OR PhoneNO NOT LIKE '%[^0-9]%')
);

CREATE TABLE Subjects
(
    SubjectID INT IDENTITY(1,1) PRIMARY KEY,
    SubjectCode VARCHAR(20) NOT NULL UNIQUE,
    SubjectName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(500) NULL
);

CREATE TABLE QuestionCategories
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    SubjectID INT NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,

    FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID),
    CONSTRAINT UQ_Category UNIQUE (SubjectID, CategoryName)
);

CREATE TABLE QuestionTypes
(
    TypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE DifficultyLevels
(
    LevelID INT IDENTITY(1,1) PRIMARY KEY,
    LevelName NVARCHAR(50) NOT NULL UNIQUE,
    LevelOrder TINYINT NOT NULL UNIQUE
);

CREATE TABLE Tags
(
    TagID INT IDENTITY(1,1) PRIMARY KEY,
    TagName NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Questions
(
    QuestionID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    TypeID INT NOT NULL,
    LevelID INT NOT NULL,
    CreatedBy INT NOT NULL,
    QuestionText NVARCHAR(MAX) NOT NULL,
    DefaultScore DECIMAL(5,2) NOT NULL DEFAULT 1,
    CorrectAnswer NVARCHAR(500) NULL,
    Explanation NVARCHAR(MAX) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    FOREIGN KEY (CategoryID) REFERENCES QuestionCategories(CategoryID),
    FOREIGN KEY (TypeID) REFERENCES QuestionTypes(TypeID),
    FOREIGN KEY (LevelID) REFERENCES DifficultyLevels(LevelID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),

    CONSTRAINT CK_QuestionScore CHECK (DefaultScore > 0)
);

CREATE TABLE QuestionOptions
(
    OptionID INT IDENTITY(1,1) PRIMARY KEY,
    QuestionID INT NOT NULL,
    OptionText NVARCHAR(1000) NOT NULL,
    IsCorrect BIT NOT NULL DEFAULT 0,
    DisplayOrder TINYINT NOT NULL,

    FOREIGN KEY (QuestionID) REFERENCES Questions(QuestionID) ON DELETE CASCADE,

    CONSTRAINT UQ_QuestionOption UNIQUE (QuestionID, DisplayOrder)
);

CREATE TABLE QuestionAttachments
(
    AttachmentID INT IDENTITY(1,1) PRIMARY KEY,
    QuestionID INT NOT NULL,
    FileName NVARCHAR(255) NOT NULL,
    FilePath NVARCHAR(500) NOT NULL,
    FileType NVARCHAR(50) NULL,
    UploadedAt DATETIME NOT NULL DEFAULT GETDATE(),

    FOREIGN KEY (QuestionID) REFERENCES Questions(QuestionID) ON DELETE CASCADE
);

CREATE TABLE QuestionTags
(
    QuestionID INT NOT NULL,
    TagID INT NOT NULL,

    PRIMARY KEY (QuestionID, TagID),

    FOREIGN KEY (QuestionID) REFERENCES Questions(QuestionID) ON DELETE CASCADE,
    FOREIGN KEY (TagID) REFERENCES Tags(TagID) ON DELETE CASCADE
);

CREATE TABLE ExamTypes
(
    ExamTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL
);

CREATE TABLE Exams
(
    ExamID INT IDENTITY(1,1) PRIMARY KEY,
    SubjectID INT NOT NULL,
    ExamTypeID INT NOT NULL,
    CreatedBy INT NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    DurationMinutes INT NOT NULL,
    TotalScore DECIMAL(6,2) NULL,
    PassingScore DECIMAL(6,2) NOT NULL,
    HasNegativeMarking BIT NOT NULL DEFAULT 0,
    IsRandomized BIT NOT NULL DEFAULT 0,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    Description NVARCHAR(MAX) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID),
    FOREIGN KEY (ExamTypeID) REFERENCES ExamTypes(ExamTypeID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),

    CONSTRAINT CK_ExamDuration CHECK (DurationMinutes > 0),
    CONSTRAINT CK_ExamTime CHECK (EndTime > StartTime),
    CONSTRAINT CK_PassingScore CHECK (PassingScore >= 0)
);

CREATE TABLE ExamQuestions
(
    ExamQuestionID INT IDENTITY(1,1) PRIMARY KEY,
    ExamID INT NOT NULL,
    QuestionID INT NOT NULL,
    QuestionScore DECIMAL(5,2) NOT NULL,
    NegativeScore DECIMAL(5,2) NOT NULL DEFAULT 0,
    DisplayOrder INT NOT NULL,

    FOREIGN KEY (ExamID) REFERENCES Exams(ExamID) ON DELETE CASCADE,
    FOREIGN KEY (QuestionID) REFERENCES Questions(QuestionID),

    CONSTRAINT UQ_ExamQuestion UNIQUE (ExamID, QuestionID),
    CONSTRAINT UQ_ExamOrder UNIQUE (ExamID, DisplayOrder),
    CONSTRAINT CK_ExamQuestionScore CHECK (QuestionScore > 0),
    CONSTRAINT CK_NegativeScore CHECK (NegativeScore >= 0)
);

CREATE TABLE ExamParticipants
(
    ParticipantID INT IDENTITY(1,1) PRIMARY KEY,
    ExamID INT NOT NULL,
    StudentID INT NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Registered',
    StartTime DATETIME NULL,
    SubmitTime DATETIME NULL,
    TotalScore DECIMAL(6,2) NULL,
    IsPassed BIT NULL,
    GradedBy INT NULL,
    GradedAt DATETIME NULL,

    FOREIGN KEY (ExamID) REFERENCES Exams(ExamID) ON DELETE CASCADE,
    FOREIGN KEY (StudentID) REFERENCES Users(UserID),
    FOREIGN KEY (GradedBy) REFERENCES Users(UserID),

    CONSTRAINT UQ_ExamParticipant UNIQUE (ExamID, StudentID),
    CONSTRAINT CK_ExamParticipantStatus CHECK (Status IN ('Registered','InProgress','Submitted','Graded'))
);

CREATE TABLE StudentAnswers
(
    AnswerID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    ExamQuestionID INT NOT NULL,
    SelectedOptionID INT NULL,
    TextAnswer NVARCHAR(MAX) NULL,
    IsCorrect BIT NULL,
    Score DECIMAL(5,2) NULL,
    AnsweredAt DATETIME NOT NULL DEFAULT GETDATE(),

    FOREIGN KEY (ParticipantID) REFERENCES ExamParticipants(ParticipantID) ON DELETE CASCADE,
    FOREIGN KEY (ExamQuestionID) REFERENCES ExamQuestions(ExamQuestionID),
    FOREIGN KEY (SelectedOptionID) REFERENCES QuestionOptions(OptionID),

    CONSTRAINT UQ_StudentAnswer UNIQUE (ParticipantID, ExamQuestionID)
);

CREATE TABLE ExamSessions
(
    SessionID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    LoginTime DATETIME NOT NULL DEFAULT GETDATE(),
    LogoutTime DATETIME NULL,
    DisconnectCount INT NOT NULL DEFAULT 0,

    FOREIGN KEY (ParticipantID) REFERENCES ExamParticipants(ParticipantID) ON DELETE CASCADE,

    CONSTRAINT CK_DisconnectCount CHECK (DisconnectCount >= 0)
);

CREATE TABLE AuditLogs
(
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(100) NOT NULL,
    Operation NVARCHAR(10) NOT NULL,
    RecordID INT NULL,
    UserID INT NULL,
    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,
    LogDate DATETIME NOT NULL DEFAULT GETDATE(),

    FOREIGN KEY (UserID) REFERENCES Users(UserID),

    CONSTRAINT CK_AuditOperation CHECK (Operation IN ('INSERT','UPDATE','DELETE'))
);
GO
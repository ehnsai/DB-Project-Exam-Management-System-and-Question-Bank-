--Procedure 1 : pro_StartExam

DECLARE @ParticipantID INT;

EXEC pro_StartExam
    @ExamID=1,
    @StudentID=3,
    @ParticipantID=@ParticipantID OUTPUT;

SELECT @ParticipantID AS ParticipantID;

SELECT *
FROM ExamParticipants
WHERE ParticipantID=@ParticipantID;

SELECT *
FROM ExamSessions
WHERE ParticipantID=@ParticipantID;
GO




--Procedure 2 : pro_SaveStudentAnswer

EXEC pro_SaveStudentAnswer
    @ParticipantID=1,
    @ExamQuestionID=1,
    @SelectedOptionID=1;

SELECT *
FROM StudentAnswers
WHERE ParticipantID=1;
GO



--Procedure 3 : pro_SubmitExam

EXEC pro_SubmitExam
    @ParticipantID=1;

SELECT *
FROM ExamParticipants
WHERE ParticipantID=1;

SELECT *
FROM StudentAnswers
WHERE ParticipantID=1;
GO



--Procedure 4 : pro_GradeEssayQuestion

EXEC pro_GradeEssayQuestion
    @AnswerID = 5,
    @Score = 5,
    @IsCorrect = 1,
    @GraderUserID = 5;

SELECT *
FROM StudentAnswers
WHERE AnswerID = 5;

SELECT *
FROM ExamParticipants
WHERE ParticipantID = (SELECT ParticipantID FROM StudentAnswers WHERE AnswerID = 5);
GO


--Procedure 5 : pro_CreateRandomExam

EXEC pro_CreateRandomExam
    @SubjectID=1,
    @LevelID=2,
    @CreatedBy=2,
    @ExamTitle='Random Database Exam',
    @DurationMinutes=90,
    @PassingScore=12,
    @QuestionCount=5;

SELECT *
FROM Exams
ORDER BY ExamID DESC;

SELECT *
FROM ExamQuestions
WHERE ExamID=
(
    SELECT MAX(ExamID)
    FROM Exams
);
GO



--Procedure 6 : pro_AddQuestionToExam

EXEC pro_AddQuestionToExam
    @ExamID=1,
    @QuestionText='What is a Clustered Index?',
    @CategoryID=1,
    @TypeID=3,
    @LevelID=2,
    @CreatedBy=2,
    @QuestionScore=4,
    @NegativeScore=0;

SELECT *
FROM Questions
ORDER BY QuestionID DESC;

SELECT *
FROM ExamQuestions
WHERE ExamID=1
ORDER BY DisplayOrder;
GO
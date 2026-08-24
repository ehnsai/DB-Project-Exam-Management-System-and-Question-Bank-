DROP VIEW view_QuestionDetails;
GO

DROP VIEW view_ExamSummary;
GO

DROP VIEW view_StudentExamResults;
GO

DROP VIEW view_ActiveExams;
GO

DROP VIEW view_ExamQuestionsList;
GO

DROP VIEW view_StudentAnswerDetails;
GO

DROP VIEW view_QuestionSuccessRate;
GO

DROP VIEW view_ExamPerformanceSummary;
GO







CREATE VIEW view_QuestionDetails
AS
SELECT q.QuestionID, q.QuestionText, qt.TypeName AS QuestionType, dl.LevelName AS DifficultyLevel, qc.CategoryName,
    s.SubjectName, u.FirstName + ' ' + u.LastName AS CreatedBy, q.DefaultScore, q.IsActive, q.CreatedAt
FROM Questions q 
JOIN QuestionTypes qt ON q.TypeID = qt.TypeID
JOIN DifficultyLevels dl ON q.LevelID = dl.LevelID
JOIN QuestionCategories qc ON q.CategoryID = qc.CategoryID
JOIN Subjects s ON qc.SubjectID = s.SubjectID
JOIN Users u ON q.CreatedBy = u.UserID;
GO

CREATE VIEW view_ExamSummary
AS
SELECT e.ExamID, e.Title, et.TypeName AS ExamType, s.SubjectName, u.FirstName + ' ' + u.LastName AS CreatedBy,
    e.DurationMinutes, e.TotalScore, e.PassingScore, e.StartTime, e.EndTime, e.IsActive,
    COUNT(DISTINCT eq.QuestionID) AS TotalQuestions,
    COUNT(DISTINCT ep.ParticipantID) AS TotalParticipants
FROM Exams e
JOIN ExamTypes et ON e.ExamTypeID = et.ExamTypeID
JOIN Subjects s ON e.SubjectID = s.SubjectID
JOIN Users u ON e.CreatedBy = u.UserID
LEFT JOIN ExamQuestions eq ON e.ExamID = eq.ExamID
LEFT JOIN ExamParticipants ep ON e.ExamID = ep.ExamID
GROUP BY e.ExamID, e.Title, et.TypeName, s.SubjectName, u.FirstName, u.LastName, e.DurationMinutes, e.TotalScore,
e.PassingScore, e.StartTime, e.EndTime, e.IsActive;
GO

CREATE VIEW view_StudentExamResults
AS
SELECT u.UserID AS StudentID, u.FirstName + ' ' + u.LastName AS StudentName, e.Title AS ExamTitle, s.SubjectName,
    et.TypeName AS ExamType, ep.TotalScore, e.PassingScore, ep.IsPassed, ep.SubmitTime
FROM ExamParticipants ep
JOIN Users u ON ep.StudentID = u.UserID
JOIN Exams e ON ep.ExamID = e.ExamID
JOIN Subjects s ON e.SubjectID = s.SubjectID
JOIN ExamTypes et ON e.ExamTypeID = et.ExamTypeID
WHERE ep.Status='Graded';
GO


CREATE VIEW view_ActiveExams
AS
SELECT e.ExamID, e.Title, s.SubjectName, et.TypeName AS ExamType, e.StartTime, e.EndTime, e.DurationMinutes,
    e.TotalScore, e.PassingScore
FROM Exams e
JOIN Subjects s ON e.SubjectID=s.SubjectID
JOIN ExamTypes et ON e.ExamTypeID=et.ExamTypeID
WHERE e.IsActive=1 AND GETDATE() BETWEEN e.StartTime AND e.EndTime;
GO

CREATE VIEW view_ExamQuestionsList
AS
SELECT eq.ExamQuestionID, e.Title AS ExamTitle, q.QuestionText, qt.TypeName AS QuestionType, dl.LevelName AS DifficultyLevel,
    eq.QuestionScore, eq.NegativeScore, eq.DisplayOrder
FROM ExamQuestions eq
JOIN Exams e ON eq.ExamID=e.ExamID
JOIN Questions q ON eq.QuestionID=q.QuestionID
JOIN QuestionTypes qt ON q.TypeID=qt.TypeID
JOIN DifficultyLevels dl ON q.LevelID=dl.LevelID;
GO

CREATE VIEW view_StudentAnswerDetails
AS
SELECT sa.AnswerID, e.Title AS ExamTitle, u.FirstName+' '+u.LastName AS StudentName, q.QuestionText, qt.TypeName,
    CASE
        WHEN qt.TypeName IN ('Multiple Choice','True/False')
        THEN qo.OptionText
        ELSE sa.TextAnswer
    END AS StudentAnswer, sa.IsCorrect, sa.Score, eq.QuestionScore, sa.AnsweredAt
FROM StudentAnswers sa
JOIN ExamParticipants ep ON sa.ParticipantID=ep.ParticipantID
JOIN Exams e ON ep.ExamID=e.ExamID
JOIN Users u ON ep.StudentID=u.UserID
JOIN ExamQuestions eq ON sa.ExamQuestionID=eq.ExamQuestionID
JOIN Questions q ON eq.QuestionID=q.QuestionID
JOIN QuestionTypes qt ON q.TypeID=qt.TypeID
LEFT JOIN QuestionOptions qo ON sa.SelectedOptionID=qo.OptionID;
GO

CREATE VIEW view_QuestionSuccessRate
AS
SELECT q.QuestionID, q.QuestionText, COUNT(sa.AnswerID) AS TotalAnswers, SUM(CASE WHEN sa.IsCorrect=1 THEN 1 ELSE 0 END) AS CorrectAnswers,
    CAST(SUM(CASE WHEN sa.IsCorrect=1 THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(sa.AnswerID),0) *100 AS SuccessRate
FROM Questions q
LEFT JOIN ExamQuestions eq ON q.QuestionID=eq.QuestionID
LEFT JOIN StudentAnswers sa ON eq.ExamQuestionID=sa.ExamQuestionID
GROUP BY q.QuestionID, q.QuestionText;
GO

CREATE VIEW view_ExamPerformanceSummary
AS
SELECT e.ExamID, e.Title, u.FirstName+' '+u.LastName AS InstructorName, COUNT(ep.ParticipantID) AS TotalParticipants,
    AVG(ep.TotalScore) AS AverageScore, MAX(ep.TotalScore) AS HighestScore, MIN(ep.TotalScore) AS LowestScore
FROM Exams e
JOIN Users u ON e.CreatedBy=u.UserID
LEFT JOIN ExamParticipants ep ON e.ExamID=ep.ExamID AND ep.Status='Graded'
GROUP BY e.ExamID, e.Title, u.FirstName, u.LastName;
GO



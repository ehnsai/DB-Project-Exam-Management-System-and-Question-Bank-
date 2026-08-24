SELECT *
FROM view_QuestionDetails;
GO

SELECT *
FROM view_ExamSummary;
GO

SELECT *
FROM view_StudentExamResults;
GO

SELECT *
FROM view_ActiveExams;
GO

SELECT *
FROM view_ExamQuestionsList;
GO

SELECT *
FROM view_StudentAnswerDetails;
GO

SELECT *
FROM view_QuestionSuccessRate;
GO

SELECT *
FROM view_ExamPerformanceSummary;
GO

SELECT *
FROM view_ExamSummary
WHERE ExamID = 1;
GO

SELECT *
FROM view_ExamQuestionsList
WHERE ExamTitle = 
(
    SELECT Title
    FROM Exams
    WHERE ExamID = 1
);
GO

SELECT *
FROM view_StudentExamResults
WHERE StudentID = 3;
GO

SELECT *
FROM view_QuestionSuccessRate
WHERE QuestionID = 1;
GO



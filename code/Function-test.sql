--Function 1 : func_CalculateExamScore

SELECT dbo.func_CalculateExamScore(1) AS TotalScore;
GO



--Function 2 : func_GetStudentAverage

SELECT dbo.func_GetStudentAverage(3) AS StudentAverage;
GO



--Function 3 : func_GetExamQuestionCount

SELECT dbo.func_GetExamQuestionCount(1) AS QuestionCount;
GO


--Function 4 : func_GetQuestionSuccessRate

SELECT dbo.func_GetQuestionSuccessRate(1) AS SuccessRate;
GO


--Function 5 : func_GetQuestionsForRandomExam

SELECT *
FROM dbo.func_GetQuestionsForRandomExam(1,1);
GO


--Function 6 : func_CanStudentTakeExam

SELECT dbo.func_CanStudentTakeExam(1,3) AS CanStudentTakeExam;
GO


--Function 7 : func_GetExamParticipantCount

SELECT dbo.func_GetExamParticipantCount(1) AS ParticipantCount;
GO



--Function 8 : func_GetExamAverage

SELECT dbo.func_GetExamAverage(1) AS AverageScore;
GO


--Function 9 : func_GetExamHighestScore

SELECT dbo.func_GetExamHighestScore(1) AS HighestScore;
GO


--Function 10 : func_GetExamRanking

SELECT *
FROM dbo.func_GetExamRanking(2);
GO

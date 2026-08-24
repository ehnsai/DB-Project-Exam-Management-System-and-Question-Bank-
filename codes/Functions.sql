DROP FUNCTION func_CalculateExamScore;
GO

DROP FUNCTION func_GetStudentAverage;
GO

DROP FUNCTION func_GetExamQuestionCount;
GO

DROP FUNCTION func_GetQuestionSuccessRate;
GO

DROP FUNCTION func_GetQuestionsForRandomExam;
GO

DROP FUNCTION func_CanStudentTakeExam;
GO

DROP FUNCTION func_GetExamParticipantCount;
GO

DROP FUNCTION func_GetExamAverage;
GO

DROP FUNCTION func_GetExamHighestScore;
GO

DROP FUNCTION func_GetExamRanking;
GO




CREATE FUNCTION func_CalculateExamScore (@ParticipantID INT)
RETURNS DECIMAL(6,2)
AS
BEGIN
    DECLARE @TotalScore DECIMAL(6,2);

    SELECT @TotalScore = ISNULL(SUM(Score),0)
    FROM StudentAnswers
    WHERE ParticipantID = @ParticipantID;

    RETURN @TotalScore;
END;
GO

CREATE FUNCTION func_GetStudentAverage (@StudentID INT)
RETURNS DECIMAL(6,2)
AS
BEGIN
    DECLARE @Average DECIMAL(6,2);

    SELECT @Average = AVG(TotalScore)
    FROM ExamParticipants
    WHERE StudentID = @StudentID AND Status = 'Graded' AND TotalScore IS NOT NULL;

    RETURN ISNULL(@Average,0);
END;
GO


CREATE FUNCTION func_GetExamQuestionCount (@ExamID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;

    SELECT @Count = COUNT(*)
    FROM ExamQuestions
    WHERE ExamID = @ExamID;

    RETURN ISNULL(@Count,0);
END;
GO


CREATE FUNCTION func_GetQuestionSuccessRate (@QuestionID INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @SuccessRate DECIMAL(5,2);
    DECLARE @TotalAnswers INT;
    DECLARE @CorrectAnswers INT;

    SELECT @TotalAnswers = COUNT(*), @CorrectAnswers = SUM(CASE WHEN sa.IsCorrect = 1 THEN 1 ELSE 0 END)
    FROM StudentAnswers sa
    JOIN ExamQuestions eq ON sa.ExamQuestionID = eq.ExamQuestionID
    WHERE eq.QuestionID = @QuestionID;

    IF @TotalAnswers > 0
        SET @SuccessRate = (CAST(@CorrectAnswers AS DECIMAL(5,2)) / @TotalAnswers) * 100;
    ELSE
        SET @SuccessRate = 0;

    RETURN @SuccessRate;
END;
GO


CREATE FUNCTION func_GetQuestionsForRandomExam (@CategoryID INT, @LevelID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT q.QuestionID, q.QuestionText, q.DefaultScore, qt.TypeName, dl.LevelName
    FROM Questions q
    JOIN QuestionTypes qt ON q.TypeID = qt.TypeID
    JOIN DifficultyLevels dl ON q.LevelID = dl.LevelID
    WHERE q.CategoryID = @CategoryID AND q.LevelID = @LevelID AND q.IsActive = 1
);
GO


CREATE FUNCTION func_CanStudentTakeExam (@ExamID INT, @StudentID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @CanTake BIT = 0;
    IF EXISTS
    (
        SELECT *
        FROM Exams
        WHERE ExamID = @ExamID AND IsActive = 1 AND GETDATE() BETWEEN StartTime AND EndTime
    )
    BEGIN
        IF NOT EXISTS
        (
            SELECT *
            FROM ExamParticipants
            WHERE ExamID = @ExamID AND StudentID = @StudentID AND Status IN ('InProgress','Submitted','Graded')
        )
        BEGIN
            SET @CanTake = 1;
        END
    END

    RETURN @CanTake;
END;
GO


CREATE FUNCTION func_GetExamParticipantCount (@ExamID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;

    SELECT @Count = COUNT(*)
    FROM ExamParticipants
    WHERE ExamID = @ExamID;

    RETURN ISNULL(@Count,0);
END;
GO


CREATE FUNCTION func_GetExamAverage (@ExamID INT)
RETURNS DECIMAL(6,2)
AS
BEGIN
    DECLARE @Average DECIMAL(6,2);

    SELECT @Average = AVG(TotalScore)
    FROM ExamParticipants
    WHERE ExamID = @ExamID AND Status = 'Graded';

    RETURN ISNULL(@Average,0);
END;
GO


CREATE FUNCTION func_GetExamHighestScore (@ExamID INT)
RETURNS DECIMAL(6,2)
AS
BEGIN
    DECLARE @HighestScore DECIMAL(6,2);

    SELECT @HighestScore = MAX(TotalScore)
    FROM ExamParticipants
    WHERE ExamID = @ExamID AND Status = 'Graded';

    RETURN ISNULL(@HighestScore,0);
END;
GO

CREATE FUNCTION func_GetExamRanking (@ExamID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT ep.ParticipantID, u.FirstName + ' ' + u.LastName AS StudentName, ep.TotalScore
    FROM ExamParticipants ep
    JOIN Users u ON ep.StudentID = u.UserID
    WHERE ep.ExamID = @ExamID AND ep.Status = 'Graded'
);
GO

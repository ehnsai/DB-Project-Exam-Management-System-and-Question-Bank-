DROP PROCEDURE pro_StartExam;
GO

DROP PROCEDURE pro_SaveStudentAnswer;
GO

DROP PROCEDURE pro_SubmitExam;
GO

DROP PROCEDURE pro_GradeEssayQuestion;
GO

DROP PROCEDURE pro_CreateRandomExam;
GO

DROP PROCEDURE pro_AddQuestionToExam;
GO




CREATE PROCEDURE pro_StartExam
    @ExamID INT, @StudentID INT, @ParticipantID INT OUTPUT
AS
BEGIN
    IF NOT EXISTS
    (
        SELECT *
        FROM Exams
        WHERE ExamID = @ExamID AND IsActive = 1 AND GETDATE() BETWEEN StartTime AND EndTime
    )
    BEGIN
        PRINT 'Exam is not Available.';
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT *
        FROM ExamParticipants
        WHERE ExamID = @ExamID AND StudentID = @StudentID
    )
    BEGIN
        INSERT INTO ExamParticipants (ExamID, StudentID, Status)
        VALUES(@ExamID, @StudentID, 'Registered');
    END;

    SELECT @ParticipantID = ParticipantID
    FROM ExamParticipants
    WHERE ExamID = @ExamID AND StudentID = @StudentID;

    UPDATE ExamParticipants
    SET
        Status = 'InProgress',
        StartTime = GETDATE()
    WHERE ParticipantID = @ParticipantID;

    INSERT INTO ExamSessions (ParticipantID, LoginTime, DisconnectCount)
    VALUES(@ParticipantID, GETDATE(),0);
END;
GO

CREATE PROCEDURE pro_SaveStudentAnswer
    @ParticipantID INT, @ExamQuestionID INT, @SelectedOptionID INT = NULL, @TextAnswer NVARCHAR(MAX) = NULL
AS
BEGIN
    IF EXISTS
    (
        SELECT *
        FROM StudentAnswers
        WHERE ParticipantID = @ParticipantID AND ExamQuestionID = @ExamQuestionID
    )
    BEGIN
        UPDATE StudentAnswers
        SET
            SelectedOptionID = @SelectedOptionID,
            TextAnswer = @TextAnswer,
            AnsweredAt = GETDATE()
        WHERE ParticipantID =@ParticipantID AND ExamQuestionID =@ExamQuestionID;
    END
    ELSE
    BEGIN
        INSERT INTO StudentAnswers (ParticipantID, ExamQuestionID, SelectedOptionID, TextAnswer, AnsweredAt)
        VALUES(@ParticipantID, @ExamQuestionID, @SelectedOptionID, @TextAnswer,GETDATE());
    END
END;
GO

CREATE PROCEDURE pro_SubmitExam
    @ParticipantID INT
AS
BEGIN
    UPDATE sa
    SET
        IsCorrect = CASE WHEN qo.IsCorrect= 1 THEN 1
		ELSE 0 
	END,
        Score = CASE
                WHEN qo.IsCorrect = 1 THEN eq.QuestionScore
                WHEN sa.SelectedOptionID IS NOT NULL THEN -eq.NegativeScore
                ELSE 0
              END
    FROM StudentAnswers sa
    JOIN ExamQuestions eq ON sa.ExamQuestionID=eq.ExamQuestionID
    JOIN QuestionOptions qo ON sa.SelectedOptionID=qo.OptionID
    WHERE sa.ParticipantID=@ParticipantID AND sa.SelectedOptionID IS NOT NULL;

    DECLARE @TotalScore DECIMAL(6,2);

    SET @TotalScore = dbo.func_CalculateExamScore(@ParticipantID);

    UPDATE ExamParticipants
    SET
        Status ='Submitted',
        SubmitTime = GETDATE(),
        TotalScore = @TotalScore,
        IsPassed=
        CASE
            WHEN @TotalScore>=(
                SELECT PassingScore
                FROM Exams
                WHERE ExamID=ExamParticipants.ExamID
            )
            THEN 1
            ELSE 0
        END
    WHERE ParticipantID=@ParticipantID;
END;
GO

CREATE PROCEDURE pro_GradeEssayQuestion
    @AnswerID INT, @Score DECIMAL(5,2), @IsCorrect BIT, @GraderUserID INT
AS
BEGIN
    UPDATE StudentAnswers
    SET Score = @Score, IsCorrect = @IsCorrect
    WHERE AnswerID=@AnswerID;

    DECLARE @ParticipantID INT;

    SELECT @ParticipantID =ParticipantID
    FROM StudentAnswers
    WHERE AnswerID =@AnswerID;

    DECLARE @NewTotalScore DECIMAL(6,2);

    SET @NewTotalScore=dbo.func_CalculateExamScore(@ParticipantID);

    UPDATE ExamParticipants
    SET
        TotalScore=@NewTotalScore,
        IsPassed=
        CASE
            WHEN @NewTotalScore>=(
                SELECT PassingScore
                FROM Exams
                WHERE ExamID = ExamParticipants.ExamID
            )
            THEN 1
            ELSE 0
        END,
        GradedBy = @GraderUserID,
        GradedAt = GETDATE(),
        Status='Graded'
    WHERE ParticipantID = @ParticipantID;
END;
GO

CREATE PROCEDURE pro_CreateRandomExam
	@SubjectID INT, @LevelID INT, @CreatedBy INT, @ExamTitle NVARCHAR(200), @DurationMinutes INT, @PassingScore DECIMAL(6,2),
    @QuestionCount INT
AS
BEGIN
    DECLARE @NewExamID INT;

    INSERT INTO Exams (SubjectID, ExamTypeID, CreatedBy, Title, DurationMinutes, PassingScore, HasNegativeMarking, IsRandomized, StartTime,EndTime)
    VALUES(@SubjectID,2,@CreatedBy,@ExamTitle, @DurationMinutes, @PassingScore, 0, 1, GETDATE(), DATEADD(HOUR,2,GETDATE()));

    SET @NewExamID = SCOPE_IDENTITY();

    INSERT INTO ExamQuestions (ExamID, QuestionID, QuestionScore, NegativeScore, DisplayOrder)
    SELECT TOP(@QuestionCount) @NewExamID, QuestionID, DefaultScore, 0,
        ROW_NUMBER() OVER(ORDER BY NEWID())
    FROM Questions
    WHERE CategoryID IN
    (
        SELECT CategoryID
        FROM QuestionCategories
        WHERE SubjectID=@SubjectID
    )
    AND LevelID=@LevelID AND IsActive=1
    ORDER BY NEWID();
END;
GO

CREATE PROCEDURE pro_AddQuestionToExam
    @ExamID INT, @QuestionText NVARCHAR(MAX), @CategoryID INT, @TypeID INT, @LevelID INT, 
    @CreatedBy INT, @QuestionScore DECIMAL(5,2), @NegativeScore DECIMAL(5,2)=0
AS
BEGIN
    DECLARE @QuestionID INT;

    INSERT INTO Questions (QuestionText, CategoryID, TypeID, LevelID, CreatedBy, DefaultScore)
    VALUES (@QuestionText, @CategoryID, @TypeID, @LevelID, @CreatedBy, @QuestionScore);

    SET @QuestionID=SCOPE_IDENTITY();

    IF EXISTS
    (
        SELECT *
        FROM ExamQuestions
        WHERE ExamID=@ExamID AND QuestionID=@QuestionID
    )
        RETURN;

    DECLARE @DisplayOrder INT;

    SELECT @DisplayOrder = ISNULL(MAX(DisplayOrder),0) + 1
    FROM ExamQuestions
    WHERE ExamID=@ExamID;

    INSERT INTO ExamQuestions (ExamID, QuestionID, QuestionScore, NegativeScore, DisplayOrder)
    VALUES (@ExamID, @QuestionID, @QuestionScore, @NegativeScore, @DisplayOrder);
END;
GO
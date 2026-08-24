DROP TRIGGER trg_LogQuestionChanges;
GO

DROP TRIGGER trg_UpdateExamTotalScore;
GO

DROP TRIGGER trg_PreventAnswerAfterSubmit;
GO





CREATE TRIGGER trg_LogQuestionChanges
ON Questions
AFTER INSERT , UPDATE , DELETE
AS
BEGIN
    IF EXISTS
    (
        SELECT *
        FROM inserted
    )
    AND EXISTS
    (
        SELECT *
        FROM deleted
    )
    BEGIN
        INSERT INTO AuditLogs (TableName, Operation, RecordID, UserID, OldValue, NewValue)
        SELECT 'Questions','UPDATE', d.QuestionID, i.CreatedBy, d.QuestionText, i.QuestionText
        FROM deleted d
        JOIN inserted i ON d.QuestionID=i.QuestionID;
    END

    ELSE IF EXISTS
    (
        SELECT *
        FROM inserted
    )
    BEGIN
        INSERT INTO AuditLogs (TableName, Operation, RecordID, UserID, OldValue, NewValue)
        SELECT 'Questions', 'INSERT', QuestionID, CreatedBy, NULL, QuestionText
        FROM inserted;
    END

    ELSE
    BEGIN
        INSERT INTO AuditLogs (TableName, Operation, RecordID, UserID, OldValue, NewValue)
        SELECT 'Questions', 'DELETE', QuestionID, CreatedBy, QuestionText, NULL
        FROM deleted;
    END
END;
GO

CREATE TRIGGER trg_UpdateExamTotalScore
ON ExamQuestions
AFTER INSERT , UPDATE, DELETE
AS
BEGIN
    DECLARE @ExamID INT;

    IF EXISTS
    (
        SELECT *
        FROM inserted
    )
        SELECT @ExamID=ExamID
        FROM inserted;
    ELSE
        SELECT @ExamID=ExamID
        FROM deleted;

    UPDATE Exams
    SET TotalScore=
    (
        SELECT ISNULL(SUM(QuestionScore),0)
        FROM ExamQuestions
        WHERE ExamID=@ExamID
    )
    WHERE ExamID=@ExamID;
END;
GO

CREATE TRIGGER trg_PreventAnswerAfterSubmit
ON StudentAnswers
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS
    (
        SELECT *
        FROM inserted i
        JOIN ExamParticipants ep ON i.ParticipantID=ep.ParticipantID
        WHERE ep.Status IN ('Submitted','Graded')
    )
    BEGIN
        RAISERROR('The exam has already been submitted.',16,1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

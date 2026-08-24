-- Test Trigger : trg_LogQuestionChanges

-- INSERT
INSERT INTO Questions
(
    CategoryID,
    TypeID,
    LevelID,
    CreatedBy,
    QuestionText,
    DefaultScore
)
VALUES
(
    1,
    1,
    1,
    1,
    N'Trigger Test Question',
    2
);

SELECT *
FROM AuditLogs
ORDER BY LogID DESC;


-- UPDATE
UPDATE Questions
SET QuestionText=N'Trigger Test Question Updated'
WHERE QuestionText=N'Trigger Test Question';

SELECT *
FROM AuditLogs
ORDER BY LogID DESC;


-- DELETE
DELETE FROM Questions
WHERE QuestionText=N'Trigger Test Question Updated';

SELECT *
FROM AuditLogs
ORDER BY LogID DESC;



-- Test Trigger : trg_UpdateExamTotalScore

SELECT ExamID,TotalScore
FROM Exams
WHERE ExamID=1;


INSERT INTO ExamQuestions
(
    ExamID,
    QuestionID,
    QuestionScore,
    NegativeScore,
    DisplayOrder
)
VALUES
(
    1,
    8,
    2,
    0,
    99
);

SELECT ExamID,TotalScore
FROM Exams
WHERE ExamID=1;


UPDATE ExamQuestions
SET QuestionScore=5
WHERE ExamID=1
AND QuestionID=8;

SELECT ExamID,TotalScore
FROM Exams
WHERE ExamID=1;


DELETE FROM ExamQuestions
WHERE ExamID=1
AND QuestionID=8;

SELECT ExamID,TotalScore
FROM Exams
WHERE ExamID=1;



-- Test Trigger : trg_PreventAnswerAfterSubmit

UPDATE ExamParticipants
SET Status='Submitted'
WHERE ParticipantID=1;


INSERT INTO StudentAnswers
(
    ParticipantID,
    ExamQuestionID,
    SelectedOptionID
)
VALUES
(
    1,
    1,
    1
);


UPDATE StudentAnswers
SET SelectedOptionID=2
WHERE ParticipantID=1
AND ExamQuestionID=1;


SELECT *
FROM StudentAnswers
WHERE ParticipantID=1;

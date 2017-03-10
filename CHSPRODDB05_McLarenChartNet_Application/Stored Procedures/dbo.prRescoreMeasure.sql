SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[prRescoreMeasure]
    @cScoringProc varchar(20)
AS 

--Runs through list of members associated with measure and reruns scoring procedure on each member-----------

-- HOW TO USE: exec prRescoreMeasure 'ScoreCDC' 
-- (Where "ScoreCDC" is the name of the scoring procedure for the measure to recore)
--------------------------------------------------------------------------------------------------------------

DECLARE @cCMD varchar(200),
    @iMemberID int 

DECLARE @TableName nvarchar(128);
DECLARE @SqlCmd nvarchar(max);

SET @TableName = '##RescoringMeasure_' + CONVERT(nvarchar(128), @@SPID);
SET @SqlCmd = 'CREATE TABLE ' + @TableName + '( ID int NOT NULL );'
EXEC (@SqlCmd);

SELECT  @iMemberID = MIN(memberid)
FROM    dbo.MemberMeasureSample mms
        INNER JOIN measure m ON mms.MeasureID = m.MeasureID
WHERE   ScoringProcedure = @cScoringProc


WHILE ISNULL(@iMemberID, 0) <> 0 
    BEGIN
        SET @cCMD = 'dbo.' + @cScoringProc + ' ' +
            CONVERT(varchar(10), @iMemberID)
        PRINT @cCMD
      
        EXEC(@cCMD)

        SELECT  @iMemberID = MIN(memberid)
        FROM    dbo.MemberMeasureSample mms
                INNER JOIN dbo.Measure m ON mms.MeasureID = m.MeasureID
        WHERE   ScoringProcedure = @cScoringProc AND
                memberid > @iMemberID

    END

IF OBJECT_ID('tempdb..' + @TableName) IS NOT NULL
	BEGIN
		SET @SqlCmd = 'DROP TABLE ' + @TableName;
		EXEC (@SqlCmd);
	END;
GO
GRANT EXECUTE ON  [dbo].[prRescoreMeasure] TO [Support]
GO

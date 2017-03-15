SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Travis Parker
-- Create date:	05/19/2016
-- Description:	populates the loopparent table
-- Usage:			
--		  EXECUTE dbo.spUpdateLoopParent
-- =============================================
CREATE PROC [dbo].[spUpdateLoopParent]
AS
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF OBJECT_ID('tempdb..#CompleteLoop') IS NOT NULL
        DROP TABLE #CompleteLoop;

    TRUNCATE TABLE dbo.LoopParent;

    SELECT  Id AS LoopID ,
            ParentLoopId ,
            NULL AS BaseParentLoopID
    INTO    #CompleteLoop
    FROM    Loop;

    UPDATE  #CompleteLoop
    SET     BaseParentLoopID = LoopID
    WHERE   ParentLoopId IS NULL;

    WHILE ( SELECT  COUNT(1)
            FROM    #CompleteLoop
            WHERE   BaseParentLoopID IS NULL
          ) > 0
        BEGIN

            UPDATE  c
            SET     BaseParentLoopID = l.Id
            FROM    #CompleteLoop AS c
                    INNER JOIN Loop AS l ON c.ParentLoopId = l.Id
            WHERE   c.BaseParentLoopID IS NULL
                    AND l.ParentLoopId IS NULL;

            UPDATE  c
            SET     ParentLoopId = l.ParentLoopId
            FROM    #CompleteLoop AS c
                    INNER JOIN Loop AS l ON c.ParentLoopId = l.Id
            WHERE   c.BaseParentLoopID IS NULL
                    AND l.ParentLoopId IS NOT NULL;
        END;

    INSERT  INTO dbo.LoopParent
            ( LoopID ,
              ParentLoopID
            )
            SELECT  LoopID ,
                    BaseParentLoopID
            FROM    #CompleteLoop;
GO

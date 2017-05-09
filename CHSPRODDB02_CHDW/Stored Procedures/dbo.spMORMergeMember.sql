SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	07/26/2016
-- Description:	merges the stage to dim for member
-- Usage:			
--		  EXECUTE dbo.spMORMergeMember
-- =============================================
CREATE PROC [dbo].[spMORMergeMember]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.Member AS t
        USING
            ( SELECT    CentauriMemberID ,
                        MAX(LastName) LastName ,
                        MAX(FirstName) FirstName ,
                        MAX(MiddleName) MiddleName ,
                        MAX(Gender) Gender ,
                        MAX(DOB) DOB
              FROM      stage.Member_MOR
		    GROUP BY CentauriMemberID
            ) AS s
        ON t.CentauriMemberID = s.CentauriMemberID
        WHEN MATCHED AND ( t.LastName <> s.LastName
                           OR t.FirstName <> s.FirstName
                           OR t.MiddleName <> s.MiddleName
                           OR t.Gender <> s.Gender
                           OR t.DOB <> s.DOB
                         ) THEN
            UPDATE SET
                    t.LastName = s.LastName ,
                    t.FirstName = s.FirstName ,
                    t.MiddleName = s.MiddleName ,
                    t.Gender = s.Gender ,
                    t.DOB = s.DOB ,
                    t.LastUpdate = GETDATE()--@CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriMemberID ,
                     LastName ,
                     FirstName ,
                     MiddleName ,
                     Gender ,
                     DOB
                   )
            VALUES ( s.CentauriMemberID ,
                     s.LastName ,
                     s.FirstName ,
                     s.MiddleName ,
                     s.Gender ,
                     s.DOB
                   );

    END;     
GO

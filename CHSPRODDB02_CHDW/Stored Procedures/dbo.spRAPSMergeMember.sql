SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Travis Parker
-- Create date:	06/11/2016
-- Description:	merges the stage to dim for member
-- Usage:			
--		  EXECUTE dbo.spRAPSMergeMember
-- =============================================
CREATE PROC [dbo].[spRAPSMergeMember]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.Member AS t
        USING
            ( SELECT    CentauriMemberID ,
                        LastName ,
                        FirstName ,
                        Gender ,
                        DOB
              FROM      stage.Member_RAPS
            ) AS s
        ON t.CentauriMemberID = s.CentauriMemberID
        --WHEN MATCHED AND ( t.LastName <> s.LastName
        --                   OR t.FirstName <> s.FirstName
        --                   OR t.Gender <> s.Gender
        --                   OR t.DOB <> s.DOB
        --                 ) THEN
        --    UPDATE SET
        --            t.LastName = s.LastName ,
        --            t.FirstName = s.FirstName ,
        --            t.Gender = s.Gender ,
        --            t.DOB = s.DOB ,
        --            t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriMemberID ,
                     LastName ,
                     FirstName ,
                     Gender ,
                     DOB
                   )
            VALUES ( CentauriMemberID ,
                     LastName ,
                     FirstName ,
                     Gender ,
                     DOB
                   );

    END;     
GO

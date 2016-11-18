SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/07/2016
-- Description:	merges the stage to dim for member for advance based on spOECMergeMembercode
-- Usage:			
--		  EXECUTE dbo.spadvMergeMember
-- =============================================
CREATE PROC [dbo].[spadvMergeMember]
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
                        CAST(YEAR(dob) AS VARCHAR)+RIGHT('0'+CAST(MONTH(dob) AS varchar),2)+RIGHT('0'+CAST(DAY(dob) AS varchar),2) AS DOB
              FROM      stage.Member_ADV
            ) AS s
        ON t.CentauriMemberID = s.CentauriMemberID
        WHEN MATCHED AND ( ISNULL(t.LastName,'') <> ISNULL(s.LastName,'')
                           OR ISNULL(t.FirstName,'') <> ISNULL(s.FirstName,'')
                           OR ISNULL(t.Gender,'') <> ISNULL(s.Gender,'')
                           OR ISNULL(t.DOB,'') <> ISNULL(s.DOB,'')
                         ) THEN
            UPDATE SET
                    t.LastName = s.LastName ,
                    t.FirstName = s.FirstName ,
                    t.Gender = s.Gender ,
                    t.DOB = s.DOB ,
                    t.LastUpdate = @CurrentDate
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

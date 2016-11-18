SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	08/01/2016
-- Description:	merges the stage to dim for member
-- Usage:			
--		  EXECUTE dbo.spMMRMergeMember
-- =============================================
CREATE PROC [dbo].[spMMRMergeMember]
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
                        MiddleName ,
                        Gender ,
                        DOB
              FROM      stage.Member_MMR
            ) AS s
        ON t.CentauriMemberID = s.CentauriMemberID
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

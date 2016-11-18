SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Travis Parker
-- Create date:	10/06/2016
-- Description:	merges the stage to dim for member
-- Usage:			
--		  EXECUTE dbo.spHEDISMergeMember
-- =============================================
CREATE PROC [dbo].[spHEDISMergeMember]
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
                        ISNULL(MiddleName, '') AS MiddleName ,
                        Gender ,
                        DOB ,
                        RecordSource ,
                        LoadDate
              FROM      stage.Member_HEDIS
            ) AS s
        ON t.CentauriMemberID = s.CentauriMemberID
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriMemberID ,
                     LastName ,
                     FirstName ,
                     MiddleName ,
                     Gender ,
                     DOB,
				 RecordSource
                   )
            VALUES ( s.CentauriMemberID ,
                     s.LastName ,
                     s.FirstName ,
                     s.MiddleName ,
                     s.Gender ,
                     s.DOB,
				 s.RecordSource
                   );

    END;     




GO

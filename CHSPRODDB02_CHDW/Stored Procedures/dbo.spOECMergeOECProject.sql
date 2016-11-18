SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	06/02/2016
-- Description:	merges the stage to dim for OECProject
-- Usage:			
--		  EXECUTE dbo.spOECMergeOECProject
-- =============================================
CREATE PROC [dbo].[spOECMergeOECProject]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.OECProject AS t
        USING
            ( SELECT    s.CentauriOECProjectID ,
                        s.ProjectID ,
                        s.ProjectName ,
                        c.ClientID
              FROM      stage.OECProject s
                        INNER JOIN dim.Client c ON s.CentauriClientID = c.CentauriClientID
            ) AS s
        ON t.CentauriOECProjectID = s.CentauriOECProjectID AND t.ClientID = s.ClientID
        WHEN MATCHED AND ( t.ProjectID <> s.ProjectID
                           OR t.ProjectName <> s.ProjectName
                         ) THEN
            UPDATE SET
                    t.ProjectID = s.ProjectID ,
                    t.ProjectName = s.ProjectName ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriOECProjectID ,
                     ProjectID ,
                     ProjectName ,
				 ClientID
                   )
            VALUES ( CentauriOECProjectID ,
                     ProjectID ,
                     ProjectName ,
				 ClientID
                   );

    END;     



GO

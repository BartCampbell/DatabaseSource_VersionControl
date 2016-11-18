SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/12/2016
-- Description:	merges the stage to dim for advance IssueResponseOffice 
-- Usage:			
--		  EXECUTE dbo.spAdvMergeIssueResponseOffice
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeIssueResponseOffice]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.IssueResponseOffice AS t
        USING
            ( SELECT    cn.[CentauriIssueResponseID] ,
                        ci.[ContactNotesOfficeID] ,
                        us.[UserID] ,
                        cn.[IssueResponse] ,
                        cn.[AdditionalResponse] ,
                        cn.[dtInsert]
             FROM      [stage].[IssueResponseOffice_ADV] cn
                        LEFT OUTER JOIN [dim].[User] us ON us.CentauriUserID = cn.CentauriUserID
                        LEFT OUTER JOIN fact.ContactNotesOffice ci ON ci.CentauriContactNotesOfficeID = cn.CentauriContactNotesOfficeID
            ) AS s
        ON t.CentauriIssueResponseID = s.CentauriIssueResponseID AND t.[ContactNotesOfficeID] = s. [ContactNotesOfficeID]
        WHEN MATCHED AND (  ISNULL(t.[UserID], 0) <> ISNULL(s.[UserID], 0)
                           OR ISNULL(t.[IssueResponse], '') <> ISNULL(s.[IssueResponse],
                                                              '')
                           OR ISNULL(t.[AdditionalResponse], '') <> ISNULL(s.[AdditionalResponse],
                                                              '')
                           OR ISNULL(t.[dtInsert], '') <> ISNULL(s.[dtInsert],
                                                              '')
                         ) THEN
            UPDATE SET
                    t.[ContactNotesOfficeID] = s.[ContactNotesOfficeID] ,
                    t.[UserID] = s.[UserID] ,
                    t.[IssueResponse] = s.[IssueResponse] ,
                    t.[AdditionalResponse] = s.[AdditionalResponse] ,
                    t.[dtInsert] = s.[dtInsert] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( [CentauriIssueResponseID] ,
                     [ContactNotesOfficeID] ,
                     [UserID] ,
                     [IssueResponse] ,
                     [AdditionalResponse] ,
                     [dtInsert]

                   )
            VALUES ( [CentauriIssueResponseID] ,
                     [ContactNotesOfficeID] ,
                     [UserID] ,
                     [IssueResponse] ,
                     [AdditionalResponse] ,
                     [dtInsert]
                   );

    END;     

GO

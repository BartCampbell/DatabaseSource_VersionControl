SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
-- Description:	merges the stage to dim for Project for advance
-- Usage:			
--		  EXECUTE dbo.spAdvMergeProject
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeProject]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.ADVProject AS t
        USING
            ( SELECT    p.[CentauriProjectID] ,
                        c.[ClientID] ,
                        p.[Project_Name] ,
                        p.[IsScan] ,
                        p.[IsCode] ,
                        p.[Client_PK] ,
                        p.[dtInsert] ,
                        p.[IsProspective] ,
                        p.[IsRetrospective] ,
                        p.[IsHEDIS] ,
                        p.[ProjectGroup] ,
                        p.[ProjectGroup_PK]
              FROM      stage.Project_ADV p
                        INNER JOIN dim.Client c ON c.CentauriClientID = p.ClientID
            ) AS s
        ON t.CentauriProjectID = s.CentauriProjectID
        WHEN MATCHED AND ( ISNULL(t.[Project_Name], '') <> ISNULL(s.[Project_Name],
                                                              '')
                           OR ISNULL(t.[IsScan], 0) <> ISNULL(s.[IsScan], 0)
                           OR ISNULL(t.[IsCode], 0) <> ISNULL(s.[IsCode], 0)
                           OR ISNULL(t.[Client_PK], 0) <> ISNULL(s.[Client_PK],
                                                              0)
                           OR ISNULL(t.[dtInsert], '') <> ISNULL(s.[dtInsert],
                                                              '')
                           OR ISNULL(t.[IsProspective], 0) <> ISNULL(s.[IsProspective],
                                                              0)
                           OR ISNULL(t.[IsRetrospective], 0) <> ISNULL(s.[IsRetrospective],
                                                              0)
                           OR ISNULL(t.[IsHEDIS], 0) <> ISNULL(s.[IsHEDIS], 0)
                           OR ISNULL(t.[ProjectGroup], '') <> ISNULL(s.[ProjectGroup],
                                                              '')
                           OR ISNULL(t.[ProjectGroup_PK], 0) <> ISNULL(s.[ProjectGroup_PK],
                                                              0)
                         ) THEN
            UPDATE SET
                    t.[ClientID] = s.[ClientID] ,
                    t.[Project_Name] = s.[Project_Name] ,
                    t.[IsScan] = s.[IsScan] ,
                    t.[IsCode] = s.[IsCode] ,
                    t.[Client_PK] = s.[Client_PK] ,
                    t.[dtInsert] = s.[dtInsert] ,
                    t.[IsProspective] = s.[IsProspective] ,
                    t.[IsRetrospective] = s.[IsRetrospective] ,
                    t.[IsHEDIS] = s.[IsHEDIS] ,
                    t.[ProjectGroup] = s.[ProjectGroup] ,
                    t.[ProjectGroup_PK] = s.[ProjectGroup_PK] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( [CentauriProjectID] ,
                     [ClientID] ,
                     [Project_Name] ,
                     [IsScan] ,
                     [IsCode] ,
                     [Client_PK] ,
                     [dtInsert] ,
                     [IsProspective] ,
                     [IsRetrospective] ,
                     [IsHEDIS] ,
                     [ProjectGroup] ,
                     [ProjectGroup_PK]
                   )
            VALUES ( [CentauriProjectID] ,
                     [ClientID] ,
                     [Project_Name] ,
                     [IsScan] ,
                     [IsCode] ,
                     [Client_PK] ,
                     [dtInsert] ,
                     [IsProspective] ,
                     [IsRetrospective] ,
                     [IsHEDIS] ,
                     [ProjectGroup] ,
                     [ProjectGroup_PK]
                   );

    END;     


GO

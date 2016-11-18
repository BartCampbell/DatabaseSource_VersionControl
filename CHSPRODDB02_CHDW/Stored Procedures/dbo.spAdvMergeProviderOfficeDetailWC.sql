SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/19/2016
-- Description:	merges the stage to dim for ProviderOfficeDetail 
-- Usage:			
--		  EXECUTE dbo.spAdvMergeProviderOfficeDetail
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeProviderOfficeDetailWC]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO dim.ProviderOfficeDetail
                ( ProviderOfficeID ,
                  [EMR_Type] ,
                  [EMR_Type_PK] ,
                  [GroupName] ,
                  LocationID ,
                  ProviderOfficeBucket_PK ,
                  Pool_PK ,
                  AssignedUser_PK ,
                  AssignedDate ,
                  RecordStartDate ,
                  RecordEndDate

	            )
                SELECT DISTINCT
                        m.ProviderOfficeID ,
                        s.[EMR_Type] ,
                        s.[EMR_Type_PK] ,
                        s.[GroupName] ,
                        s.LocationID ,
                        s.ProviderOfficeBucket_PK ,
                        s.Pool_PK ,
                        s.AssignedUser_PK ,
                        s.AssignedDate ,
                        @CurrentDate ,
                        '2999-12-31 00:00:00.000'
                FROM    stage.ProviderOfficeDetail_ADV s
                        INNER JOIN dim.[ProviderOffice] m ON m.CentauriProviderOfficeID = s.CentauriProviderOfficeID
                        LEFT JOIN dim.ProviderOfficeDetail d ON d.ProviderOfficeID = m.ProviderOfficeID
                                                              AND ISNULL(d.[EMR_Type],
                                                              '') = ISNULL(s.[EMR_Type],
                                                              '')
                                                              AND ISNULL(d.[EMR_Type_PK],
                                                              '') = ISNULL(s.[EMR_Type_PK],
                                                              '')
                                                              AND ISNULL(d.[GroupName],
                                                              '') = ISNULL(s.[GroupName],
                                                              '')
                                                              AND ISNULL(d.[LocationID],
                                                              '') = ISNULL(s.[LocationID],
                                                              '')
                                                              AND ISNULL(d.[ProviderOfficeBucket_PK],
                                                              '') = ISNULL(s.[ProviderOfficeBucket_PK],
                                                              '')
                                                              AND ISNULL(d.[Pool_PK],
                                                              '') = ISNULL(s.[Pool_PK],
                                                              '')
                                                              AND ISNULL(d.[AssignedUser_PK],
                                                              '') = ISNULL(s.[AssignedUser_PK],
                                                              '')
                                                              AND ISNULL(d.[AssignedDate],
                                                              '') = ISNULL(s.[AssignedDate],
                                                              '')
                WHERE   d.ProviderOfficeDetailID IS NULL; 

        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.ProviderOfficeDetail_ADV s
                INNER JOIN dim.[ProviderOffice] m ON m.CentauriProviderOfficeID = s.CentauriProviderOfficeID
                INNER JOIN dim.ProviderOfficeDetail mc ON mc.ProviderOfficeID = m.ProviderOfficeID
        WHERE   ( ISNULL(mc.[EMR_Type], '') <> ISNULL(s.[EMR_Type], '')
                  OR ISNULL(mc.[EMR_Type_PK], '') <> ISNULL(s.[EMR_Type_PK],
                                                            '')
                  OR ISNULL(mc.[GroupName], '') <> ISNULL(s.[GroupName], '')
                  OR ISNULL(mc.[LocationID], '') <> ISNULL(s.[LocationID], '')
                  OR ISNULL(mc.[ProviderOfficeBucket_PK], '') <> ISNULL(s.[ProviderOfficeBucket_PK],
                                                              '')
                  OR ISNULL(mc.[Pool_PK], '') <> ISNULL(s.[Pool_PK], '')
                  OR ISNULL(mc.[AssignedUser_PK], '') <> ISNULL(s.[AssignedUser_PK],
                                                              '')
                  OR ISNULL(mc.[AssignedDate], '') <> ISNULL(s.[AssignedDate],
                                                             '')
                )
                AND mc.RecordEndDate = '2999-12-31 00:00:00.000';

    END;     



GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
-- Description:	merges the stage to dim for ProviderOfficeDetail 
-- Usage:			
--		  EXECUTE dbo.spAdvMergeProviderOfficeDetail
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeProviderOfficeDetail]
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
                  RecordStartDate ,
                  RecordEndDate

	            )
                SELECT DISTINCT
                        m.ProviderOfficeID ,
                        s.[EMR_Type] ,
                        s.[EMR_Type_PK] ,
                        s.[GroupName] ,
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
                )
                AND mc.RecordEndDate = '2999-12-31 00:00:00.000';

    END;     



GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
--Update 10/10/2016 Cahnged RecordEndDate to 2998 to avoid turning off all update records 
-- Description:	merges the stage to dim for UserLocation
-- Usage:			
--		  EXECUTE dbo.spAdvMergeUserLocation
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeUserLocation]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO dim.UserLocation
                ( [UserID] ,
                  [AdvanceLocationID] ,
                  [address] ,
                  [zipcode_pk] ,
                  [Latitude] ,
                  [Longitude] ,
                  RecordStartDate ,
                  RecordEndDate
	            )
                SELECT DISTINCT
                        m.UserID ,
                        l.[AdvanceLocationID] ,
                        s.[address] ,
                        s.[zipcode_pk] ,
                        s.[Latitude] ,
                        s.[Longitude] ,
                        @CurrentDate ,
                        '2998-12-31 00:00:00.000'
                FROM    stage.UserLocation_ADV s
                        INNER JOIN dim.[User] m ON m.CentauriUserid = s.CentauriUserid
                        LEFT OUTER JOIN dim.AdvanceLocation l ON l.CentauriAdvanceLocationID = s.CentauriAdvanceLocationID
                        LEFT JOIN dim.UserLocation d ON d.UserID = m.UserID
                                                        AND ISNULL(d.[address],'') = ISNULL(s.[address],'')
                                                        AND ISNULL(d.[zipcode_pk],'') = ISNULL(s.[zipcode_pk],'')
                                                        AND ISNULL(d.[Latitude],'') = ISNULL(s.[Latitude],'')
                                                        AND ISNULL(d.[Longitude],0) = ISNULL(s.[Longitude],0)
                                                        AND ISNULL(d.AdvanceLocationID,0) = ISNULL(l.AdvanceLocationID,0)
                WHERE   d.UserLocationID IS NULL; 

        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.UserLocation_ADV s
                INNER JOIN dim.[User] m ON m.CentauriUserID = s.CentauriUserid
                INNER JOIN dim.UserLocation mc ON mc.UserID = m.UserID
                LEFT OUTER JOIN dim.AdvanceLocation l ON l.CentauriAdvanceLocationID = s.CentauriAdvanceLocationID
        WHERE   
				( ISNULL(mc.[address], '') <> ISNULL(s.[address], '')
                  OR ISNULL(mc.[zipcode_pk], '') <> ISNULL(s.[zipcode_pk], '')
                  OR ISNULL(mc.[Latitude], '') <> ISNULL(s.[Latitude], '')
                  OR ISNULL(mc.[Longitude], 0) <> ISNULL(s.[Longitude], 0)
                  OR ISNULL(l.CentauriAdvanceLocationID, 0) <> ISNULL(s.CentauriAdvanceLocationID,0)
                )
                AND 
				mc.RecordEndDate = '2999-12-31 00:00:00.000';

		UPDATE  dim.UserLocation
        SET     RecordEndDate = '2999-12-31 00:00:00.000'
		WHERE  RecordEndDate =  '2998-12-31 00:00:00.000'
        
        

    END;     



GO

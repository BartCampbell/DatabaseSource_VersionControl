SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[CheckOtherLocationsExist] @PursuitEventID int
AS 
DECLARE @MemberID int
DECLARE @ProviderSiteID int
DECLARE @MeasureID int

SELECT  @MemberID = P.MemberID
FROM    PursuitEvent PE
        JOIN Pursuit P ON PE.PursuitID = P.PursuitID
WHERE   PE.PursuitEventID = @PursuitEventID

SELECT  @ProviderSiteID = P.ProviderSiteID
FROM    PursuitEvent PE
        JOIN Pursuit P ON PE.PursuitID = P.PursuitID
WHERE   PE.PursuitEventID = @PursuitEventID

SELECT  @MeasureID = PE.MeasureID
FROM    PursuitEvent PE
WHERE   PE.PursuitEventID = @PursuitEventID 

DECLARE @OtherLocationsExist bit
SET @OtherLocationsExist = 0

IF (EXISTS ( SELECT *
             FROM   Pursuit P
                    JOIN PursuitEvent PE ON P.PursuitID = PE.PursuitID
             WHERE  P.MemberID = @MemberID AND
                    --PE.MeasureID = @MeasureID AND
                    P.ProviderSiteID <> @ProviderSiteID )) 
    BEGIN
        SET @OtherLocationsExist = 1
    END


SELECT  @OtherLocationsExist




GO

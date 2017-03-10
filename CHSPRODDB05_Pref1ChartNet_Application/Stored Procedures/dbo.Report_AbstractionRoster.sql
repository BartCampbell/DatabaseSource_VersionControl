SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Report_AbstractionRoster]
    @CustomerProviderID varchar(25) = NULL,
    @MemberID int = NULL
AS 
DECLARE @YearEndDate datetime
SET @YearEndDate = CAST('12/31/' + CAST(YEAR(GETDATE()) AS varchar) AS datetime)


SELECT	DISTINCT
        M.MemberID,
        PR.CustomerProviderID,
        M.NameLast,
        M.NameFirst,
        M.NameLast + ', ' + M.NameFirst FullName,
        M.Gender,
        DATEDIFF(yy, M.DateOfBirth, @YearEndDate) Age,
        CONVERT(varchar, M.DateOfBirth, 101) DateOfBirth,
        ME.HEDISMeasureDescription
FROM    Member M
        JOIN Pursuit P ON M.MemberID = P.MemberID
        JOIN PursuitEvent PE ON P.PursuitID = PE.PursuitID
        JOIN Measure ME ON PE.MeasureID = ME.MeasureID
        JOIN Providers PR ON P.ProviderID = PR.ProviderID
WHERE   PR.CustomerProviderID = ISNULL(@CustomerProviderID,
                                       PR.CustomerProviderID) AND
        M.MemberID = ISNULL(@MemberID, M.MemberID)
ORDER BY M.NameLast,
        M.NameFirst,
        ME.HEDISMeasureDescription



GO

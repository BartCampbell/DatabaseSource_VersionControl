SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =================================================================================================================================
-- Author:		Melody Jones
-- Create date: 03/01/2017
-- Description:	 Comprehensive Diabetes Care Assessment form
-- Version History	
-- Date			Name			Comments
-- 03/01/2017	Melody Jones	Initial create
-- 03/16/2017	Melody Jones	Changed from MemberID to CustomerMemberID	
-- ==================================================================================================================================

CREATE PROCEDURE [dbo].[Report_CDC_AbstractionForm]
    @MemberID varchar(5000)
AS 
SELECT DISTINCT
       m.[CustomerMemberID] AS MemberID
	  ,[NameFirst]
      ,[NameLast]
      ,[NameMiddleInitial]
	  ,[DateOfBirth]
	  ,[MemberAge] = DATEDIFF(Year,[DateOfBirth],'12/31/2016')
FROM [ChartNet_BCBSAZ_Application].[dbo].[Member] m 
INNER JOIN [ChartNet_BCBSAZ_Application].[dbo].[Pursuit] P
ON p.MemberID = m.MemberID
INNER JOIN [ChartNet_BCBSAZ_Application].[dbo].[PursuitEvent] pe
ON p.PursuitID = pe.PursuitID
INNER JOIN [ChartNet_BCBSAZ_Application].[dbo].[Measure] me
ON pe.MeasureID = me.MeasureID
AND [HEDISMeasure] = 'CDC'
WHERE    m.[CustomerMemberID] IN (SELECT stringValue FROM [dbo].[dba_parseString_udf](@MemberID,','))
ORDER BY   m.[CustomerMemberID]

GO
GRANT EXECUTE ON  [dbo].[Report_CDC_AbstractionForm] TO [INTERNAL\Melody.Jones]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Report].[GetSystematicSampleRoster]
(
 @DataRunID int,
 @PopulationID int = NULL
 )
AS
BEGIN

----------------------------------------------------

    IF OBJECT_ID('tempdb..#MedRcds') IS NOT NULL
        DROP TABLE #MedRcds;

    SELECT  SUM(CONVERT(smallint, IsDenominator)) AS CountDenominator,
            SUM(CONVERT(smallint, IsNumerator)) AS CountNumerator,
            RMD.DataRunID,
            RMD.DataSetID,
            RMD.DSMemberID,
            RMD.EnrollGroupID,
            RMD.KeyDate,
            RMD.MeasureID,
            RMD.MeasureXrefID,
            RMD.PayerID,
            RMD.PopulationID,
            RMD.ProductLineID,
            RMD.ResultTypeID,
            RMD.SysSampleRefID,
            RSS.SysSampleOrder,
            RSS.IsAuxiliary,
            RSS.SysSampleID,
			MIN(PP.Abbrev) AS SysSamplePayer
    INTO    #MedRcds
    FROM    Result.MeasureDetail AS RMD WITH (NOLOCK)
            INNER JOIN Measure.Metrics AS MX WITH (NOLOCK) ON RMD.MetricID = MX.MetricID AND
                                                              MX.IsInverse = 0
            INNER JOIN Result.SystematicSamples AS RSS WITH (NOLOCK) ON RMD.SysSampleRefID = RSS.SysSampleRefID AND
                                                              RMD.DataRunID = RSS.DataRunID
            INNER JOIN Batch.SystematicSamples AS BSS WITH (NOLOCK) ON RSS.SysSampleID = BSS.SysSampleID AND
                                                              RSS.DataRunID = BSS.DataRunID
            LEFT OUTER JOIN Product.Payers AS PP WITH (NOLOCK) ON PP.PayerID = BSS.PayerID
    WHERE   RMD.DataRunID = @DataRunID AND
            (@PopulationID IS NULL OR
             RMD.PopulationID = @PopulationID
            ) AND
            RMD.ResultTypeID = 3 --1 = Admin EOC-Like, 2 = Medical Record, 3 = Hybrid)
GROUP BY    RMD.DataRunID,
            RMD.DataSetID,
            RMD.DSMemberID,
            RMD.EnrollGroupID,
            RMD.KeyDate,
            RMD.MeasureID,
            RMD.MeasureXrefID,
            RMD.PayerID,
            RMD.PopulationID,
            RMD.ProductLineID,
            RMD.ResultTypeID,
            RMD.SysSampleRefID,
            RSS.SysSampleOrder,
            RSS.IsAuxiliary,
            RSS.SysSampleID
    ORDER BY MeasureID,
            SysSampleOrder;
 
			
    IF OBJECT_ID('tempdb..#Admins') IS NOT NULL
        DROP TABLE #Admins;		
					
    SELECT DISTINCT
            RMD.DataRunID,
            RMD.DataSetID,
            RMD.DSMemberID,
            RMD.EnrollGroupID,
            RMD.KeyDate,
            RMD.MeasureID,
            RMD.MeasureXrefID,
            RMD.PayerID,
            RMD.PopulationID,
            RMD.ProductLineID,
            RMD.ResultTypeID
    INTO    #Admins
    FROM    Result.MeasureDetail AS RMD WITH (NOLOCK)
    WHERE   RMD.DataRunID = @DataRunID AND
            (@PopulationID IS NULL OR
             RMD.PopulationID = @PopulationID
            ) AND
            MeasureID IN (SELECT DISTINCT
                                    MeasureID
                          FROM      #MedRcds) AND
            IsDenominator = 1 AND
            IsExclusion = 0 AND
            RMD.ResultTypeID = 1 --1 = Admin EOC-Like, 2 = Medical Record, 3 = Hybrid) 
ORDER BY    MeasureID;          


/*************************************************************************************
--THE FOLLOWING SECTION IS USED FOR RESEARCH PURPOSES ONLY
--Admin data...
SELECT	'Admin' AS SourceType,
		COUNT(DISTINCT DSMemberID) AS CountMembers, 
		COUNT(*) AS CountRecords, 
		MM.Abbrev AS Measure, 
		t.MeasureID
FROM	#Admins AS t
		INNER JOIN Measure.Measures AS MM
				ON t.MeasureID = MM.MeasureID
GROUP BY MM.Abbrev,
		t.MeasureID
ORDER BY Measure;

--Medical Record data...
SELECT	'Sample' AS SourceType,
		COUNT(DISTINCT DSMemberID) AS CountMembers, 
		COUNT(*) AS CountRecords,  
		t.IsAuxiliary, 
		MM.Abbrev AS Measure, 
		t.MeasureID
FROM	#MedRcds AS t
		INNER JOIN Measure.Measures AS MM
				ON t.MeasureID = MM.MeasureID
GROUP BY t.IsAuxiliary,
		MM.Abbrev,
		t.MeasureID
ORDER BY Measure, IsAuxiliary;

--Multiple-event members...
WITH FindMultiEventMemberMeasures AS
(
	SELECT	DSMemberID, MeasureID 
	FROM	#MedRcds
	GROUP BY DSMemberID, MeasureID 
	HAVING	COUNT(*) > 1
)
SELECT	MR.* 
FROM	#MedRcds AS MR
		INNER JOIN FindMultiEventMemberMeasures AS t
				ON MR.DSMemberID = t.DSMemberID AND
					MR.MeasureID = t.MeasureID;

*************************************************************************************/

    SELECT  MR.SysSampleID AS [Systematic Sample ID],
			ISNULL(MR.SysSamplePayer + ' - ' + MNG.Descr, 'All') AS [Systematic Sample Description],  
			RDSMK.CustomerMemberID AS [Member ID],
            RDSMK.DisplayID AS [IMI Member ID],
            RDSMK.DOB AS [Date Of Birth],
            Member.ConvertGenderToMF(RDSMK.Gender) AS Gender,
            RDSMK.NameLast AS [Last Name],
            RDSMK.NameFirst AS [First Name],
            RDSMK.SsnDisplay AS [SSN],
            MM.Abbrev AS [Measure],
            MM.Descr AS [Measure Description],
            A.KeyDate AS [Key Event Date],
            MR.SysSampleOrder AS [Sample Order],
            dbo.ConvertBitToYN(MR.IsAuxiliary) AS [Is Auxiliary],
            CASE WHEN MR.CountDenominator IS NULL THEN ''
                 WHEN MR.CountDenominator = MR.CountNumerator THEN 'Y'
                 ELSE 'N'
            END AS [Fully Compliant]
    FROM    #Admins AS A
            INNER JOIN Measure.Measures AS MM WITH (NOLOCK) ON A.MeasureID = MM.MeasureID
            INNER JOIN #MedRcds AS MR ON A.DataRunID = MR.DataRunID AND
                                         A.DSMemberID = MR.DSMemberID AND
                                         A.MeasureID = MR.MeasureID AND
                                         A.KeyDate = MR.KeyDate AND
                                         A.PayerID = MR.PayerID AND
                                         A.PopulationID = MR.PopulationID
            LEFT OUTER JOIN Result.DataSetMemberKey AS RDSMK WITH (NOLOCK) ON A.DataRunID = RDSMK.DataRunID AND
                                                              A.DSMemberID = RDSMK.DSMemberID
			LEFT OUTER JOIN Member.EnrollmentGroups AS MNG WITH(NOLOCK) ON MNG.EnrollGroupID = MR.EnrollGroupID
    ORDER BY [Measure],
			[Systematic Sample ID],
            [Sample Order],
            [Last Name],
            [First Name];

END;





GO
GRANT VIEW DEFINITION ON  [Report].[GetSystematicSampleRoster] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetSystematicSampleRoster] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetSystematicSampleRoster] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetSystematicSampleRoster] TO [Reports]
GO

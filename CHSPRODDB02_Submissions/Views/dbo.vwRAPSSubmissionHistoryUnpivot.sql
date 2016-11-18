SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [dbo].[vwRAPSSubmissionHistoryUnpivot]
AS

SELECT	c.ResponseFileID
		,c.HicNo
		,RTRIM(c.PatientControlNo) AS 'PatientControlNo'
		,c.DOBErrorCode
		,c.HicErrorCode
		,pvt.FromDate
		,pvt.ThruDate
		,pvt.ProviderType
		,pvt.DXCode
		,pvt.ErrorA
		,pvt.ErrorB
		,pvt.ClusterGrouping
		,c.ID AS 'CCCSourceRecordID'
FROM	Insights.dbo.RAPS_RESPONSE_CCC c
		CROSS APPLY
			(
				VALUES 
					(c.FromDate1, c.ThruDate1,c.ProviderType1,c.DiagnosisCode1,c.DiagClstrErrorA1,c.DiagClstrErrorB1,1)
					,(c.FromDate2, c.ThruDate2,c.ProviderType2,c.DiagnosisCode2,c.DiagClstrErrorA2,c.DiagClstrErrorB2,2)
					,(c.FromDate3, c.ThruDate3,c.ProviderType3,c.DiagnosisCode3,c.DiagClstrErrorA3,c.DiagClstrErrorB3,3)
					,(c.FromDate4, c.ThruDate4,c.ProviderType4,c.DiagnosisCode4,c.DiagClstrErrorA4,c.DiagClstrErrorB4,4)
					,(c.FromDate5, c.ThruDate5,c.ProviderType5,c.DiagnosisCode5,c.DiagClstrErrorA5,c.DiagClstrErrorB5,5)
					,(c.FromDate6, c.ThruDate6,c.ProviderType6,c.DiagnosisCode6,c.DiagClstrErrorA6,c.DiagClstrErrorB6,6)
					,(c.FromDate7, c.ThruDate7,c.ProviderType7,c.DiagnosisCode7,c.DiagClstrErrorA7,c.DiagClstrErrorB7,7)
					,(c.FromDate8, c.ThruDate8,c.ProviderType8,c.DiagnosisCode8,c.DiagClstrErrorA8,c.DiagClstrErrorB8,8)
					,(c.FromDate9, c.ThruDate9,c.ProviderType9,c.DiagnosisCode9,c.DiagClstrErrorA9,c.DiagClstrErrorB9,9)
					,(c.FromDate10, c.ThruDate10,c.ProviderType10,c.DiagnosisCode10,c.DiagClstrErrorA10,c.DiagClstrErrorB10,10)
			) pvt (FromDate,ThruDate,ProviderType,DXCode,ErrorA,ErrorB,ClusterGrouping)
WHERE	ISNULL(pvt.FromDate,'') <> ''
		AND
		ISNULL(pvt.ThruDate,'') <> ''
		AND
		ISNULL(pvt.ProviderType,'') <> ''
		AND
		ISNULL(pvt.DXCode,'') <> ''




GO

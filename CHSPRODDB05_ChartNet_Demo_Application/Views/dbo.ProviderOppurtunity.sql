SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[ProviderOppurtunity] AS

select	Pr.CustomerProviderID,		--Report Header
		Pr.NameEntityFullName,		--Report Header
--		PS.ProviderSiteName,		--Report Header
--		PS.Phone,					--Report Header
		M.CustomerMemberID,			--Report Body
		M.NameLast,					--Report Body
		M.NameFirst,				--Report Body
		M.DateOfBirth,				--Report Body
		Me.HEDISMeasure,			--Report Body
		HSM.HEDISSubMetricDescription,	--Report Body
		AbstractionStatus = ASTAT.Description,
		AbstractorName,
		Pr.ProviderID 
from	PursuitEvent PE
		inner join Pursuit P on
			PE.PursuitID = P.PursuitID
		inner join Member M on
			P.MemberID = M.MemberID 
		inner join Providers Pr on
			P.ProviderID = Pr.ProviderID 
		inner join ProviderSite PS on
			P.ProviderSiteID = PS.ProviderSiteID 
		inner join Measure Me on
			PE.MeasureID = Me.MeasureID 
		inner join MemberMeasureSample MMS on
			M.MemberID = MMS.MemberID and
			PE.MeasureID = MMS.MeasureID 
		inner join MemberMeasureMetricScoring MMMS on
			MMS.MemberMeasureSampleID = MMMS.MemberMeasureSampleID 
		inner join HEDISSubMetric HSM on
			MMMS.HEDISSubMetricID = HSM.HEDISSubMetricID 
		left join AbstractionStatus ASTAT on
			PE.PursuitEventStatus = ASTAT.AbstractionStatusID 
		left join Abstractor A on
			P.AbstractorID = A.AbstractorID 

GO

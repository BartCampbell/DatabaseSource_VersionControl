SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vw_faxrpt_onsite] AS
SELECT ps.ProviderSiteID
	, ps.ProviderSiteName
	, ps.Phone ProviderSitePhone
	, ps.Fax ProviderSiteFax
	, ps.Contact ProviderSiteContact
	, c.Client
	, c.MeasureYear
	, c.ClientFax
	, c.ClientAddress1
	, c.ClientAddress2
	, c.ClientPhone
	, c.ClientEmail
	, c.ClientRep
	, p.PursuitNumber
	, m.CustomerMemberID
	, m.NameLast
	, m.NameFirst
	, m.DateOfBirth
	, pro.NameEntityFullName
	, ab.AbstractorName
	, app.AppointmentDate
	, app.AppointmentDateTime
	, mea.HEDISMeasure
	, mea.HEDISMeasureDescription
	, mms.DischargeDate
	, mms.PPCDeliveryDate
FROM dbo.ProviderSite ps
LEFT JOIN 
(select c.ParamCharValue Client
	, my.measureyear
	, fax.clientfax
	, a1.ClientAddress1
	, a2.ClientAddress2
	, phone.ClientPhone
	, email.ClientEmail
	, cr.ClientRep
	FROM dbo.SystemParams c
	LEFT JOIN (select CONVERT(VARCHAR(4), ParamIntValue) MeasureYear FROM dbo.SystemParams WHERE ParamName = 'MeasureYear') my
		ON 1=1
	LEFT JOIN (select '615-555-1212' ClientFax) fax
		ON 1=1 
	LEFT JOIN (select '41905 Thunderhill Road' ClientAddress1) a1
		ON 1=1 
	LEFT JOIN (select 'Parker, CO 80138' ClientAddress2) a2
		ON 1=1 
	LEFT JOIN (select '615-555-1212' ClientPhone) phone
		ON 1=1 
	LEFT JOIN (select 'guardian@guardianangel.com' ClientEmail) email
		ON 1=1 
	LEFT JOIN (select 'HSAG' ClientRep) cr
		ON 1=1 
	WHERE c.ParamName = 'CurrentClient') c
	ON 1=1
LEFT JOIN dbo.Pursuit p
	ON ps.ProviderSiteID = p.ProviderSiteID
LEFT JOIN dbo.Member m
	ON p.MemberID = m.MemberID
LEFT JOIN dbo.providers pro
	ON p.ProviderID = pro.ProviderID
LEFT JOIN dbo.abstractor ab
	ON p.AbstractorID = ab.AbstractorID
LEFT JOIN dbo.Appointment app
	ON p.AppointmentID = app.AppointmentID
LEFT JOIN dbo.MemberMeasureSample mms
	ON m.memberid = mms.MemberID
LEFT JOIN dbo.Measure mea
	ON mms.MeasureID = mea.measureid 
--where p.appointmentid is not NULL
--AND p.providersiteid = '1070183'
--ORDER BY p.ProviderSiteID




GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[vw_ProviderSiteFax] AS
SELECT ps.ProviderSiteID
	,ps.CustomerProviderSiteID
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
	, c.ReturnDate
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
	, fmc.faxmeasureinstruction
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
	, rd.ReturnDate
	FROM dbo.SystemParams c
	LEFT JOIN (select CONVERT(VARCHAR(4), ParamIntValue) MeasureYear FROM dbo.SystemParams WHERE ParamName = 'MeasureYear') my
		ON 1=1
	LEFT JOIN (select '321-525-7700' ClientFax) fax
		ON 1=1 
	LEFT JOIN (select '41905 Thunderhill Road' ClientAddress1) a1
		ON 1=1 
	LEFT JOIN (select 'Parker, CO 80138' ClientAddress2) a2
		ON 1=1 
	LEFT JOIN (select '321-525-7700' ClientPhone) phone
		ON 1=1 
	LEFT JOIN (select 'guardian@guardianangel.com' ClientEmail) email
		ON 1=1 
	LEFT JOIN (select CONVERT(DATETIME, '20140301', 112) AS ReturnDate) rd
		ON 1=1 
	LEFT JOIN (select 'HSAG' ClientRep) cr
		ON 1=1 
	WHERE c.ParamName = 'CurrentClient') c
	ON 1=1
LEFT JOIN dbo.Pursuit p
	ON ps.ProviderSiteID = p.ProviderSiteID
LEFT JOIN dbo.PursuitEvent AS PV
	ON p.PursuitID = PV.PursuitID
LEFT JOIN dbo.Member m
	ON p.MemberID = m.MemberID
LEFT JOIN dbo.providers pro
	ON p.ProviderID = pro.ProviderID
LEFT JOIN dbo.abstractor ab
	ON p.AbstractorID = ab.AbstractorID
LEFT JOIN dbo.Appointment app
	ON p.AppointmentID = app.AppointmentID
LEFT JOIN dbo.MemberMeasureSample mms
	ON m.memberid = mms.MemberID AND
		PV.MeasureID = mms.MeasureID  
LEFT JOIN dbo.Measure mea
	ON mms.MeasureID = mea.measureid 
LEFT JOIN dbo.faxMeasureContent fmc
	ON mea.MeasureID = fmc.measureid
--where p.providersiteid = '1070183'
--ORDER BY p.ProviderSiteID






GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[prLoadClient]
--***********************************************************************
--***********************************************************************
/*
Loads all Client import tables into ChartNet, purging all existing data
*/
--***********************************************************************
--***********************************************************************
AS 
EXEC [dbo].[prTruncateUserData]

DELETE  AdministrativeEvent
DELETE	dbo.AbstractionReviewDetail
DELETE  dbo.AbstractionReview
DELETE	dbo.AbstractionReviewSetConfiguration
DELETE	dbo.AbstractionReviewSet
DELETE	dbo.AbstractionOverRead 
DELETE  dbo.ProviderSiteAppointment
DELETE	dbo.Appointment
DELETE	dbo.ActivityLog
DELETE	dbo.FaxLogPursuits
DELETE  dbo.FaxLog
DELETE  PursuitEventNote
DELETE  PursuitEventLog
DELETE	PursuitEventChartImage
DELETE  PursuitEventSupplementalInformation
DELETE  PursuitEventDataEntryStatus
DELETE  dbo.PursuitEventStatusLog
DELETE  PursuitEvent
DELETE  Pursuit
DELETE  MemberMeasureMetricScoring
DELETE  MemberMeasureSample
DELETE  Member
DELETE  Providers
DELETE  ProviderSite

DELETE  Abstractor
DELETE  Reviewer


EXEC prLoadMember
EXEC prLoadProviders
EXEC prLoadProviderSite
EXEC prLoadAdministrativeEvent
EXEC prLoadPursuitEvent
EXEC prLoadMemberMeasureSample
EXEC prLoadMemberMeasureMetricScoring

EXEC prLoadAbstractor
EXEC prLoadReviewer

EXEC dbo.ApplyMemberMeasureSampleIDsToPursuitEvent
EXEC dbo.GetRecordCounts 



GO

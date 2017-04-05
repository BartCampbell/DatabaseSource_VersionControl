SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE proc [dbo].[prUpdateDwHedisMRTables]
as
--*************************************************************************
--*************************************************************************
/*

exec POP_HEDIS_FACT_AWC '20071231', '20070101', '20071231'
exec POP_HEDIS_FACT_W34 '20071231', '20070101', '20071231'
exec POP_HEDIS_FACT_LSC '20071231', '20070101', '20071231'
print 'LSC'
exec POP_HEDIS_FACT_W15 '20071231', '20070101', '20071231'
exec POP_HEDIS_FACT_CCS '20071231', '20070101', '20071231'
exec POP_HEDIS_FACT_APC '20071231', '20070101', '20071231'
print 'APC'
exec POP_HEDIS_FACT_CDC '20071231', '20070101', '20071231'
exec POP_HEDIS_FACT_CDX '20071231', '20070101', '20071231'
exec POP_HEDIS_FACT_CIS '20071231', '20070101', '20071231'
exec POP_HEDIS_FACT_CMC '20071231', '20070101', '20071231'
print 'CMC'
exec POP_HEDIS_FACT_CBP '20071231', '20070101', '20071231'
exec POP_HEDIS_FACT_PPC '20071231', '20070101', '20071231'
--30 minutes to run all
*/
--*************************************************************************
--*************************************************************************

/*


create table Abstractor
(		AbstractorID			int	identity(1,1),
		AbstractorName			varchar(50))

create table Pursuit
(		PursuitID				int	identity(1,1),
		MemberID				int,
		ProviderID				int,
		AbstractorID			int,
		AbstractionDate			datetime,
		PursuitStatus			varchar(2),
		Source					varchar(80),
		SourcePK1				varchar(50),
		SourcePK2				varchar(50),
		SourcePK3				varchar(50),
		SourcePK4				varchar(50),
		SourcePK5				varchar(50))

create table PursuitEvent
(		PursuitEventID			int	identity(1,1),
		PursuitID				int,
		PursuitEventType		varchar(1),
		MR_ServiceDate			datetime,
		Source					varchar(80),
		SourcePK1				varchar(50),
		SourcePK2				varchar(50),
		SourcePK3				varchar(50),
		SourcePK4				varchar(50),
		SourcePK5				varchar(50) )

create table MedicalRecordAWC
(		PursuitID				int,
		PursuitEventID			int,
		AWC_MR_NumeratorFlag	int,
		AWC_HlthDevFlag			int,
		AWC_PhysExamFlag		int,
		AWC_HlthEducFlag		int,
		AWC_MR_SampleVoidFlag	int,
		AWC_SampleVoidReason	varchar(40),
		AWC_MR_PursuitStatus	varchar(40) )



create table dw_hedis_mr_awc
(		dw_hedis_claim_hdr_key	int,
		dw_hedis_claim_dtl_key	int,
		ihds_member_id			int,
		ihds_prov_id			int,
		service_date			datetime,
		AWC_MR_NumeratorFlag	int,
		AWC_HlthDevFlag			int,
		AWC_PhysExamFlag		int,
		AWC_HlthEducFlag		int,
		AWC_MR_SampleVoidFlag	int,
		AWC_SampleVoidReason	varchar(40),
		AWC_MR_PursuitStatus	varchar(40) )





create table dw_hedis_mr_cdc_hba1c
(		PursuitID					int,
		PursuitEventID				int,
		MR_ServiceDate				datetime,
		CDC_MR_HbA1CEventFlag		varchar(1),
		CDC_HbA1CResult				numeric(9,2),
		CDC_HbA1CResultEmptyFlag	varchar(1),
		CDC_HbACTestSource			varchar(40) )

create table dw_hedis_mr_cdc_eye
(		PursuitID					int,
		PursuitEventID				int,
		MR_ServiceDate				datetime,
		CDC_MR_EyeExamNumFlag		varchar(1),
		CDC_EyeRetEvalFlag			varchar(1),
		CDC_EyeRetEvalResults		numeric(9,2),
		CDC_EyeRetEvalProv			varchar(40),
		CDC_EyeChartPhotoAbnFlag	varchar(1),
		CDC_EyeNoteOphtExamFlag		varchar(1) )


*/




truncate table hh08_ihds_ds01..NUM01

insert into hh08_ihds_ds01..NUM01
select	* 
from	hh08_rdsm..NUM01


update	hh08_ihds_ds01..NUM01
set		SUBNO		= rtrim(tosubno),
		PERSNO		= rtrim(topersno),
		SUBNOPERS	= rtrim(tosubno)+rtrim(topersno)
from	hh08_ihds_ds01..NUM01 a
		inner join dw_xref_hhp_member_merge_move_hist b on
			a.SUBNO = rtrim(fromsubno) and
			a.PERSNO = rtrim(frompersno) and
			b.dateprocessed > '02/09/2008'


truncate table hh08_ihds_ds01..Diabnum

insert into hh08_ihds_ds01..Diabnum
select	* 
from	hh08_rdsm..Diabnum

update	hh08_ihds_ds01..Diabnum
set		SUBNO		= rtrim(tosubno),
		PERSNO		= rtrim(topersno)
from	hh08_ihds_ds01..Diabnum a
		inner join dw_xref_hhp_member_merge_move_hist b on
			rtrim(a.SUBNO) = rtrim(fromsubno) and
			rtrim(a.PERSNO) = rtrim(frompersno) and
			b.dateprocessed > '02/09/2008'




truncate table hh08_ihds_ds01..tblDenomHist

insert into hh08_ihds_ds01..tblDenomHist
select	* 
from	hh08_rdsm..tblDenomHist

update	hh08_ihds_ds01..tblDenomHist
set		SUBNO		= rtrim(tosubno),
		PERSNO		= rtrim(topersno),
		SUBNOPERS	= rtrim(tosubno)+rtrim(topersno)
from	hh08_ihds_ds01..tblDenomHist a
		inner join dw_xref_hhp_member_merge_move_hist b on
			rtrim(a.SUBNO) = rtrim(fromsubno) and
			rtrim(a.PERSNO) = rtrim(frompersno) and
			b.dateprocessed > '02/09/2008'





IF OBJECT_ID('tempdb..#PursuitNumberXref') is not null
    DROP TABLE #PursuitNumberXref

create table #PursuitNumberXref
(		PursuitNumber			int identity(1,1),
		SUBNO					varchar(20),
		PERSNO					varchar(20),
		UserName				varchar(20),
		AbstractionDate			varchar(8),
		CustomerProviderID 		varchar(20))


insert into #PursuitNumberXref
select	distinct
		SUBNO,
		PERSNO,
		UserName,
		AbstractionDate	= convert(varchar(8),convert(datetime,LASTUPDTE),112),
		CustomerProviderID	= ''
from	hh08_ihds_ds01..NUM01
union
select	distinct
		SUBNO,
		PERSNO,
		USERNAME,
		AbstractionDate	= convert(varchar(8),convert(datetime,LASTUPDTE),112),
		CustomerProviderID	= ''
from	hh08_ihds_ds01..Diabnum
union 
select	distinct
		SUBNO,
		PERSNO,
		UserName,
		AbstractionDate	= convert(varchar(8),convert(datetime,LASTUPDATE),112),
		CustomerProviderID	= '' 
from	hh08_ihds_ds01..tblDenomHist a



IF OBJECT_ID('tempdb..#NUM01') is not null
    DROP TABLE #NUM01

select	PursuitNumber,
		a.*
into	#NUM01
from	hh08_ihds_ds01..NUM01 a
		inner join #PursuitNumberXref b on
			a.SUBNO = b.SUBNO and
			a.PERSNO = b.PERSNO and
			a.UserName = b.UserName and
			convert(varchar(8),convert(datetime,a.LASTUPDTE),112)	= b.AbstractionDate and
			'' = b.CustomerProviderID



insert into #NUM01
(		PursuitNumber
      ,SUBNO
      ,PERSNO
      ,SUBNOPERS
      ,s_GUID
      ,SERVTYPE
      ,LASTUPDTE
      ,UserName)
select	PursuitNumber
	  ,SUBNO		= a.SUBNO
      ,PERSNO		= a.PERSNO
      ,SUBNOPERS	= a.SUBNOPERS
      ,s_GUID		= s_GUID
      ,SERVTYPE		=	case	when	CATEGORY = 'WCV15M'
								then	'W15'
								when	CATEGORY = 'CHOLMGMT'
								then	'CMC'
								when	CATEGORY = 'CERV'
								then	'CCS'
								when	CATEGORY = 'PRENb'
								then	'PPC'
								when	CATEGORY = 'HIGHBP'
								then	'CBP'
								when	CATEGORY = '2YO'
								then	'CIS'
								when	CATEGORY = 'WCV1221Y'
								then	'AWC'
								when	CATEGORY = 'ADOLESCENT'
								then	'APC'
								when	CATEGORY = 'DIABETES'
								then	'CDC'
								when	CATEGORY = 'WCV3456Y'
								then	'W34'								
						end
      ,LASTUPDTE	= a.LASTUPDATE
      ,UserName		= a.UserName
--select	*
from	hh08_ihds_ds01..tblDenomHist a
		inner join #PursuitNumberXref b on
			a.SUBNO = b.SUBNO and
			a.PERSNO = b.PERSNO and
			a.UserName = b.UserName and
			convert(varchar(8),convert(datetime,a.LASTUPDATE),112)	= b.AbstractionDate and
			'' = b.CustomerProviderID
where	not exists (	select	*
						from	#NUM01 b
						where	a.SUBNO = b.SUBNO and
								a.PERSNO = b.PERSNO and
								a.UserName = b.UserName ) and
		CATEGORY <> 'DIABETES'








IF OBJECT_ID('tempdb..#Diabnum') is not null
    DROP TABLE #Diabnum

select	PursuitNumber,
		a.*
into	#Diabnum
from	hh08_ihds_ds01..Diabnum a
		inner join #PursuitNumberXref b on
			a.SUBNO = b.SUBNO and
			a.PERSNO = b.PERSNO and
			a.UserName = b.UserName and
			convert(varchar(8),convert(datetime,a.LASTUPDTE),112)	= b.AbstractionDate and
			'' = b.CustomerProviderID


insert into #Diabnum
(		PursuitNumber
	  ,SUBNO
      ,PERSNO
      ,s_GUID
      ,SERVTYPE
      ,LASTUPDTE
      ,UserName)
select	PursuitNumber
      ,SUBNO		= a.SUBNO
      ,PERSNO		= a.PERSNO
      ,s_GUID		= a.s_GUID
      ,SERVTYPE		='CDC'
      ,LASTUPDTE	= a.LASTUPDATE
      ,UserName		= a.UserName
--select	count(*)
from	hh08_ihds_ds01..tblDenomHist a
		inner join #PursuitNumberXref b on
			a.SUBNO = b.SUBNO and
			a.PERSNO = b.PERSNO and
			a.UserName = b.UserName and
			convert(varchar(8),convert(datetime,a.LASTUPDATE),112)	= b.AbstractionDate and
			'' = b.CustomerProviderID
where	not exists (	select	*
						from	#Diabnum b
						where	a.SUBNO = b.SUBNO and
								a.PERSNO = b.PERSNO and
								a.UserName = b.UserName ) and
		CATEGORY = 'DIABETES'









truncate table Abstractor

insert into Abstractor
(		AbstractorName)
select	distinct
		UserName 
from	#NUM01
union 
select	distinct
		USERNAME
from	#Diabnum a

--select * from Pursuit

truncate table Pursuit

insert into Pursuit
(		MemberID,
		ProviderID,
		AbstractorID,
		AbstractionDate,
		Source,
		SourcePK1)
select	distinct
		MemberID				= b.MemberID,
		ProviderID				= '', --referential integrity issues matching consistently to tblDenomhist
		AbstractorID			= c.AbstractorID,
		AbstractionDate			= convert(varchar(8),convert(datetime,a.LASTUPDTE),112),
		Source					= 'NUM01',
		SourcePK1				= PursuitNumber 
from	#NUM01 a
		inner join Member b on
			a.SUBNOPERS = b.CustomerMemberID
		inner join Abstractor c on
			a.UserName = c.AbstractorName


insert into Pursuit
(		MemberID,
		ProviderID,
		AbstractorID,
		AbstractionDate,
		Source,
		SourcePK1)
select	distinct
		MemberID				= b.MemberID,
		ProviderID				= '', --referential integrity issues matching consistently to tblDenomhist
		AbstractorID			= c.AbstractorID,
		AbstractionDate			= convert(varchar(8),convert(datetime,a.LASTUPDTE),112),
		Source					= 'Diabnum',
		SourcePK1				= PursuitNumber 
from	#Diabnum a
		inner join Member b on
			a.SUBNO+a.PERSNO = b.CustomerMemberID
		inner join Abstractor c on
			a.USERNAME = c.AbstractorName


IF OBJECT_ID('tempdb..#status') is not null
    DROP TABLE #status

select 	PursuitID,
		CHARTSTAT = (	select	top 1 CHARTSTAT
							from	hh08_ihds_ds01..tblDenomHist b2
							where	b.SUBNO = b2.SUBNO and
									b.PERSNO = b2.PERSNO and
									b.UserName = b2.UserName
							order by CHARTNUM desc,
									CHARTSTAT desc)
into	#status 
from	Pursuit a
		inner join #PursuitNumberXref b on
			a.SourcePK1 = b.PursuitNumber


update	Pursuit
set		PursuitStatus = (case	when	CHARTSTAT = 'Data Found'
										then	'10'
										when	CHARTSTAT = 'Chart Unavailable'
										then	'51'
										when	CHARTSTAT = 'Enrollee Unknown'
										then	'52'
										when	CHARTSTAT = 'No Data Found'
										then	'50'
										else	'01'
								end)
from	Pursuit a
		inner join #status b on
			a.PursuitID = b.PursuitID




truncate table PursuitEvent

insert into PursuitEvent
(		PursuitID,
		PursuitEventType,
		MR_ServiceDate,
		Source,
		SourcePK1)
select	PursuitID				= b.PursuitID,
		PursuitEventType		= '', 
		MR_ServiceDate			= a.SERVDATE,
		Source					= 'NUM01',
		SourcePK1				= s_GUID
from	#NUM01 a
		inner join Pursuit b on
			a.PursuitNumber = b.SourcePK1



insert into PursuitEvent
(		PursuitID,
		PursuitEventType,
		MR_ServiceDate,
		Source,
		SourcePK1)
select	PursuitID				= b.PursuitID,
		PursuitEventType		= '', 
		MR_ServiceDate			= a.SERVDATE,
		Source					= 'Diabnum',
		SourcePK1				= s_GUID
from	#Diabnum a
		inner join Pursuit b on
			a.PursuitNumber = b.SourcePK1




IF OBJECT_ID('tempdb..#PursuitEventMax') is not null
    DROP TABLE #PursuitEventMax

select	distinct
		PursuitEventID,
		CHARTSTAT			= (	select	top 1 CHARTSTAT
								from	hh08_ihds_ds01..tblDenomHist b
								where	a.SUBNO = b.SUBNO and
										a.PERSNO = b.PERSNO and
										a.UserName = b.UserName
								order by CHARTNUM desc,
										CHARTSTAT desc),
		Exclusion			= (	select	min(Exclusion)
								from	hh08_ihds_ds01..tblDenomHist b
								where	a.SUBNO = b.SUBNO and
										a.PERSNO = b.PERSNO and
										a.UserName = b.UserName),
		ExclusionRsn		= (	select	top 1 left(ExclusionRsn,40)
								from	hh08_ihds_ds01..tblDenomHist b
								where	a.SUBNO = b.SUBNO and
										a.PERSNO = b.PERSNO and
										a.UserName = b.UserName and
										Exclusion = -1) 
into	#PursuitEventMax
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
union all
select	distinct
		PursuitEventID,
		CHARTSTAT			= (	select	top 1 CHARTSTAT
								from	hh08_ihds_ds01..tblDenomHist b
								where	a.SUBNO = b.SUBNO and
										a.PERSNO = b.PERSNO and
										a.UserName = b.UserName
								order by CHARTNUM desc,
										CHARTSTAT desc),
		Exclusion			= (	select	min(Exclusion)
								from	hh08_ihds_ds01..tblDenomHist b
								where	a.SUBNO = b.SUBNO and
										a.PERSNO = b.PERSNO and
										a.UserName = b.UserName),
		ExclusionRsn		= (	select	top 1 ExclusionRsn
								from	hh08_ihds_ds01..tblDenomHist b
								where	a.SUBNO = b.SUBNO and
										a.PERSNO = b.PERSNO and
										a.UserName = b.UserName and
										Exclusion = -1) 
from	#Diabnum a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1

truncate table MedicalRecordAWC

insert into MedicalRecordAWC
select	PursuitID				= b.PursuitID,
		PursuitEventID			= b.PursuitEventID,
		AWC_MR_NumeratorFlag	=	case	when	DEVHXPHY = 1 and
													DEVHXMNTL = 1 and
													EXAM = 1 and
													HEALTHED = 1
											then	1
											else	0
									end,
		AWC_HlthDevFlag			=	case	when	DEVHXPHY = 1 and DEVHXMNTL = 1
											then	1
											else	0
									end,
		AWC_HlthDevPhysFlag		=	case	when	DEVHXPHY = 1
											then	1
											else	0
									end,
		AWC_HlthDevMntlFlag		=	case	when	DEVHXMNTL = 1
											then	1
											else	0
									end,
		AWC_PhysExamFlag		= EXAM,
		AWC_HlthEducFlag		= HEALTHED,
		AWC_MR_SampleVoidFlag	=	case	when	Exclusion = '-1'
											then	1
											else	0 
									end,
		AWC_SampleVoidReason	= left(ExclusionRsn,40),
		AWC_MR_PursuitStatus	=	case	when	CHARTSTAT = 'Data Found'
											then	'10'
											when	CHARTSTAT = 'Chart Unavailable'
											then	'51'
											when	CHARTSTAT = 'Enrollee Unknown'
											then	'52'
											when	CHARTSTAT = 'No Data Found'
											then	'50'
											else	'01'
									end
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('wcv1221','AWC')





truncate table MedicalRecordW34

insert into MedicalRecordW34
select	PursuitID				= b.PursuitID,
		PursuitEventID			= b.PursuitEventID,
		W34_MR_NumeratorFlag	=	case	when	DEVHXPHY = 1 and
													DEVHXMNTL = 1 and
													EXAM = 1 and
													HEALTHED = 1
											then	1
											else	0
									end,
		W34_HlthDevFlag			=	case	when	DEVHXPHY = 1 and DEVHXMNTL = 1
											then	1
											else	0
									end,
		W34_HlthDevPhysFlag		=	case	when	DEVHXPHY = 1
											then	1
											else	0
									end,
		W34_HlthDevMntlFlag		=	case	when	DEVHXMNTL = 1
											then	1
											else	0
									end,
		W34_PhysExamFlag		= EXAM,
		W34_HlthEducFlag		= HEALTHED,
		W34_MR_SampleVoidFlag	=	case	when	Exclusion = '-1'
											then	1
											else	0 
									end,
		W34_SampleVoidReason	= left(ExclusionRsn,40),
		W34_MR_PursuitStatus	=	case	when	CHARTSTAT = 'Data Found'
											then	'10'
											when	CHARTSTAT = 'Chart Unavailable'
											then	'51'
											when	CHARTSTAT = 'Enrollee Unknown'
											then	'52'
											when	CHARTSTAT = 'No Data Found'
											then	'50'
											else	'01'
									end
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('wcv3456','W34')








truncate table MedicalRecordLSC

insert into MedicalRecordLSC
select	PursuitID				= b.PursuitID,
		PursuitEventID			= b.PursuitEventID,
		LSC_MR_NumeratorFlag	=	case	when	SERVTYPE = 'lead' and
													RESULT1 = 'Yes'
											then	1
											else	0
									end,
		LSC_LeadTestFlag			=	case	when	SERVTYPE = 'lead'
											then	1
											else	0
									end,
		LSC_LeadTestResult		= RESULT1,
		LSC_MR_SampleVoidFlag	=	case	when	Exclusion = '-1'
											then	1
											else	0 
									end,
		LSC_SampleVoidReason	= left(ExclusionRsn,40),
		LSC_MR_PursuitStatus	=	case	when	CHARTSTAT = 'Data Found'
											then	'10'
											when	CHARTSTAT = 'Chart Unavailable'
											then	'51'
											when	CHARTSTAT = 'Enrollee Unknown'
											then	'52'
											when	CHARTSTAT = 'No Data Found'
											then	'50'
											else	'01'
									end
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('lead','CIS')





truncate table MedicalRecordW15

insert into MedicalRecordW15
select	PursuitID				= b.PursuitID,
		PursuitEventID			= b.PursuitEventID,
		W15_MR_NumeratorFlag	=	case	when	DEVHXPHY = 1 and
													DEVHXMNTL = 1 and
													EXAM = 1 and
													HEALTHED = 1
											then	1
											else	0
									end,
		W15_HlthDevFlag			=	case	when	DEVHXPHY = 1 and DEVHXMNTL = 1
											then	1
											else	0
									end,
		W15_HlthDevPhysFlag		=	case	when	DEVHXPHY = 1
											then	1
											else	0
									end,
		W15_HlthDevMntlFlag		=	case	when	DEVHXMNTL = 1
											then	1
											else	0
									end,
		W15_PhysExamFlag		= EXAM,
		W15_HlthEducFlag		= HEALTHED,
		W15_MR_SampleVoidFlag	=	case	when	Exclusion = '-1'
											then	1
											else	0 
									end,
		W15_SampleVoidReason	= left(ExclusionRsn,40),
		W15_MR_PursuitStatus	=	case	when	CHARTSTAT = 'Data Found'
											then	'10'
											when	CHARTSTAT = 'Chart Unavailable'
											then	'51'
											when	CHARTSTAT = 'Enrollee Unknown'
											then	'52'
											when	CHARTSTAT = 'No Data Found'
											then	'50'
											else	'01'
									end
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('wcv15','W15')





truncate table MedicalRecordCCS

insert into MedicalRecordCCS
select	PursuitID				= b.PursuitID,
		PursuitEventID			= b.PursuitEventID,
		CCS_MR_NumeratorFlag	=	case	when	RESULT1 = 'Yes'
											then	1
											else	0
									end,
		CCS_MR_ExclusionFlag	= 0,
		CCS_PapTestFlag			= 0,
		CCS_PapTestResult		= '',
		CCS_ExclHystNoCervixFlag = 0,
		CCS_ExclHystVagPapFlag	= 0,
		CCS_MR_SampleVoidFlag	=	case	when	Exclusion = '-1'
											then	1
											else	0 
									end,
		CCS_SampleVoidReason	= left(ExclusionRsn,40),
		CCS_MR_PursuitStatus	=	case	when	CHARTSTAT = 'Data Found'
											then	'10'
											when	CHARTSTAT = 'Chart Unavailable'
											then	'51'
											when	CHARTSTAT = 'Enrollee Unknown'
											then	'52'
											when	CHARTSTAT = 'No Data Found'
											then	'50'
											else	'01'
									end 
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('cerv','CIS')





truncate table MedicalRecordAPC

insert into MedicalRecordAPC
select	PursuitID				= b.PursuitID,
		PursuitEventID			= b.PursuitEventID,
		APC_DTTYPE				= DTTYPE,
		APC_RESULT1				= RESULT1,
		APC_PASS				= PASS,
		APC_MR_SampleVoidFlag	=	case	when	Exclusion = '-1'
											then	1
											else	0 
									end,
		APC_SampleVoidReason	= left(ExclusionRsn,40),
		APC_MR_PursuitStatus	=	case	when	CHARTSTAT = 'Data Found'
											then	'10'
											when	CHARTSTAT = 'Chart Unavailable'
											then	'51'
											when	CHARTSTAT = 'Enrollee Unknown'
											then	'52'
											when	CHARTSTAT = 'No Data Found'
											then	'50'
											else	'01'
									end 
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('adolescent','APC')



truncate table MedicalRecordCBP_DxConf

insert into MedicalRecordCBP_DxConf
select	PursuitID				= b.PursuitID,
		PursuitEventID			= b.PursuitEventID,
		CBP_ConfHTNFlag			=	case	when	RESULT1 = 'Problem List'
											then	1
											when	RESULT1 = 'No Confirmation Found'
											then	0
											when	RESULT1 is null
											then	0
											when	convert(datetime,SERVDATE) <= '20070630'
											then	1
											else	0
									end,
		CBP_ConfHighBPFlag		= 0,
		CBP_ConfEleBPFlag		= 0,
		CBP_ConfBordHTNFlag		= 0,
		CBP_ConfIntHTNFlag		= 0,
		CBP_ConfHistHTNFlag		= 0,
		CBP_ConfHVDFlag			= 0,
		CBP_ConfHypiaFlag		= 0,
		CBP_ConfHypisFlag		= 0,
		CBP_ConfNotationSource	= RESULT1,
		CBP_MR_SampleVoidFlag	=	case	when	Exclusion = '-1'
											then	1
											else	0 
									end,
		CBP_SampleVoidReason	= left(ExclusionRsn,40),
		CBP_MR_PursuitStatus	=	case	when	CHARTSTAT = 'Data Found'
											then	'10'
											when	CHARTSTAT = 'Chart Unavailable'
											then	'51'
											when	CHARTSTAT = 'Enrollee Unknown'
											then	'52'
											when	CHARTSTAT = 'No Data Found'
											then	'50'
											else	'01'
									end 
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('HIGHBP','CBP') and
		DTTYPE = 'HIGHBPHTN'




truncate table MedicalRecordCBP_Excl

insert into MedicalRecordCBP_Excl
select	PursuitID				= b.PursuitID,
		PursuitEventID			= b.PursuitEventID,
		CBP_MR_ExclusionFlag	=	case	when	Exclusion = '-1'
											then	1
											when	Exclusion = '1'
											then	1
											else	0 
									end,
		CBP_ExclESRDFlag		= 0,
		CBP_ExclPregFlag		= 0,
		CBP_ExclNonAcuteFlag	= 0
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE = 'HIGHBP' and
		Exclusion in ('1','-1')








truncate table MedicalRecordCBP_BPNum

insert into MedicalRecordCBP_BPNum
select	PursuitID				= b.PursuitID,
		PursuitEventID			= b.PursuitEventID,
		CBP_MR_NumeratorFlag	= case	when	RESULT1 < 140 and
												RESULT2 < 90
										then	1
										else	0
								  end,
		CBP_SystolicLevel		= RESULT1,
		CBP_DiastolicLevel		= RESULT2
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE = 'HIGHBP' and
		DTTYPE = 'HIGHBPCTL'








truncate table MedicalRecordCMC

insert into MedicalRecordCMC
select	PursuitID					= b.PursuitID,
		PursuitEventID				= b.PursuitEventID,
		CMC_MR_LDLTestFlag			= 1,
		CMC_MR_LDLTestResult		= RESULT1,
		CMC_MR_LDLTestResultEmptyFlag = 0,
		CMC_LDLTotalCholesterolMethodFlag = 0,
		CMC_TotalCholesterolLevel	= 0,
		CMC_HDLLevel				= 0,
		CMC_TriglyceridesLevel		= 0,
		CMC_LipoproteinLevel		= 0,
		CBP_MR_SampleVoidFlag		=	case	when	Exclusion = '-1'
												then	1
												else	0 
										end,
		CBP_SampleVoidReason		= left(ExclusionRsn,40),
		CBP_MR_PursuitStatus	=	case	when	CHARTSTAT = 'Data Found'
											then	'10'
											when	CHARTSTAT = 'Chart Unavailable'
											then	'51'
											when	CHARTSTAT = 'Enrollee Unknown'
											then	'52'
											when	CHARTSTAT = 'No Data Found'
											then	'50'
											else	'01'
									end 
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('choles','CMC')







truncate table MedicalRecordPPC

insert into MedicalRecordPPC
select	PursuitID						= b.PursuitID,
		PursuitEventID					= b.PursuitEventID,
		PPC_MR_PrenatalNumeratorFlag	= 0,
		PPC_MR_PostPartumNumeratorFlag	= 0,
		PPC_ServProvType				=	case	when	PROVTYPE = '1'
													then	'PCP'
													when	PROVTYPE in ('2','3')
													then	'OBGYN'
											end,
		PPC_PreOBGVisitFlag				= 0,
		PPC_PreOBGVisitSource			=	case	when	FETHEART = 1
													then	'Evidence 01' --Exam with Fetal Heart Tone
													when	PEXAM = 1
													then	'Evidence 02' --Pelvic Exam
													when	FUNDUS = 1
													then	'Evidence 03' --Fundus Height
													when	OBPANEL = 1
													then	'Evidence 04' --Obs Panel
													when	RUBELLA = 1 and RH = 1 and ABO = 1
													then	'Evidence 05' --Rubella antibody
													when	TORCH = 1
													then	'Evidence 06' --TORCH
													when	SONO = 1
													then	'Evidence 07' --Echography
													when	(LMP = 1 and RISKASSESS = 1 and COUNSEL = 1) or
															(LMP = 1 and OBHIST = 1)
													then	'Evidence 08' --Complete Obs History
													when	(EDD = 1 and RISKASSESS = 1 and COUNSEL = 1) or
															(EDD = 1 and OBHIST = 1)
													then	'Evidence 09' --Prenatal Risk Assessment
											end,
		PPC_PrePCPVisitFlag				= 0,
		PPC_PrePCPVisitDiagFlag			= PREGDX,
		PPC_PrePCPVisitSource			=	case	when	FETHEART = 1
													then	'Evidence 01' --Exam with Fetal Heart Tone
													when	PEXAM = 1
													then	'Evidence 02' --Pelvic Exam
													when	FUNDUS = 1
													then	'Evidence 03' --Fundus Height
													when	OBPANEL = 1
													then	'Evidence 04' --Obs Panel
													when	RUBELLA = 1 and RH = 1 and ABO = 1
													then	'Evidence 05' --Rubella antibody
													when	TORCH = 1
													then	'Evidence 06' --TORCH
													when	SONO = 1
													then	'Evidence 07' --Echography
													when	(LMP = 1 and RISKASSESS = 1 and COUNSEL = 1) or
															(LMP = 1 and OBHIST = 1)
													then	'Evidence 08' --Complete Obs History
													when	(EDD = 1 and RISKASSESS = 1 and COUNSEL = 1) or
															(EDD = 1 and OBHIST = 1)
													then	'Evidence 09' --Prenatal Risk Assessment
											end,

		PPC_PostpartVisitFlag			= 0,
		PPC_PostpartVisitSource			= 0,
		PPC_MR_SampleVoidFlag			=	case	when	Exclusion = '-1'
													then	1
													else	0 
											end,
		PPC_SampleVoidReason			= left(ExclusionRsn,40),
		PPC_MR_PursuitStatus			=	case	when	CHARTSTAT = 'Data Found'
													then	'10'
													when	CHARTSTAT = 'Chart Unavailable'
													then	'51'
													when	CHARTSTAT = 'Enrollee Unknown'
													then	'52'
													when	CHARTSTAT = 'No Data Found'
													then	'50'
													else	'01'
											end 
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('prenatal','PPC')



insert into MedicalRecordPPC
select	PursuitID						= b.PursuitID,
		PursuitEventID					= b.PursuitEventID,
		PPC_MR_PrenatalNumeratorFlag	= 0,
		PPC_MR_PostPartumNumeratorFlag	= 0,
		PPC_ServProvType				= 0,
		PPC_PreOBGVisitFlag				= 0,
		PPC_PreOBGVisitSource			= 0,
		PPC_PrePCPVisitFlag				= 0,
		PPC_PrePCPVisitDiagFlag			= 0,
		PPC_PrePCPVisitSource			= 0,
		PPC_PostpartVisitFlag			= 0,
		PPC_PostpartVisitSource			=	case	when	PELVICEXAM = 1
													then	'Evidence 01'
													when	BPBRABEXAM = 1
													then	'Evidence 02'
													when	EXAM = 1
													then	'Evidence 03'
											end,
		PPC_MR_SampleVoidFlag			=	case	when	Exclusion = '-1'
													then	1
													else	0 
											end,
		PPC_SampleVoidReason			= left(ExclusionRsn,40),
		PPC_MR_PursuitStatus			=	case	when	CHARTSTAT = 'Data Found'
													then	'10'
													when	CHARTSTAT = 'Chart Unavailable'
													then	'51'
													when	CHARTSTAT = 'Enrollee Unknown'
													then	'52'
													when	CHARTSTAT = 'No Data Found'
													then	'50'
													else	'01'
											end 
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('postpard','PPC')







IF OBJECT_ID('tempdb..#single_shot_xref') is not null
    DROP TABLE #single_shot_xref

create table #single_shot_xref
(		compound_shot	varchar(50),
		single_shot		varchar(50) )

insert into #single_shot_xref
select	'DTaP',						'DTaP'							union all --standard
select	'Diphtheria',				'Diphtheria'					union all --standard
select	'Tetanus',					'Tetanus'						union all --standard
select	'Acellular pertussis',		'Acellular pertussis'			union all --standard
select	'DT',						'Diphtheria'					union all
select	'DT',						'Tetanus'						union all
select	'Trihibit',					'DTaP'							union all
select	'Trihibit',					'HiB'							union all
select	'Pediarix',					'DTaP'							union all
select	'Pediarix',					'IPV'							union all
select	'Pediarix',					'Hepatitis B'					union all
select	'Tripedia',					'DTaP'							union all
select	'DTP',						'DTaP'							union all
select	'DTP+',						'DTaP'							union all
select	'Pertussis',				'Acellular pertussis'			union all
select	'HiB',						'HiB'							union all --standard
select	'Comvax',					'HiB'							union all
select	'Comvax',					'Hepatitis B'					union all
select	'MMR',						'MMR'							union all --standard
select	'Measles',					'Measles'						union all --standard
select	'Mumps',					'Mumps'							union all --standard
select	'Rubella',					'Rubella'						union all --standard
select	'Proquad',					'MMR'							union all
select	'Proquad',					'VZV'							union all
select	'VZV',						'VZV'							union all --standard
select	'Varicella',				'VZV'							union all
select	'VariVax',					'VZV'							union all
select	'VariVax',					'IPV'							union all
select	'IPV',						'IPV'							union all --standard
select	'HepB',						'Hepatitis B'					union all
select	'Pneumo',					'Pneumococcal conjugate'		union all
select	'Prevnar',					'Pneumococcal conjugate'


truncate table MedicalRecordCIS

insert into MedicalRecordCIS
select	PursuitID						= b.PursuitID,
		PursuitEventID					= b.PursuitEventID,

		CIS_ImmunizationType			= d.single_shot,
		CIS_MR_NumeratorEventFlag		= 1,
		CIS_MR_NumeratorEvidenceFlag	= 0,
		CIS_MR_ExclusionFlag			=	case	when	Exclusion = '-1'
													then	1
													else	0 
											end,


		CIS_IMMEventFlag				= 1,
		CIS_HistIllnessFlag				= 0,
		CIS_SeroposResultFlag			= 0,
		CIS_ExclContrFlag				= 0,

		CIS_MR_SampleVoidFlag	=	case	when	Exclusion = '-1'
											then	1
											else	0 
									end,
		CIS_SampleVoidReason	= left(ExclusionRsn,40),
		CIS_MR_PursuitStatus	=	case	when	CHARTSTAT = 'Data Found'
											then	'10'
											when	CHARTSTAT = 'Chart Unavailable'
											then	'51'
											when	CHARTSTAT = 'Enrollee Unknown'
											then	'52'
											when	CHARTSTAT = 'No Data Found'
											then	'50'
											else	'01'
									end 
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		inner join #single_shot_xref d on
			a.SHOTTYPE = d.compound_shot
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('pneumo','pneumo','hib','dtp','polio','pox','mmr','CIS','hepb')
union all
select	PursuitID						= b.PursuitID,
		PursuitEventID					= b.PursuitEventID,

		CIS_ImmunizationType			=	case	when	SHOTTYPE = 'Measles History'
													then	'Measles'
													when	SHOTTYPE = 'Measles Seropositive Test Result'
													then	'Measles'
													when	SHOTTYPE = 'Mumps History'
													then	'Mumps'
													when	SHOTTYPE = 'Mumps Seropositive Test Result'
													then	'Mumps'
													when	SHOTTYPE = 'Rubella History'
													then	'Rubella'
													when	SHOTTYPE = 'Rubella Seropositive Test Result'
													then	'Rubella'
													when	SHOTTYPE = 'ChickenPox History'
													then	'VZV'
													when	SHOTTYPE = 'Seropositive Test Result' and SERVTYPE = 'pox'
													then	'VZV'
													when	SHOTTYPE = 'HepB History'
													then	'Hepititis B'
													when	SHOTTYPE = 'Seropositive Test Result' and SERVTYPE = 'hepb'
													then	'Hepititis B'
											end,
		CIS_MR_NumeratorEventFlag		= 0,
		CIS_MR_NumeratorEvidenceFlag	= 1,
		CIS_MR_ExclusionFlag			=	case	when	Exclusion = '-1'
													then	1
													else	0 
											end,


		CIS_IMMEventFlag				= 0,
		CIS_HistIllnessFlag				= case	when	SHOTTYPE = 'Measles History'
													then	1
													when	SHOTTYPE = 'Measles Seropositive Test Result'
													then	0
													when	SHOTTYPE = 'Mumps History'
													then	1
													when	SHOTTYPE = 'Mumps Seropositive Test Result'
													then	0
													when	SHOTTYPE = 'Rubella History'
													then	1
													when	SHOTTYPE = 'Rubella Seropositive Test Result'
													then	0
													when	SHOTTYPE = 'ChickenPox History'
													then	1
													when	SHOTTYPE = 'Seropositive Test Result' and SERVTYPE = 'pox'
													then	0
													when	SHOTTYPE = 'HepB History'
													then	1
													when	SHOTTYPE = 'Seropositive Test Result' and SERVTYPE = 'hepb'
													then	0
											end,
		CIS_SeroposResultFlag			= case	when	SHOTTYPE = 'Measles History'
													then	0
													when	SHOTTYPE = 'Measles Seropositive Test Result'
													then	1
													when	SHOTTYPE = 'Mumps History'
													then	0
													when	SHOTTYPE = 'Mumps Seropositive Test Result'
													then	1
													when	SHOTTYPE = 'Rubella History'
													then	0
													when	SHOTTYPE = 'Rubella Seropositive Test Result'
													then	1
													when	SHOTTYPE = 'ChickenPox History'
													then	0
													when	SHOTTYPE = 'Seropositive Test Result' and SERVTYPE = 'pox'
													then	1
													when	SHOTTYPE = 'HepB History'
													then	0
													when	SHOTTYPE = 'Seropositive Test Result' and SERVTYPE = 'hepb'
													then	1
											end,
		CIS_ExclContrFlag				= 0,

		CIS_MR_SampleVoidFlag	=	case	when	Exclusion = '-1'
											then	1
											else	0 
									end,
		CIS_SampleVoidReason	= left(ExclusionRsn,40),
		CIS_MR_PursuitStatus	=	case	when	CHARTSTAT = 'Data Found'
											then	'10'
											when	CHARTSTAT = 'Chart Unavailable'
											then	'51'
											when	CHARTSTAT = 'Enrollee Unknown'
											then	'52'
											when	CHARTSTAT = 'No Data Found'
											then	'50'
											else	'01'
									end 
from	#NUM01 a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('pneumo','pneumo','hib','dtp','polio','pox','mmr','CIS','hepb') and
		not exists (	select *
						from	#single_shot_xref d 
						where	a.SHOTTYPE = d.compound_shot)









truncate table MedicalRecordCDC_HbA1C

insert into MedicalRecordCDC_HbA1C
select	PursuitID					= b.PursuitID,
		PursuitEventID				= b.PursuitEventID,
		CMC_MR_HbA1CEventFlag		= 1,
		CMC_MR_HbA1CResult			= RESULT1,
		CMC_MR_HbA1CResultEmptyFlag = 0,
		CDC_MR_SampleVoidFlag		=	case	when	Exclusion = '-1'
												then	1
												else	0 
										end,
		CDC_SampleVoidReason		= left(ExclusionRsn,40),
		CDC_MR_PursuitStatus	=	case	when	CHARTSTAT = 'Data Found'
											then	'10'
											when	CHARTSTAT = 'Chart Unavailable'
											then	'51'
											when	CHARTSTAT = 'Enrollee Unknown'
											then	'52'
											when	CHARTSTAT = 'No Data Found'
											then	'50'
											else	'01'
									end 
from	#Diabnum a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('CDC') or
		DTTYPE in ('HbA1c')






truncate table MedicalRecordCDC_Eye

insert into MedicalRecordCDC_Eye
select	PursuitID						= b.PursuitID,
		PursuitEventID					= b.PursuitEventID,

		CMC_MR_EyeExamNumFlag			=	case	when	DIABRET in ('Yes','No','?') and
															MR_ServiceDate between '01/01/2007' and '12/31/2007'
													then	1 
													when	DIABRET in ('No') and
															MR_ServiceDate between '01/01/2006' and '12/31/2006'
													then	1 
													else	0
											end,
		CMC_MR_EyeRetEvalFlag			=	case	when	DIABRET in ('Yes','No','?') and
															MR_ServiceDate between '01/01/2007' and '12/31/2007'
													then	1 
													else	0
											end,
		CMC_MR_EyeNegRetExamPriorFlag	=	case	when	DIABRET in ('No') and
															MR_ServiceDate between '01/01/2006' and '12/31/2006'
													then	1 
													else	0
											end,
		CMC_MR_EyeRetEvalResults		= '',
		CMC_MR_EyeRetEvalProv			= '',
		CMC_MR_EyeChartPhotoAbnFlag		= 0,
		CMC_MR_EyeNoteOphtExamFlag		= 0,

		CDC_MR_SampleVoidFlag		=	case	when	Exclusion = '-1'
												then	1
												else	0 
										end,
		CDC_SampleVoidReason		= left(ExclusionRsn,40),
		CDC_MR_PursuitStatus	=	case	when	CHARTSTAT = 'Data Found'
											then	'10'
											when	CHARTSTAT = 'Chart Unavailable'
											then	'51'
											when	CHARTSTAT = 'Enrollee Unknown'
											then	'52'
											when	CHARTSTAT = 'No Data Found'
											then	'50'
											else	'01'
									end 
from	#Diabnum a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('CDC') or
		DTTYPE in ('Eye Exam')





truncate table MedicalRecordCDC_LDL

insert into MedicalRecordCDC_LDL
select	PursuitID							= b.PursuitID,
		PursuitEventID						= b.PursuitEventID,

		CDC_MR_LDLTestFlag					= 1,
		CDC_MR_LDLTestResult				= RESULT1,
		CDC_MR_LDLTestResultEmptyFlag		= 0,
		CDC_LDLTotalCholesterolMethodFlag	= 0,
		CDC_TotalCholesterolLevel			= 0,
		CDC_HDLLevel						= 0,
		CDC_TriglyceridesLevel				= 0,
		CDC_LipoproteinLevel				= 0,

		CDC_MR_SampleVoidFlag		=	case	when	Exclusion = '-1'
												then	1
												else	0 
										end,
		CDC_SampleVoidReason		= left(ExclusionRsn,40),
		CDC_MR_PursuitStatus	=	case	when	CHARTSTAT = 'Data Found'
											then	'10'
											when	CHARTSTAT = 'Chart Unavailable'
											then	'51'
											when	CHARTSTAT = 'Enrollee Unknown'
											then	'52'
											when	CHARTSTAT = 'No Data Found'
											then	'50'
											else	'01'
									end 
from	#Diabnum a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('CDC') or
		DTTYPE in ('LDL-C')






truncate table MedicalRecordCDC_Neph

insert into MedicalRecordCDC_Neph
select	PursuitID							= b.PursuitID,
		PursuitEventID						= b.PursuitEventID,

		CDC_MR_NephNumeratorFlag			=	case	when	DTTYPE = 'Quantitative' and
																RESULT1 in ('microalb +','microalb -')
														then	1
														when	DTTYPE = 'NephroVisit'
														then	1
														when	DTTYPE = 'Nephropathy'
														then	1
														when	DTTYPE = 'Qualitative' and
																RESULT1 = 'macroalb +'
														then	1
														when	DTTYPE = 'ACEARB'
														then	1
														else	0
												end,

		CDC_MR_NephScreenFlag				=	case	when	DTTYPE = 'Quantitative' and
																RESULT1 in ('microalb +','microalb -')
														then	1
														else	0
												end,
		CDC_MR_NephScreenResult				= '',
		CDC_MR_NephScreenSource				= '',
		CDC_MR_NephEvidNephVisitFlag		=	case	when	DTTYPE = 'NephroVisit'
														then	1
														else	0
												end,
		CDC_MR_NephMedAttnFlag				=	case	when	DTTYPE = 'Nephropathy'
														then	1
														else	0
												end,
		CDC_MR_NephMedAttnCond				= '',

		CDC_MR_NephEvidPosUrMacFlag			=	case	when	DTTYPE = 'Qualitative' and
																RESULT1 = 'macroalb +'
														then	1
														else	0
												end,
		CDC_MR_NephEvidPosUrMacSource		= '',
		CDC_MR_NephEvidPosUrMacResult		= '',

		CDC_MR_NephEvidAceArbFlag			=	case	when	DTTYPE = 'ACEARB'
														then	1
														else	0
												end,


		CDC_MR_SampleVoidFlag		=	case	when	Exclusion = '-1'
												then	1
												else	0 
										end,
		CDC_SampleVoidReason		= left(ExclusionRsn,40),
		CDC_MR_PursuitStatus	=	case	when	CHARTSTAT = 'Data Found'
											then	'10'
											when	CHARTSTAT = 'Chart Unavailable'
											then	'51'
											when	CHARTSTAT = 'Enrollee Unknown'
											then	'52'
											when	CHARTSTAT = 'No Data Found'
											then	'50'
											else	'01'
									end 
from	#Diabnum a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('CDC') or
		DTTYPE in (	'NephroVisit',
					'Qualitative',
					'Quantitative',
					'Nephropathy',
					'ACEARB')







truncate table MedicalRecordCDC_BP

insert into MedicalRecordCDC_BP
select	PursuitID				= b.PursuitID,
		PursuitEventID			= b.PursuitEventID,
		CDC_MR_NumeratorFlag	= case	when	case when isnumeric(RESULT1)=1 then RESULT1 else null end < 140 and
												case when isnumeric(RESULT2)=1 then RESULT2 else null end < 90
										then	1
										else	0
								  end,
		CDC_SystolicLevel		= case when isnumeric(RESULT1)=1 then RESULT1 else null end,
		CDC_DiastolicLevel		= case when isnumeric(RESULT2)=1 then RESULT2 else null end 
from	#Diabnum a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	SERVTYPE in ('CDC') or
		DTTYPE in ('BP')






truncate table MedicalRecordCDC_Excl

insert into MedicalRecordCDC_Excl
select	PursuitID				= b.PursuitID,
		PursuitEventID			= b.PursuitEventID,
		CDC_MR_ExclusionFlag	=	case	when	Exclusion = '-1'
											then	1
											when	Exclusion = '1'
											then	1
											else	0 
									end,
		CDC_ExclPolycyOvarFlag	= 0,
		CDC_ExclGestDiabFlag	= 0,
		CDC_ExclSteroidIndFlag	= 0
from	#Diabnum a
		inner join PursuitEvent b on
			a.s_GUID = b.SourcePK1
		left join #PursuitEventMax c on
			b.PursuitEventID = c.PursuitEventID
where	--SERVTYPE in ('CDC') and
		Exclusion in ('1','-1')




--
--DTTYPE
-----------------
--Eye Exam
--HbA1c
--NULL
--BP
--LDL-C
--
--Quantitative
--ACEARB
--
--(7 row(s) affected)






/*
SERVTYPE   
---------- -----------
HIGHBP     60

choles     5

ppd        17
pox        20
mmr        9
pneumo     38
polio      29
dtp        34
hib        30
pneumo       37

prenatal   19
postpard   4

adolescent 407
wcv1221    25
wcv3456    20
lead       28
wcv15      264
cerv       0
*/


--		union all select	'01', 'Not Pursued'
--		union all select	'10', 'Pursued-Reviewed'
--		union all select	'50', 'Pursued-No Data Found'
--		union all select	'51', 'Pursued-Chart Unavailable'
--		union all select	'52', 'Pursued-Enrollee Unknown'



--IF OBJECT_ID('tempdb..#dw_hedis_claim_hdr') is not null
--    DROP TABLE #dw_hedis_claim_hdr
--
--CREATE TABLE #dw_hedis_claim_hdr(
--	dw_hedis_claim_hdr_key int IDENTITY(1,1) NOT NULL,
--	claim_src varchar(50) NOT NULL,
--	claim_pk1 varchar(50) NOT NULL,
--	claim_pk2 varchar(50) NULL,
--	claim_pk3 varchar(50) NULL,
--	claim_pk4 varchar(50) NULL,
--	claim_pk5 varchar(50) NULL,
--	claim_pk6 varchar(50) NULL,
--	claim_pk7 varchar(50) NULL,
--	claim_pk8 varchar(50) NULL,
--	claim_pk9 varchar(50) NULL,
--	claim_pk10 varchar(50) NULL,
--	claim_type varchar(20) NULL
--) 
--
--
--IF OBJECT_ID('tempdb..#dw_hedis_claim_dtl') is not null
--    DROP TABLE #dw_hedis_claim_dtl
--
--CREATE TABLE #dw_hedis_claim_dtl(
--	dw_hedis_claim_dtl_key int IDENTITY(1,1) NOT NULL,
--	dw_hedis_claim_hdr_key int NOT NULL,
--	claim_src varchar(50) NOT NULL,
--	claim_pk1 varchar(50) NOT NULL,
--	claim_pk2 varchar(50) NULL,
--	claim_pk3 varchar(50) NULL,
--	claim_pk4 varchar(50) NULL,
--	claim_pk5 varchar(50) NULL,
--	claim_pk6 varchar(50) NULL,
--	claim_pk7 varchar(50) NULL,
--	claim_pk8 varchar(50) NULL,
--	claim_pk9 varchar(50) NULL,
--	claim_pk10 varchar(50) NULL,
--	claim_type varchar(20) NULL
--)

delete dw_hedis_claim_hdr
where	claim_src = 'Pursuit'

insert into dw_hedis_claim_hdr
(		claim_src,
		claim_pk1,
		claim_type)
select	claim_src				= 'Pursuit',
		claim_pk1				= PursuitID,
		claim_type				= 'MR'
from	Pursuit


delete dw_hedis_claim_dtl
where	claim_src = 'PursuitEvent'

insert into dw_hedis_claim_dtl
(		dw_hedis_claim_hdr_key,
		claim_src,
		claim_pk1,
		claim_type)
select	dw_hedis_claim_hdr_key	= dw_hedis_claim_hdr_key,
		claim_src				= 'PursuitEvent',
		claim_pk1				= PursuitEventID,
		claim_type				= 'MR' 
from	PursuitEvent a
		inner join dw_hedis_claim_hdr b on
			b.claim_src = 'Pursuit' and
			a.PursuitID = b.claim_pk1




truncate table dw_hedis_mr_pursuit_event

insert into dw_hedis_mr_pursuit_event
select	dw_hedis_claim_hdr_key	= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key	= e.dw_hedis_claim_dtl_key,
		ihds_member_id			= d.ihds_member_id,
		ihds_prov_id			= '',
		service_date			= MR_ServiceDate,
		PursuitStatus			= PursuitStatus
from	Pursuit a
		inner join PursuitEvent b on
			a.PursuitID = b.PursuitID
		inner join Member d on
			a.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			b.PursuitEventID = e.claim_pk1



truncate table dw_hedis_mr_awc

insert into dw_hedis_mr_awc
select	dw_hedis_claim_hdr_key	= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key	= e.dw_hedis_claim_dtl_key,
		ihds_member_id			= d.ihds_member_id,
		ihds_prov_id			= '',
		service_date			= MR_ServiceDate,
		AWC_MR_NumeratorFlag	= AWC_MR_NumeratorFlag,
		AWC_HlthDevFlag			= AWC_HlthDevFlag,
		AWC_HlthDevPhysFlag		= AWC_HlthDevPhysFlag,
		AWC_HlthDevMntlFlag		= AWC_HlthDevMntlFlag,
		AWC_PhysExamFlag		= AWC_PhysExamFlag,
		AWC_HlthEducFlag		= AWC_HlthEducFlag,
		AWC_MR_SampleVoidFlag	= AWC_MR_SampleVoidFlag,
		AWC_SampleVoidReason	= AWC_SampleVoidReason,
		AWC_MR_PursuitStatus	= AWC_MR_PursuitStatus
from	MedicalRecordAWC a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1






truncate table dw_hedis_mr_w34

insert into dw_hedis_mr_w34
select	dw_hedis_claim_hdr_key	= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key	= e.dw_hedis_claim_dtl_key,
		ihds_member_id			= d.ihds_member_id,
		ihds_prov_id			= '',
		service_date			= MR_ServiceDate,
		W34_MR_NumeratorFlag	= W34_MR_NumeratorFlag,
		W34_HlthDevFlag			= W34_HlthDevFlag,
		W34_HlthDevPhysFlag		= W34_HlthDevPhysFlag,
		W34_HlthDevMntlFlag		= W34_HlthDevMntlFlag,
		W34_PhysExamFlag		= W34_PhysExamFlag,
		W34_HlthEducFlag		= W34_HlthEducFlag,
		W34_MR_SampleVoidFlag	= W34_MR_SampleVoidFlag,
		W34_SampleVoidReason	= W34_SampleVoidReason,
		W34_MR_PursuitStatus	= W34_MR_PursuitStatus
from	MedicalRecordW34 a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1






truncate table dw_hedis_mr_lsc

insert into dw_hedis_mr_lsc
select	dw_hedis_claim_hdr_key	= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key	= e.dw_hedis_claim_dtl_key,
		ihds_member_id			= d.ihds_member_id,
		ihds_prov_id			= '',
		service_date			= MR_ServiceDate,
		LSC_MR_NumeratorFlag	= LSC_MR_NumeratorFlag,
		LSC_LeadTestFlag		= LSC_LeadTestFlag,
		LSC_LeadTestResult		= LSC_LeadTestResult,
		LSC_MR_SampleVoidFlag	= LSC_MR_SampleVoidFlag,
		LSC_SampleVoidReason	= LSC_SampleVoidReason,
		LSC_MR_PursuitStatus	= LSC_MR_PursuitStatus
from	MedicalRecordLSC a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1






truncate table dw_hedis_mr_w15

insert into dw_hedis_mr_w15
select	dw_hedis_claim_hdr_key	= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key	= e.dw_hedis_claim_dtl_key,
		ihds_member_id			= d.ihds_member_id,
		ihds_prov_id			= '',
		service_date			= MR_ServiceDate,
		W15_MR_NumeratorFlag	= W15_MR_NumeratorFlag,
		W15_HlthDevFlag			= W15_HlthDevFlag,
		W15_HlthDevPhysFlag		= W15_HlthDevPhysFlag,
		W15_HlthDevMntlFlag		= W15_HlthDevMntlFlag,
		W15_PhysExamFlag		= W15_PhysExamFlag,
		W15_HlthEducFlag		= W15_HlthEducFlag,
		W15_MR_SampleVoidFlag	= W15_MR_SampleVoidFlag,
		W15_SampleVoidReason	= W15_SampleVoidReason,
		W15_MR_PursuitStatus	= W15_MR_PursuitStatus
from	MedicalRecordW15 a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1





truncate table dw_hedis_mr_ccs

insert into dw_hedis_mr_ccs
select	dw_hedis_claim_hdr_key	= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key	= e.dw_hedis_claim_dtl_key,
		ihds_member_id			= d.ihds_member_id,
		ihds_prov_id			= '',
		service_date			= MR_ServiceDate,
		CCS_MR_NumeratorFlag	= CCS_MR_NumeratorFlag,
		CCS_MR_ExclusionFlag	= CCS_MR_ExclusionFlag,
		CCS_PapTestFlag			= CCS_PapTestFlag,
		CCS_PapTestResult		= CCS_PapTestResult,
		CCS_ExclHystNoCervixFlag = CCS_ExclHystNoCervixFlag,
		CCS_ExclHystVagPapFlag	= CCS_ExclHystVagPapFlag,
		CCS_MR_SampleVoidFlag	= CCS_MR_SampleVoidFlag,
		CCS_SampleVoidReason	= CCS_SampleVoidReason,
		CCS_MR_PursuitStatus	=CCS_MR_PursuitStatus
from	MedicalRecordCCS a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1





truncate table dw_hedis_mr_apc

insert into dw_hedis_mr_apc
select	dw_hedis_claim_hdr_key	= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key	= e.dw_hedis_claim_dtl_key,
		ihds_member_id			= d.ihds_member_id,
		ihds_prov_id			= '',
		service_date			= MR_ServiceDate,
		APC_DTTYPE				= APC_DTTYPE,
		APC_RESULT1				= APC_RESULT1,
		APC_PASS				= APC_PASS,
		APC_MR_SampleVoidFlag	= APC_MR_SampleVoidFlag,
		APC_SampleVoidReason	= APC_SampleVoidReason,
		APC_MR_PursuitStatus	= APC_MR_PursuitStatus
from	MedicalRecordAPC a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1







truncate table dw_hedis_mr_cmc

insert into dw_hedis_mr_cmc
select	dw_hedis_claim_hdr_key		= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key		= e.dw_hedis_claim_dtl_key,
		ihds_member_id				= d.ihds_member_id,
		ihds_prov_id				= '',
		service_date				= MR_ServiceDate,
		CMC_MR_LDLTestFlag			= CMC_MR_LDLTestFlag,
		CMC_MR_LDLTestResult		= CMC_MR_LDLTestResult,
		CMC_LDLTotalCholesterolMethodFlag	= CMC_LDLTotalCholesterolMethodFlag,
		CMC_TotalCholesterolLevel	= CMC_TotalCholesterolLevel,
		CMC_HDLLevel				= CMC_HDLLevel,
		CMC_TriglyceridesLevel		= CMC_TriglyceridesLevel,
		CMC_LipoproteinLevel		= CMC_LipoproteinLevel,
		CMC_MR_SampleVoidFlag		= CMC_MR_SampleVoidFlag,
		CMC_SampleVoidReason		= CMC_SampleVoidReason,
		CMC_MR_PursuitStatus		= CMC_MR_PursuitStatus
from	MedicalRecordCMC a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1








truncate table dw_hedis_mr_cbp_dx_conf

insert into dw_hedis_mr_cbp_dx_conf
select	dw_hedis_claim_hdr_key		= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key		= e.dw_hedis_claim_dtl_key,
		ihds_member_id				= d.ihds_member_id,
		ihds_prov_id				= '',
		service_date				= MR_ServiceDate,
		CBP_ConfHTNFlag				= CBP_ConfHTNFlag,
		CBP_ConfHighBPFlag			= CBP_ConfHighBPFlag,
		CBP_ConfEleBPFlag			= CBP_ConfEleBPFlag,
		CBP_ConfBordHTNFlag			= CBP_ConfBordHTNFlag,
		CBP_ConfIntHTNFlag			= CBP_ConfIntHTNFlag,
		CBP_ConfHistHTNFlag			= CBP_ConfHistHTNFlag,
		CBP_ConfHVDFlag				= CBP_ConfHVDFlag,
		CBP_ConfHypiaFlag			= CBP_ConfHypiaFlag,
		CBP_ConfHypisFlag			= CBP_ConfHypisFlag,
		CBP_ConfNotationSource		= CBP_ConfNotationSource,
		CBP_MR_SampleVoidFlag		= CBP_MR_SampleVoidFlag,
		CBP_SampleVoidReason		= CBP_SampleVoidReason,
		CBP_MR_PursuitStatus		= CBP_MR_PursuitStatus
from	MedicalRecordCBP_DxConf a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1







truncate table dw_hedis_mr_cbp_excl

insert into dw_hedis_mr_cbp_excl
select	dw_hedis_claim_hdr_key		= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key		= e.dw_hedis_claim_dtl_key,
		ihds_member_id				= d.ihds_member_id,
		ihds_prov_id				= '',
		service_date				= MR_ServiceDate,
		CBP_MR_ExclusionFlag		= CBP_MR_ExclusionFlag,
		CBP_ExclESRDFlag			= CBP_ExclESRDFlag,
		CBP_ExclPregFlag			= CBP_ExclPregFlag,
		CBP_ExclNonAcuteFlag		= CBP_ExclNonAcuteFlag
from	MedicalRecordCBP_Excl a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1




truncate table dw_hedis_mr_cbp_num

insert into dw_hedis_mr_cbp_num
select	dw_hedis_claim_hdr_key		= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key		= e.dw_hedis_claim_dtl_key,
		ihds_member_id				= d.ihds_member_id,
		ihds_prov_id				= '',
		service_date				= MR_ServiceDate,
		CBP_MR_NumeratorFlag		= CBP_MR_NumeratorFlag,
		CBP_SystolicLevel			= CBP_SystolicLevel,
		CBP_DiastolicLevel			= CBP_DiastolicLevel
from	MedicalRecordCBP_BPNum a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1










truncate table dw_hedis_mr_ppc

insert into dw_hedis_mr_ppc
select	dw_hedis_claim_hdr_key		= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key		= e.dw_hedis_claim_dtl_key,
		ihds_member_id				= d.ihds_member_id,
		ihds_prov_id				= '',
		service_date				= MR_ServiceDate,
		PPC_MR_PrenatalNumeratorFlag		= PPC_MR_PrenatalNumeratorFlag,
		PPC_MR_PostPartumNumeratorFlag		= PPC_MR_PostPartumNumeratorFlag,
		PPC_ServProvType			= PPC_ServProvType,
		PPC_PreOBGVisitFlag			= PPC_PreOBGVisitFlag,
		PPC_PreOBGVisitSource		= PPC_PreOBGVisitSource,
		PPC_PrePCPVisitFlag			= PPC_PrePCPVisitFlag,
		PPC_PrePCPVisitDiagFlag		= PPC_PrePCPVisitDiagFlag,
		PPC_PrePCPVisitSource		= PPC_PrePCPVisitSource,
		PPC_PostpartVisitFlag		= PPC_PostpartVisitFlag,
		PPC_PostpartVisitSource		= PPC_PostpartVisitSource,
		PPC_MR_SampleVoidFlag		= PPC_MR_SampleVoidFlag,
		PPC_SampleVoidReason		= PPC_SampleVoidReason,
		PPC_MR_PursuitStatus		= PPC_MR_PursuitStatus
from	MedicalRecordPPC a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1










truncate table dw_hedis_mr_cis

insert into dw_hedis_mr_cis
select	dw_hedis_claim_hdr_key			= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key			= e.dw_hedis_claim_dtl_key,
		ihds_member_id					= d.ihds_member_id,
		ihds_prov_id					= '',
		service_date					= MR_ServiceDate,
		CIS_ImmunizationType			= CIS_ImmunizationType,
		CIS_MR_NumeratorEventFlag		= CIS_MR_NumeratorEventFlag,
		CIS_MR_NumeratorEvidenceFlag	= CIS_MR_NumeratorEvidenceFlag,
		CIS_MR_ExclusionFlag			= CIS_MR_ExclusionFlag,
		CIS_IMMEventFlag				= CIS_IMMEventFlag,
		CIS_HistIllnessFlag				= CIS_HistIllnessFlag,
		CIS_SeroposResultFlag			= CIS_SeroposResultFlag,
		CIS_ExclContrFlag				= CIS_ExclContrFlag,
		CIS_MR_SampleVoidFlag			= CIS_MR_SampleVoidFlag,
		CIS_SampleVoidReason			= CIS_SampleVoidReason,
		CIS_MR_PursuitStatus			= CIS_MR_PursuitStatus
from	MedicalRecordCIS a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1







truncate table dw_hedis_mr_cdc_hba1c

insert into dw_hedis_mr_cdc_hba1c
select	dw_hedis_claim_hdr_key			= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key			= e.dw_hedis_claim_dtl_key,
		ihds_member_id					= d.ihds_member_id,
		ihds_prov_id					= '',
		service_date					= MR_ServiceDate,
		CMC_MR_HbA1CEventFlag			= CMC_MR_HbA1CEventFlag,
		CMC_MR_HbA1CResult				=	case	when patindex('%,%',CMC_MR_HbA1CResult) > 0 
													then null 
													when isnumeric(CMC_MR_HbA1CResult) = 1 
													then CMC_MR_HbA1CResult 
													else null 
											end,
		CMC_MR_HbA1CResultEmptyFlag		= CMC_MR_HbA1CResultEmptyFlag,
		CDC_MR_SampleVoidFlag			= CDC_MR_SampleVoidFlag,
		CDC_SampleVoidReason			= CDC_SampleVoidReason,
		CDC_MR_PursuitStatus			= CDC_MR_PursuitStatus
from	MedicalRecordCDC_HbA1C a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1




truncate table dw_hedis_mr_cdc_eye

insert into dw_hedis_mr_cdc_eye
select	dw_hedis_claim_hdr_key			= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key			= e.dw_hedis_claim_dtl_key,
		ihds_member_id					= d.ihds_member_id,
		ihds_prov_id					= '',
		service_date					= MR_ServiceDate,
		CMC_MR_EyeExamNumFlag			= CMC_MR_EyeExamNumFlag,
		CMC_MR_EyeRetEvalFlag			= CMC_MR_EyeRetEvalFlag,
		CMC_MR_EyeNegRetExamPriorFlag	= CMC_MR_EyeNegRetExamPriorFlag,
		CMC_MR_EyeRetEvalResults		= CMC_MR_EyeRetEvalResults,
		CMC_MR_EyeRetEvalProv			= CMC_MR_EyeRetEvalProv,
		CMC_MR_EyeChartPhotoAbnFlag		= CMC_MR_EyeChartPhotoAbnFlag,
		CMC_MR_EyeNoteOphtExamFlag		= CMC_MR_EyeNoteOphtExamFlag,
		CDC_MR_SampleVoidFlag			= CDC_MR_SampleVoidFlag,
		CDC_SampleVoidReason			= CDC_SampleVoidReason,
		CDC_MR_PursuitStatus			= CDC_MR_PursuitStatus
from	MedicalRecordCDC_Eye a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1






truncate table dw_hedis_mr_cdc_ldl

insert into dw_hedis_mr_cdc_ldl
select	dw_hedis_claim_hdr_key			= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key			= e.dw_hedis_claim_dtl_key,
		ihds_member_id					= d.ihds_member_id,
		ihds_prov_id					= '',
		service_date					= MR_ServiceDate,
		CDC_MR_LDLTestFlag				= CDC_MR_LDLTestFlag,
		CDC_MR_LDLTestResult			= CDC_MR_LDLTestResult,
		CDC_MR_LDLTestResultEmptyFlag	= CDC_MR_LDLTestResultEmptyFlag,
		CDC_LDLTotalCholesterolMethodFlag	= CDC_LDLTotalCholesterolMethodFlag,
		CDC_TotalCholesterolLevel		= CDC_TotalCholesterolLevel,
		CDC_HDLLevel					= CDC_HDLLevel,
		CDC_TriglyceridesLevel			= CDC_TriglyceridesLevel,
		CDC_LipoproteinLevel			= CDC_LipoproteinLevel,
		CDC_MR_SampleVoidFlag			= CDC_MR_SampleVoidFlag,
		CDC_SampleVoidReason			= CDC_SampleVoidReason,
		CDC_MR_PursuitStatus			= CDC_MR_PursuitStatus
from	MedicalRecordCDC_LDL a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1






truncate table dw_hedis_mr_cdc_neph

insert into dw_hedis_mr_cdc_neph
select	dw_hedis_claim_hdr_key			= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key			= e.dw_hedis_claim_dtl_key,
		ihds_member_id					= d.ihds_member_id,
		ihds_prov_id					= '',
		service_date					= MR_ServiceDate,
		CDC_MR_NephNumeratorFlag		= CDC_MR_NephNumeratorFlag,
		CDC_MR_NephScreenFlag			= CDC_MR_NephScreenFlag,
		CDC_MR_NephScreenResult			= CDC_MR_NephScreenResult,
		CDC_MR_NephScreenSource			= CDC_MR_NephScreenSource,
		CDC_MR_NephEvidNephVisitFlag	= CDC_MR_NephEvidNephVisitFlag,
		CDC_MR_NephMedAttnFlag			= CDC_MR_NephMedAttnFlag,
		CDC_MR_NephMedAttnCond			= CDC_MR_NephMedAttnCond,
		CDC_MR_NephEvidPosUrMacFlag		= CDC_MR_NephEvidPosUrMacFlag,
		CDC_MR_NephEvidPosUrMacSource	= CDC_MR_NephEvidPosUrMacSource,
		CDC_MR_NephEvidPosUrMacResult	= CDC_MR_NephEvidPosUrMacResult,
		CDC_MR_NephEvidAceArbFlag		= CDC_MR_NephEvidAceArbFlag,
		CDC_MR_SampleVoidFlag			= CDC_MR_SampleVoidFlag,
		CDC_SampleVoidReason			= CDC_SampleVoidReason,
		CDC_MR_PursuitStatus			= CDC_MR_PursuitStatus
from	MedicalRecordCDC_Neph a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1






truncate table dw_hedis_mr_cdc_bp

insert into dw_hedis_mr_cdc_bp
select	dw_hedis_claim_hdr_key			= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key			= e.dw_hedis_claim_dtl_key,
		ihds_member_id					= d.ihds_member_id,
		ihds_prov_id					= '',
		service_date					= MR_ServiceDate,
		CDC_MR_NumeratorFlag			= CDC_MR_NumeratorFlag,
		CDC_SystolicLevel			= CDC_SystolicLevel,
		CDC_DiastolicLevel			= CDC_DiastolicLevel
from	MedicalRecordCDC_BP a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1






truncate table dw_hedis_mr_cdc_excl

insert into dw_hedis_mr_cdc_excl
select	dw_hedis_claim_hdr_key			= e.dw_hedis_claim_hdr_key,
		dw_hedis_claim_dtl_key			= e.dw_hedis_claim_dtl_key,
		ihds_member_id					= d.ihds_member_id,
		ihds_prov_id					= '',
		service_date					= MR_ServiceDate,
		CDC_MR_ExclusionFlag			= CDC_MR_ExclusionFlag,
		CDC_ExclPolycyOvarFlag			= CDC_ExclPolycyOvarFlag,
		CDC_ExclGestDiabFlag			= CDC_ExclGestDiabFlag,
		CDC_ExclSteroidIndFlag			= CDC_ExclSteroidIndFlag
from	MedicalRecordCDC_Excl a
		inner join Pursuit b on
			a.PursuitID = b.PursuitID
		inner join PursuitEvent c on
			a.PursuitEventID = c.PursuitEventID
		inner join Member d on
			b.MemberID = d.MemberID
		inner join dw_hedis_claim_dtl e on
			e.claim_src = 'PursuitEvent' and
			a.PursuitEventID = e.claim_pk1









/*
select	convert(varchar(8),convert(datetime,b.LASTUPDATE),112),*
from	tblDenomHist b
where	SUBNO = '1032401'


select	SUBNO,
		PERSNO,
		UserName,
		CATEGORY,
		count(*)
from	tblDenomHist b
group by SUBNO,
		PERSNO,
		UserName,
		CATEGORY having count(*)>1

select	distinct CHARTSTAT
--select *
from	hh08_ihds_ds01..tblDenomHist b
where CHARTSTAT is null
where	SUBNO = '1009431' and
		PERSNO = '03' and
		UserName = 'jhaftel' and
		CATEGORY = 'WCV1221Y'

select	*
from	#NUM01 a
where	SUBNO = '1041572' and
		PERSNO = '03' and
		UserName = 'jhaftel'



select	convert(varchar(8),convert(datetime,a.LASTUPDTE),112),a.*
from	#NUM01 a
		left join hh08_ihds_ds01..tblDenomHist b on
			rtrim(a.SUBNO) = rtrim(b.SUBNO) and
			rtrim(a.PERSNO) = rtrim(b.PERSNO) and
			rtrim(a.UserName) = rtrim(b.UserName) and
			convert(varchar(8),convert(datetime,a.LASTUPDTE),112) = convert(varchar(8),convert(datetime,b.LASTUPDATE),112)
where	b.subno is null

 3/13/2008 14:00:59             dnichols 
*/





--*************************************************************************
--*************************************************************************
--Import data from MS Access DB:
--*************************************************************************
--*************************************************************************
/*
--create table:

use hh08_rdsm
--drop table dbo.NUM01
create table dbo.NUM01
(		SUBNO			varchar(12),
		PERSNO			varchar(2),
		SUBNOPERS		varchar(50),
		SERVDATE		varchar(30),
		LOB				varchar(3),
		s_GUID			varchar(50),
		DATASYS			varchar(10),
		DATASOURCE		varchar(6),
		HXOFDX			int,
		HXOFDXDESC		varchar(20),
		DEVHXPHY		int,
		DEVHXMNTL		int,
		EXAM			int,
		HEALTHED		int,
		POSTPARCTR		varchar(50),
		BPBRABEXAM		int,
		PELVICEXAM		int,
		PPDREAD			varchar(30),
		SERVTYPE		varchar(10),
		RESULT1			varchar(50),
		RESULT2			varchar(50),
		DTTYPE			varchar(10),
		SHOTTYPE		varchar(100),
		PANEL			varchar(3),
		PROVNAME		varchar(50),
		LASTUPDTE		varchar(30),
		UserName		varchar(50),
		TOBEDUC			int,
		TOBUSER			varchar(20),
		FETHEART		int,
		PEXAM			int,
		FUNDUS			int,
		OBPANEL			int,
		RUBELLA			int,
		RH				int,
		ABO				int,
		TOXMO			int,
		CYTO			int,
		HERPES			int,
		TORCH			int,
		SONO			int,
		RISKASSESS		int,
		COUNSEL			int,
		OBHIST			int,
		LMP				int,
		EDD				int,
		LMPDTE			varchar(30),
		EDDDTE			varchar(30),
		SAHIST			varchar(20),
		SAPREGUSE		int,
		SATREAT			int,
		CHLAMYD			varchar(30),
		PROVTYPE		varchar(2),
		PREGDX			int,
		DOMVIOL			int,
		SERVPASS		int,
		PASS			int,
		SERVDATE2		varchar(30),
		RESULT3			varchar(50),
		s_CoLineage		varchar(50),
		s_Generation	int,
		s_Lineage		varchar(50)
 )

--create import format
declare @lccmd varchar(1000)
set @lccmd = 'bcp hh08_rdsm.dbo.NUM01 format nul -T -f \\imisql9\e$\dataware\hhpsql1\NUM01.fmt -t, -c'
--set @lccmd = 'dir \\imisql9\e$\dataware\hhpsql1\'
print @lccmd
exec master..xp_cmdshell @lccmd

declare @lccmd varchar(1000)
--use this to do a tab delimitted:
set @lccmd = 'bcp hh08_rdsm.dbo.NUM01 format nul -c -f \\imisql9\e$\dataware\hhpsql1\NUM01.fmt -T'
print @lccmd
exec master..xp_cmdshell @lccmd

--NUM01_20080320
--NUM01_20080414
--NUM01_20080424 --8521
--NUM01_20080430 --9176

select	*
into	NUM01_20080430
from	NUM01

truncate table NUM01

--export from access tab delimited no " wrapping field content
bulk insert hh08_rdsm.dbo.NUM01 from '\\imisql9\e$\dataware\hhpsql1\NUM01.txt' WITH (FORMATFILE = '\\imisql9\e$\dataware\hhpsql1\NUM01.fmt' )

select *
from	NUM01
where SUBNO = '1015462'

*/

/*
use hh08_rdsm
--drop table dbo.tblDenomHist
create table dbo.tblDenomHist
(		s_GUID			varchar(50),
		SUBNO			varchar(12),
		PERSNO			varchar(2),
		SUBNOPERS		varchar(50),
		PANEL			varchar(3),
		PANELNAME		varchar(50),
		PCP				varchar(12),
		PCPNAME			varchar(50),
		PROVNAME		varchar(50),
		CATEGORY		varchar(50),
		CHARTSTAT		varchar(20),
		CHARTNUM		varchar(50),
		LASTUPDATE		varchar(30),
		UserName		varchar(50),
		NoData			varchar(50),
		Exclusion		varchar(50),
		COMMENTS1		varchar(155),
		FACILITY		varchar(50),
		COMMENTS2		varchar(50),
		ExclusionRsn	varchar(100),
		MODIFIED		varchar(30),
		MODIFIEDBY		varchar(50),
		s_CoLineage		varchar(50),
		s_Generation	int,
		s_Lineage		varchar(50) )


--create import format
declare @lccmd varchar(1000)
set @lccmd = 'bcp hh08_rdsm.dbo.tblDenomHist format nul -c -f \\imisql9\e$\dataware\hhpsql1\tblDenomHist.fmt -T'
--set @lccmd = 'dir \\imisql9\e$\dataware\hhpsql1\'
print @lccmd
exec master..xp_cmdshell @lccmd


declare @lccmd varchar(1000)
--use this to do a tab delimitted:
set @lccmd = 'bcp hh08_rdsm.dbo.tblDenomHist format nul -c -f \\imisql9\e$\dataware\hhpsql1\tblDenomHist.fmt -T'
print @lccmd
exec master..xp_cmdshell @lccmd

--tblDenomHist_20080320
--tblDenomHist_20080414
--tblDenomHist_20080424--3692
--tblDenomHist_20080430--4113

select	*
into	tblDenomHist_20080430
from	tblDenomHist

truncate table tblDenomHist

--export from access comma delimited no " wrapping field content
bulk insert hh08_rdsm.dbo.tblDenomHist from '\\imisql9\e$\dataware\hhpsql1\tblDenomHist.txt' WITH (FORMATFILE = '\\imisql9\e$\dataware\hhpsql1\tblDenomHist.fmt' )
*/


/*
select	*
from	hh08_rdsm.dbo.Diabnum

--Diabnum_20080402
--Diabnum_20080414
--Diabnum_20080424--2124
--Diabnum_20080430--2420

select	*
into	Diabnum_20080430
from	Diabnum

--create import format
declare @lccmd varchar(1000)
--use this to do a tab delimitted:
set @lccmd = 'bcp hh08_rdsm.dbo.Diabnum format nul -c -f \\imisql9\e$\dataware\hhpsql1\Diabnum.fmt -T'
print @lccmd
exec master..xp_cmdshell @lccmd

truncate table Diabnum

--export from access tab delimited no " wrapping field content
bulk insert hh08_rdsm.dbo.Diabnum from '\\imisql9\e$\dataware\hhpsql1\Diabnum.txt' WITH (FORMATFILE = '\\imisql9\e$\dataware\hhpsql1\Diabnum.fmt' )


create table hh08_rdsm.dbo.Diabnum
(		s_GUID			varchar(50),
		LASTUPDTE		varchar(30),
		LNAME			varchar(20),
		LASTNM			varchar(20),
		FNAME			varchar(12),
		MI				varchar(1),
		SUBSNO			varchar(12),
		SUBNO			varchar(12),
		PERSNO			varchar(2),
		SEX				varchar(1),
		DOB				varchar(30),
		NOINSULIN		int,
		SERVTYPE		varchar(10),
		DTTYPE			varchar(15),
		PASS			int,
		MOSTRECENT		int,
		SERVDATE		varchar(30),
		LOB				varchar(3),
		PANEL			varchar(3),
		NORMAL			int,
		ABNORMAL		int,
		NOHG			int,
		NOHGRES			int,
		HG95			int,
		HG8				int,
		LDL130			int,
		PASSYEAR		int,
		RESULT1			varchar(100),
		RESULT2			varchar(100),
		DATASOURCE		varchar(10),
		CLAIMNO			varchar(15),
		DATASYS			varchar(10),
		RESCODE			varchar(2),
		USERNAME		varchar(50),
		[DOCUMENT]		varchar(20),
		PROCCODE		varchar(8),
		PROCMODIF		varchar(1),
		DRG				varchar(3),
		MEDDEF			varchar(4),
		DX1				varchar(6),
		DX2				varchar(6),
		DX3				varchar(6),
		DX4				varchar(6),
		DX5				varchar(6),
		DX6				varchar(6),
		DX7				varchar(6),
		DX8				varchar(6),
		DX9				varchar(6),
		PROC1			varchar(8),
		PROC2			varchar(8),
		PROC3			varchar(8),
		PROC4			varchar(8),
		PROC5			varchar(8),
		PROC6			varchar(8),
		PROVNO			varchar(12),
		PROVFLAG		varchar(3),
		PROVTYPE		varchar(6),
		PROVSPEC		varchar(6),
		PROVPAR			varchar(1),
		PROVIPA			varchar(3),
		PCP				varchar(12),
		PCPTYPE			varchar(6),
		PCPSPEC			varchar(6),
		PCPIPA			varchar(3),
		VENDOR			varchar(15),
		VENDFLAG		varchar(1),
		FUNDMODEL		varchar(5),
		FIRSTUPDTE		varchar(30),
		DOCYN			varchar(50),
		DIABRET			varchar(50),
		s_ColLineage	varchar(50),
		s_Generation	int,
		s_Lineage		varchar(50),
		 )

*/



GO

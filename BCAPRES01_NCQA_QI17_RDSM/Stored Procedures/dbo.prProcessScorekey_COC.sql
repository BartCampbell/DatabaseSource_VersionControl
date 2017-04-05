SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--exec [prProcessScorekey_COC] 'RCA_Sample'
CREATE proc [dbo].[prProcessScorekey_COC] 

	@testdeck varchar(10)

as

--declare	@testdeck varchar(10)
--set		@testdeck = 'BCS_Sample'


declare @lccmd			varchar(2000)


--create table ncqa_qi10_rdsm..Scorekey_parseCOC
--(		comma1		int,
--		comma2		int,
--		comma3		int,
--		comma4		int,
--		comma5		int,
--		comma6		int,
--		comma7		int,
--		comma8		int,
--		comma9		int,
--		comma10		int,
--		comma11		int,
--		comma12		int,
--		comma13		int,
--		comma14		int,
--		comma15		int,
--		comma16		int,
--		comma17		int,
--		comma18		int,
--		txt_fld		varchar(200))

truncate table ncqa_qi10_rdsm..Scorekey_parseCOC

set		@lccmd = 
'select	txt_fld'+char(13)+
'from	ncqa_qi10_rdsm..Scorekey_'+@testdeck+'_import'+char(13)+
'where	left(txt_fld,5) <> ''MemID'''
print	@lccmd


--select top 2 * from ncqa_qi10_rdsm..Scorekey_RCA_Sample_import
--select top 2 * from ncqa_qi10_rdsm..Scorekey_RCA_Sample where memid = '25354'
--select top 2 * from ncqa_qi10_rdsm..Scorekey_parseCOC
--select top 2 * from ncqa_qi10_rdsm..Scorekey_EOC_Template

insert into ncqa_qi10_rdsm..Scorekey_parseCOC
(txt_fld)
exec (@lccmd)

update ncqa_qi10_rdsm..Scorekey_parseCOC set comma1  = charindex(',',txt_fld,0)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma2  = charindex(',',txt_fld,comma1+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma3  = charindex(',',txt_fld,comma2+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma4  = charindex(',',txt_fld,comma3+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma5  = charindex(',',txt_fld,comma4+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma6  = charindex(',',txt_fld,comma5+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma7  = charindex(',',txt_fld,comma6+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma8  = charindex(',',txt_fld,comma7+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma9  = charindex(',',txt_fld,comma8+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma10 = charindex(',',txt_fld,comma9+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma11 = charindex(',',txt_fld,comma10+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma12 = charindex(',',txt_fld,comma11+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma13 = charindex(',',txt_fld,comma12+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma14 = charindex(',',txt_fld,comma13+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma15 = charindex(',',txt_fld,comma14+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma16 = charindex(',',txt_fld,comma15+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma17 = charindex(',',txt_fld,comma16+1)
update ncqa_qi10_rdsm..Scorekey_parseCOC set comma18 = charindex(',',txt_fld,comma17+1)



SET @lcCMD = 'IF OBJECT_ID(''ncqa_qi10_rdsm..Scorekey_'+@testdeck+''') is not null DROP TABLE ncqa_qi10_rdsm..Scorekey_'+@testdeck+''
PRINT @lcCMD
EXEC (@lcCMD)


SET @lcCMD = 
'select	top 0 *'+char(13)+
'into	ncqa_qi10_rdsm..Scorekey_'+@testdeck+char(13)+
'from	ncqa_qi10_rdsm..Scorekey_COC_Template'
PRINT @lcCMD
EXEC (@lcCMD)


SET @lcCMD = 
'insert into ncqa_qi10_rdsm..Scorekey_'+@testdeck+char(13)+
'select	MemID = left(txt_fld,comma1-1),'+char(13)+
'		Meas  = substring(txt_fld,comma1+1,comma2-comma1-1),'+char(13)+
'		Payer = substring(txt_fld,comma2+1,comma3-comma2-1),'+char(13)+
'		Excl  = substring(txt_fld,comma3+1,comma4-comma3-1),'+char(13)+
'		Cor  = substring(txt_fld,comma4+1,comma5-comma4-1),'+char(13)+
'		ClinCat   = substring(txt_fld,comma5+1,comma6-comma5-1),'+char(13)+
'		CostInp   = substring(txt_fld,comma6+1,comma7-comma6-1),'+char(13)+
'		CostIEM   = substring(txt_fld,comma7+1,comma8-comma7-1),'+char(13)+
'		CostOEM   = substring(txt_fld,comma8+1,comma9-comma8-1),'+char(13)+
'		CostIProc   = substring(txt_fld,comma9+1,comma10-comma9-1),'+char(13)+
'		CostOProc   = substring(txt_fld,comma10+1,comma11-comma10-1),'+char(13)+
'		CostPharm   = substring(txt_fld,comma11+1,comma12-comma11-1),'+char(13)+
'		FreqInp   = substring(txt_fld,comma12+1,comma13-comma12-1),'+char(13)+
'		FreqED   = substring(txt_fld,comma13+1,comma14-comma13-1),'+char(13)+
'		Cond1   = substring(txt_fld,comma14+1,comma15-comma14-1),'+char(13)+
'		MM   = substring(txt_fld,comma15+1,comma16-comma15-1),'+char(13)+
'		MMP   = substring(txt_fld,comma16+1,comma17-comma16-1),'+char(13)+
'		Age   = substring(txt_fld,comma17+1,comma18-comma17-1),'+char(13)+
'		Gender   = right(txt_fld,len(txt_fld)-comma18)'+char(13)+
'from	ncqa_qi10_rdsm..Scorekey_parseCOC'
PRINT @lcCMD
EXEC (@lcCMD)

--MemId,Meas,Payer,Exc,Cor,ClinCat,CostInp,CostEM,CostProc,CostPharm,FreqInp,FreqED,FreqOB,Cond1,MM,MMP,Age,Sex
--25354,RCA,MCD,0,0,3,4205,0,0,45.84,1,0,0,0,12,12,39,M
GO

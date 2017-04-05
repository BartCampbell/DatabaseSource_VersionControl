SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--exec prProcessScorekey_EOC 'GSO_Sample'
CREATE proc [dbo].[prProcessScorekey_EOC_CDC] 

	@testdeck varchar(10)

as

--declare	@testdeck varchar(10)
--set		@testdeck = 'CDC_Sample'


declare @lccmd			varchar(2000)


--create table ncqa_qi10_rdsm..Scorekey_parse
--(		comma1		int,
--		comma2		int,
--		comma3		int,
--		comma4		int,
--		comma5		int,
--		comma6		int,
--		txt_fld		varchar(200))

truncate table ncqa_qi10_rdsm..Scorekey_parse

set		@lccmd = 
'select	txt_fld'+char(13)+
'from	ncqa_qi10_rdsm..Scorekey_'+@testdeck+'_import'+char(13)+
'where	left(txt_fld,5) <> ''MemID'''
print	@lccmd

--select	txt_fld--select *--from	ncqa_qi10_rdsm..Scorekey_CDC_Sample_import--where	left(txt_fld,5) <> 'MemID' and left(txt_fld,4) = '5425'
--
--txt_fld
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--MemID,Meas,Payer,Epop,Excl,Num,RExcl,Ind
--5425,CDC10,PPO,1,0,0,0,0
--5425,CDC2,PPO,1,0,0,0,0
--5425,CDC4,PPO,1,0,1,0,0
--5425,CDC8,PPO,1,0,0,0,0
--5425,CDC3,PPO,1,0,0,0,0
--5425,CDC5,PPO,1,0,1,0,0
--5425,CDC9,PPO,1,0,0,0,0
--5425,CDC1,PPO,1,0,1,0,0
--5425,CDC6,PPO,1,0,0,0,0
--5425,CDC7,PPO,1,0,0,0,0


insert into ncqa_qi10_rdsm..Scorekey_parse
(txt_fld)
exec (@lccmd)

update ncqa_qi10_rdsm..Scorekey_parse set comma1 = charindex(',',txt_fld,0)
update ncqa_qi10_rdsm..Scorekey_parse set comma2 = charindex(',',txt_fld,comma1+1)
update ncqa_qi10_rdsm..Scorekey_parse set comma3 = charindex(',',txt_fld,comma2+1)
update ncqa_qi10_rdsm..Scorekey_parse set comma4 = charindex(',',txt_fld,comma3+1)
update ncqa_qi10_rdsm..Scorekey_parse set comma5 = charindex(',',txt_fld,comma4+1)
update ncqa_qi10_rdsm..Scorekey_parse set comma6 = charindex(',',txt_fld,comma5+1)
update ncqa_qi10_rdsm..Scorekey_parse set comma7 = charindex(',',txt_fld,comma6+1)



SET @lcCMD = 'IF OBJECT_ID(''ncqa_qi10_rdsm..Scorekey_'+@testdeck+''') is not null DROP TABLE ncqa_qi10_rdsm..Scorekey_'+@testdeck+''
PRINT @lcCMD
EXEC (@lcCMD)


SET @lcCMD = 
'select	top 0 *'+char(13)+
'into	ncqa_qi10_rdsm..Scorekey_'+@testdeck+char(13)+
'from	ncqa_qi10_rdsm..Scorekey_EOC_CDC_Template'
PRINT @lcCMD
EXEC (@lcCMD)



SET @lcCMD = 
'insert into ncqa_qi10_rdsm..Scorekey_'+@testdeck+char(13)+
'select	MemID = left(txt_fld,comma1-1),'+char(13)+
'		Meas  = substring(txt_fld,comma1+1,comma2-comma1-1),'+char(13)+
'		Payer = substring(txt_fld,comma2+1,comma3-comma2-1),'+char(13)+
'		Epop  = substring(txt_fld,comma3+1,comma4-comma3-1),'+char(13)+
'		Excl  = substring(txt_fld,comma4+1,comma5-comma4-1),'+char(13)+
'		Num   = substring(txt_fld,comma5+1,comma6-comma5-1),'+char(13)+
'		RExcl = substring(txt_fld,comma6+1,comma7-comma6-1),'+char(13)+
'		Ind   = right(txt_fld,len(txt_fld)-comma7)'+char(13)+
'from	ncqa_qi10_rdsm..Scorekey_parse'
PRINT @lcCMD
EXEC (@lcCMD)
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[usp_import_codesets]

As
declare @lcCmd varchar(200)

--SET @lcCMD = 'bcp ncqa_rdsm.dbo.tblCodeSets format nul -c -x -f e:\dataware\ncqa\codesets\codeset-f-c-x.xml -t -U sa -P 3o1M#dium '
--EXEC master..xp_cmdshell @lcCMD

--TERMINATOR="\t"
-- delete from tblcodesets
SET @lcCMD = 'bulk insert ncqa_rdsm.dbo.tblCodeSets from '
			+ '''e:\dataware\ncqa\codesets\hedis_codes.txt'' '
			+ 'WITH ( DATAFILETYPE=''char'' , '
			+ 'FORMATFILE = ''e:\dataware\ncqa\codesets\codeset-f-c-x.xml'' )'

PRINT @lcCMD
EXEC (@lcCMD)


select codetype, count(*) from tblCodeSets
group by codetype
order by codetype

update tblcodesets
set codetype = 'ICD-9-CM_Procedure'
where codetype = 'ICD-9-CM_Prodecure'

update tblcodesets
set codetype = 'UB-92_Revenue'
where isnull(codetype, '') = ''
	and MeasureID = 'AMM-B'

update tblcodesets
set codetype = 'CMS_1500_Place_Of_Service_Codes'
where codetype = 'Place_of_Service_CMS_1500'
	and MeasureID = 'AMB-B'


select * from tblcodesets 
where codetype = 'Place_of_Service_CMS_1500'
GO

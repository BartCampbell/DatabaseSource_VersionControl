SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










/*
EXECUTE prRunDemoHedis 
			@bUpdateDs01 = 0, 
			@bRunWithTestData = 0, 
			@bUpdateMPI = 0, 
			@bUpdateIMIDataStore = 0, 
			@bUpdateDwHedisTables = 0, 
			@bRunMeasures = 1, 
			@bUpdateDW01 = 1
*/



create  PROC [dbo].[prBuildQINet] 
	@bUpdateRDSM BIT = 0,
    @bRunWithTestData BIT = 0,
    @bUpdateMPI BIT = 0,
    @bUpdateIMIDataStore BIT = 0,
    @bUpdateDwHedisTables  BIT = 0,
    @bRunMeasures BIT = 0, 
    @bUpdateDW01 BIT = 0

AS




--DECLARE @bUpdateDs01 BIT,
--    @bRunWithTestData BIT,
--    @bUpdateIMIDataStore BIT,
--    @bUpdateMPI BIT,
--    @bUpdateDwHedisTables  BIT,
--    @bRunMeasures BIT, 
--    @bUpdateDW01 BIT
--    
--
--SELECT @bUpdateDs01 =0,
--    @bRunWithTestData = 0,
--    @bUpdateMPI = 0,
--    @bUpdateIMIDataStore = 1,
--    @bUpdateDwHedisTables = 1,
--    @bRunMeasures = 1, 
--    @bUpdateDW01 = 1
    


IF @bUpdateRDSM = 1
BEGIN
--This step will be used to get the RDSM populated from native Client sources
--E.g. text files, spreadsheets, etc.

print 'Update RDSM'

END


IF @bUpdateMPI = 1
BEGIN
-- Update MPI 

print 'RUN MPI'
--HEDIS 2008: exec ncqa_rdsm.dbo.prBuildMPIXref_NCQA
END




IF @bUpdateIMIDataStore = 1
BEGIN
-- Update IMIDataStore tables

print 'Load IMIDatastore'
--HEDIS 2008: execute prLoadDataStoreWithTestDeck




IF OBJECT_ID('tempdb..#temp_DS01') is not null
    DROP TABLE #temp_DS01

select	a.EligibilityID,
		a.DateEffective,
		a.DateTerminated,
		new_DateEffective		= isnull(
								(select	min(dateadd(dd,-1,b.DateEffective))
								from	Eligibility b
								where	a.MemberID = b.MemberID and
										a.EligibilityID <> b.EligibilityID and
										a.DateEffective < b.DateEffective),
								a.DateTerminated) 
into	#temp_DS01 
from	Eligibility a
		inner join Eligibility c on
			a.MemberID = c.MemberID and
			a.EligibilityID <> c.EligibilityID and
			a.DateTerminated between c.DateEffective and c.DateTerminated


update	Eligibility
set		DateTerminated = b.new_DateEffective 
from	Eligibility a
		left join #temp_DS01 b on
			a.EligibilityID = b.EligibilityID
where	a.DateTerminated <> b.new_DateEffective 



update	Eligibility
set	CustomerPCPID = right(convert(varchar(10),ihds_member_id),2)
from	Eligibility a
		inner join Member b on
			a.MemberID = b.MemberID




END





IF @bUpdateDwHedisTables = 1
BEGIN
print 'Load dw_hedis'
--exec prLoadHedis '20071231', '20070101', '20071231', 'CDC_Sample'

--EXECUTE dbo.prLoadHedisSupport 
--EXEC usp_break_in_coverage  '20070101', '20071231'

END 


--exec prLoadHedis '20071231', '20070101', '20071231', 'ASM_Sample'
--exec POP_HEDIS_FACT_ASM '20071231', '20070101', '20071231'
--exec prLoadHedis '20071231', '20070101', '20071231', 'CDC_Sample'
--exec POP_HEDIS_FACT_CDC '20071231', '20070101', '20071231'
--exec prLoadHedis '20071231', '20070101', '20071231', 'BCS_Sample'
--exec POP_HEDIS_FACT_BCS '20071231', '20070101', '20071231'
--exec prLoadHedis '20071231', '20070101', '20071231', 'PPC_Sample'
--exec POP_HEDIS_FACT_PPC '20071231', '20070101', '20071231'
--exec prLoadHedis '20071231', '20070101', '20071231', 'CIS_Sample'
--exec POP_HEDIS_FACT_CIS '20071231', '20070101', '20071231'
--
--truncate table utb_hedis_service_dtl
--exec prLoadHedis '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_ASM '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_CDC '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_BCS '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_PPC '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_CIS '20071231', '20070101', '20071231'
--
--exec POP_HEDIS_FACT_COL '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_GSO '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_SPR '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_PCE '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_CBP '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_PBH '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_OMW '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_AMM '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_FUH '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_MPM '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_DDE '20071231', '20070101', '20071231'
--exec POP_HEDIS_FACT_DAE '20071231', '20070101', '20071231'


--where	measureset in ('ASM_Sample','BCS_Sample','CDC_Sample','PPC_Sample',
--		'CIS_Sample','COL_Sample','GSO_Sample','SPR_Sample','PCE_Sample',
--		'CBP_Sample','PBH_Sample','OMW_Sample','AMM_Sample','FUH_Sample',
--		'MPM_Sample','DDE_Sample','DAE_Sample')

IF @bRunMeasures = 1
BEGIN -- Run Measures
    -- Make sure that the dates match the dates used for prRunMeasures

print 'Run Measures'

--exec POP_HEDIS_FACT_CDC '20071231', '20070101', '20071231'
--	truncate table utb_hedis_service_dtl
--
--    -- Run the measures in HH08_IHDS_DS01
--    EXEC prRunMeasures
--        @iLoadInstanceID = 1,
--	    @lcCurYearMonth = '200712',
--	    @lcStartDate = '20070101',
--	    @lcEndDate = '20071231',
--	    @liRunMeasures  = 1
	
END-- Run Measures






IF @bUpdateDW01 = 1
BEGIN -- Dim MOdel 

--    -- Update the dims that are associated with the HEDIS dim model

exec ncqa_ihds_dw01..pop_member_dim_imidatastore
exec ncqa_ihds_dw01..pop_pcp_dim_imidatastore 
exec ncqa_ihds_dw01..pop_hedis_medical_record_site_dim 
exec ncqa_ihds_dw01..pop_hedis_medical_group_dim 
exec ncqa_ihds_dw01..pop_service_date_dim
exec ncqa_ihds_dw01..pop_report_ending_date_dim
exec ncqa_ihds_dw01..POP_HEDIS_MEASURE_DIM
exec ncqa_ihds_dw01..POP_HEDIS_REPORT_METRIC_DIM

exec ncqa_ihds_dw01..POP_HEDIS_REPORT_METRIC_FACT '20070101', '20071231'
exec ncqa_ihds_dw01..POP_HEDIS_SERVICE_DTL_FACT  '20070101','20071231'


/*


exec ncqa_ihds_dw01..rpt_hedis_indicator_summary

exec ncqa_ihds_dw01..rpt_hedis_measure_member_list
		@lchedis_report_metric_id = 'ASM1',  
		@lidenominator_value = '1',
		@linumerator_value = '3',
		@liexclusion_value = '3',
		@linumerator_negative_value = '3'


exec ncqa_ihds_dw01..rpt_hedis_measure_member_claim_list
		@lchedis_measure_id = 'CDC',  
		@lcCustomerMemberID = '3209920',
		@lchedis_measure_sub_metric_class = 'Numerator'

*/




END -- Dim MOdel 


DECLARE @vcCmd VARCHAR(1000)
DECLARE @vcCmd2 VARCHAR(1000)

SET @vcCmd = 'NCQADemo is complete'
SET @vccmd2 = '@bUpdateRDSM = ' + CONVERT(VARCHAR(1),@bUpdateRDSM) + CHAR(13) 
            +'@bRunWithTestData = ' + CONVERT(VARCHAR(1),@bRunWithTestData) + CHAR(13)
			+'@bUpdateMPI = '  + CONVERT(VARCHAR(1),@bUpdateMPI) + CHAR(13)
            +'@bUpdateIMIDataStore = ' + CONVERT(VARCHAR(1),@bUpdateIMIDataStore) + CHAR(13) 
            +'@bUpdateDwHedisTables  = ' + CONVERT(VARCHAR(1),@bUpdateDwHedisTables ) + CHAR(13) 
            +'@bRunMeasures = ' + CONVERT(VARCHAR(1),@bRunMeasures) + CHAR(13) 
            +'@bUpdateDW01 = ' + CONVERT(VARCHAR(1),@bUpdateDW01 ) + CHAR(13) 

EXEC msdb..sp_send_dbmail @subject = @vcCmd, @importance = 'NORMAL', @recipients =  'randy.wilson@imihealth.com', @body = @vccmd2












GO

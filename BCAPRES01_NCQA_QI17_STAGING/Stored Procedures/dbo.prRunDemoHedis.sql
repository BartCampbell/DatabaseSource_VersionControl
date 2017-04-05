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



CREATE  PROC [dbo].[prRunDemoHedis] 
	@bUpdateRDSM BIT = 0,
	@bUpdateDs01 BIT = 0,
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

print 'Populate RDSM from recently downloaded decks'

exec ncqa_qi10_rdsm.dbo.usp_load_ncqa_datasets_2010

END



IF @bUpdateMPI = 1
BEGIN

print 'Runs pseudo MPI on new decks'

EXECUTE ncqa_qi10_rdsm.dbo.prPopulateMPITables
EXECUTE ncqa_qi10_rdsm.dbo.prCreateInstanceAndLoadData 'NCQA2010', '20091231'

END
--use ncqa_ihds_ds01
--exec prLoadDataStoreWithTestDeck




IF @bUpdateIMIDataStore = 1
BEGIN-- Update IMIDataStore tables

print 'Load IMIDatastore'
execute prLoadDataStoreWithTestDeck



--IF OBJECT_ID('tempdb..#temp_DS01') is not null
--    DROP TABLE #temp_DS01
--
--select	a.EligibilityID,
--		a.DateEffective,
--		a.DateTerminated,
--		new_DateEffective		= isnull(
--								(select	min(dateadd(dd,-1,b.DateEffective))
--								from	Eligibility b
--								where	a.MemberID = b.MemberID and
--										a.EligibilityID <> b.EligibilityID and
--										a.DateEffective < b.DateEffective),
--								a.DateTerminated) 
--into	#temp_DS01 
--from	Eligibility a
--		inner join Eligibility c on
--			a.MemberID = c.MemberID and
--			a.EligibilityID <> c.EligibilityID and
--			a.DateTerminated between c.DateEffective and c.DateTerminated
--
--
--update	Eligibility
--set		DateTerminated = b.new_DateEffective 
--from	Eligibility a
--		left join #temp_DS01 b on
--			a.EligibilityID = b.EligibilityID
--where	a.DateTerminated <> b.new_DateEffective 
--
--
--
--update	Eligibility
--set	CustomerPCPID = right(convert(varchar(10),ihds_member_id),2)
--from	Eligibility a
--		inner join Member b on
--			a.MemberID = b.MemberID




END





IF @bUpdateDwHedisTables = 1
BEGIN
print 'Load dw_hedis'
exec prLoadHedis '20081231', '20080101', '20081231', 'BCS_Sample'

--Both of these are run by prLoadHedis:
--EXECUTE dbo.prLoadHedisSupport 
--EXEC usp_break_in_coverage  '20070101', '20071231'

END 





IF @bRunMeasures = 1
BEGIN -- Run Measures
    -- Make sure that the dates match the dates used for prRunMeasures

print 'Run Measures'

truncate table utb_hedis_service_dtl

    -- Run the measures
    EXEC prRunMeasures
        @iLoadInstanceID = 1,
	    @lcCurYearMonth = '200712',
	    @lcStartDate = '20070101',
	    @lcEndDate = '20071231',
	    @liRunMeasures  = 1


--    -- Run the measures
--    EXEC prRunMeasures
--        @iLoadInstanceID = 1,
--	    @lcCurYearMonth = '200706',
--	    @lcStartDate = '20060701',
--	    @lcEndDate = '20070630',
--	    @liRunMeasures  = 1
	
END-- Run Measures





IF @bUpdateDW01 = 1
BEGIN -- Dim MOdel 

--    -- Update the dims that are associated with the HEDIS dim model

--pop_hedis_dss_report_metric_uos_cohort_dim
--Msg 207, Level 16, State 1, Line 1
--Invalid column name 'rlb_dss_product'.
--Msg 207, Level 16, State 1, Line 1
--Invalid column name 'rlb_dss_sub_category'.
--Msg 207, Level 16, State 1, Line 1
--Invalid column name 'rlb_dss_product'.


exec pop_hedis_service_date_dim
exec pop_hedis_age_dim
exec pop_hedis_dss_age_dim
exec pop_hedis_gender_dim
exec pop_hedis_member_dim
exec pop_hedis_pcp_dim
exec pop_hedis_medical_group_dim
exec pop_hedis_medical_record_site_dim
exec pop_hedis_member_measure_sample_dim
exec pop_hedis_report_ending_date_dim
exec pop_hedis_measure_dim
exec pop_hedis_report_metric_dim
exec pop_hedis_benchmark_metric_level_dim
exec pop_hedis_benchmark_metric_prodline_prod_level_dim
exec pop_hedis_product_line_dim
exec pop_hedis_report_metric_uos_dim
exec pop_hedis_benchmark_metric_uos_prodline_prod_level_dim
exec pop_hedis_report_metric_uos_cohort_dim
exec pop_hedis_report_metric_coc_dim
exec pop_hedis_benchmark_metric_coc_prodline_prod_level_dim
exec pop_hedis_coc_comorbidity_dim
exec pop_hedis_coc_clinical_category_dim
exec pop_hedis_servicing_prov_dim


--exec pop_hedis_report_metric_fact '20070101', '20071231'
--exec pop_hedis_service_dtl_fact  '20070101','20071231'
--
--exec pop_hedis_report_metric_uos_fact '20070101', '20071231'
--exec pop_hedis_report_metric_coc_fact '20070101', '20071231'

exec pop_hedis_report_metric_fact '20060701', '20070630'
exec pop_hedis_service_dtl_fact  '20060701', '20070630'

exec pop_hedis_report_metric_uos_fact '20060701', '20070630'
exec pop_hedis_report_metric_coc_fact '20060701', '20070630'


/*
6/26/08 I've run the updates above, and the compare here looks reasonable, 
need to prepare to get cognos in shape to handle multiple periods, the publish and test:
exec rpt_hedis_build_compare_to_previous


exec usp_move_staging_prod 'hedis_service_date_dim'
exec usp_move_staging_prod 'hedis_age_dim'
exec usp_move_staging_prod 'hedis_dss_age_dim'
exec usp_move_staging_prod 'hedis_gender_dim'
exec usp_move_staging_prod 'hedis_member_dim'
exec usp_move_staging_prod 'hedis_pcp_dim'
exec usp_move_staging_prod 'hedis_medical_group_dim'
exec usp_move_staging_prod 'hedis_medical_record_site_dim'
exec usp_move_staging_prod 'hedis_member_measure_sample_dim'
exec usp_move_staging_prod 'hedis_report_ending_date_dim'
exec usp_move_staging_prod 'hedis_measure_dim'
exec usp_move_staging_prod 'hedis_report_metric_dim'
exec usp_move_staging_prod 'hedis_benchmark_metric_level_dim'
exec usp_move_staging_prod 'hedis_benchmark_metric_prodline_prod_level_dim'
exec usp_move_staging_prod 'hedis_product_line_dim'
exec usp_move_staging_prod 'hedis_report_metric_uos_dim'
exec usp_move_staging_prod 'hedis_benchmark_metric_uos_prodline_prod_level_dim'
exec usp_move_staging_prod 'hedis_report_metric_uos_cohort_dim'
exec usp_move_staging_prod 'hedis_report_metric_coc_dim'
exec usp_move_staging_prod 'hedis_benchmark_metric_coc_prodline_prod_level_dim'
exec usp_move_staging_prod 'hedis_coc_comorbidity_dim'
exec usp_move_staging_prod 'hedis_coc_clinical_category_dim'
exec usp_move_staging_prod 'hedis_report_metric_coc_cohort_dim'
exec usp_move_staging_prod 'hedis_servicing_prov_dim'

exec usp_move_staging_prod 'hedis_measure_sub_metric_dim'
exec usp_move_staging_prod 'hedis_service_dtl_indicative_dim'
exec usp_move_staging_prod 'hedis_service_dtl_claim_hdr_dim'
exec usp_move_staging_prod 'hedis_service_dtl_claim_dtl_dim'
exec usp_move_staging_prod 'hedis_service_dtl_lab_result_dim'
exec usp_move_staging_prod 'hedis_service_dtl_pharmacy_claim_dim'
exec usp_move_staging_prod 'hedis_service_dtl_medical_record_dim'

exec usp_move_staging_prod 'hedis_report_metric_fact'
exec usp_move_staging_prod 'hedis_service_dtl_fact'
exec usp_move_staging_prod 'hedis_report_metric_uos_fact'
exec usp_move_staging_prod 'hedis_report_metric_coc_fact'



*/


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
SET @vccmd2 = '@bUpdateDs01 = ' + CONVERT(VARCHAR(1),@bUpdateDs01) + CHAR(13) 
            +'@bRunWithTestData = ' + CONVERT(VARCHAR(1),@bRunWithTestData) + CHAR(13)
			+'@bUpdateMPI = '  + CONVERT(VARCHAR(1),@bUpdateMPI) + CHAR(13)
            +'@bUpdateIMIDataStore = ' + CONVERT(VARCHAR(1),@bUpdateIMIDataStore) + CHAR(13) 
            +'@bUpdateDwHedisTables  = ' + CONVERT(VARCHAR(1),@bUpdateDwHedisTables ) + CHAR(13) 
            +'@bRunMeasures = ' + CONVERT(VARCHAR(1),@bRunMeasures) + CHAR(13) 
            +'@bUpdateDW01 = ' + CONVERT(VARCHAR(1),@bUpdateDW01 ) + CHAR(13) 

EXEC msdb..sp_send_dbmail @subject = @vcCmd, @importance = 'NORMAL', @recipients =  'randy.wilson@imihealth.com', @body = @vccmd2
















GO

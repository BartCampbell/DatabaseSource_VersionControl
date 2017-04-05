SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec PrSampleDraw '20070630'


create procedure [dbo].[PrSampleDraw]

@lcEndDate VARCHAR(8)

as


--**********************************************************************************
--declare @lcEndDate VARCHAR(8)
--set		@lcEndDate = '20070630'
--**********************************************************************************



--**********************************************************************************
--**********************************************************************************
--CDC
--exec POP_HEDIS_FACT_CDC '20071231', '20070101', '20071231'
--**********************************************************************************
--**********************************************************************************

--**********************************************************************************
--**********************************************************************************
truncate table utb_hedis_systematic_sample

insert into	dbo.utb_hedis_systematic_sample
(		ihds_member_id,
		last_name,
		first_name,
		dob )
select	ihds_member_id			= a.ihds_member_id,
		last_name				= d.NameLast,
		first_name				= d.NameFirst,
		dob						= c.dob 
from	utb_hedis_cdc a
		inner join dw_hedis_member_elig b on
			a.ihds_member_id = b.ihds_member_id and
			@lcEndDate between eff_date and term_date
		inner join dw_hedis_member c on
			a.ihds_member_id = c.ihds_member_id 
		inner join member d on
			a.ihds_member_id = d.ihds_member_id
where	cdc_hedis_eligible_flag = 1 and
		cdc_denominator_flag = 1 and
		cdc_exclusion_flag = 0 and
		case	when lob = 'MDE' then 'MCD'
				when lob = 'MD'  then 'MCD'
				when lob = 'MLI' then 'MCD'
				when lob = 'MRB' then 'MCD'
				when lob = 'MR'  then 'MCR'
				when lob = 'MP'  then 'MP'
				when lob = 'MC'  then 'MCR'
				when lob = 'PPO' then 'PPO'
				when lob = 'POS' then 'COM'
				when lob = 'HMO' then 'COM'
				when lob = 'CHP' then 'CHP'
				else ''
		  end = 'CHP'

exec POP_HEDIS_SYSTEMATIC_SAMPLE '548', '0.05', '0.21'


truncate table utb_hedis_cdc_sampleframe_CHP

insert	into dbo.utb_hedis_cdc_sampleframe_CHP
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'CHP',
		hedis_measure_init	= 'CDC',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end),
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row
--**********************************************************************************
--**********************************************************************************


--**********************************************************************************
--**********************************************************************************
truncate table utb_hedis_systematic_sample

insert into	dbo.utb_hedis_systematic_sample
(		ihds_member_id,
		last_name,
		first_name,
		dob )
select	ihds_member_id			= a.ihds_member_id,
		last_name				= d.NameLast,
		first_name				= d.NameFirst,
		dob						= c.dob
from	utb_hedis_cdc a
		inner join dw_hedis_member_elig b on
			a.ihds_member_id = b.ihds_member_id and
			@lcEndDate between eff_date and term_date 
		inner join dw_hedis_member c on
			a.ihds_member_id = c.ihds_member_id 
		inner join member d on
			a.ihds_member_id = d.ihds_member_id
where	cdc_hedis_eligible_flag = 1 and
		cdc_denominator_flag = 1 and
		cdc_exclusion_flag = 0 and
		case	when lob = 'MDE' then 'MCD'
				when lob = 'MD'  then 'MCD'
				when lob = 'MLI' then 'MCD'
				when lob = 'MRB' then 'MCD'
				when lob = 'MR'  then 'MCR'
				when lob = 'MP'  then 'MP'
				when lob = 'MC'  then 'MCR'
				when lob = 'PPO' then 'PPO'
				when lob = 'POS' then 'COM'
				when lob = 'HMO' then 'COM'
				when lob = 'CHP' then 'CHP'
				else ''
		  end = 'MCD'

exec POP_HEDIS_SYSTEMATIC_SAMPLE '548', '0.05', '0.21'


truncate table utb_hedis_cdc_sampleframe_MCD

insert into	dbo.utb_hedis_cdc_sampleframe_MCD
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'MCD',
		hedis_measure_init	= 'CDC',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end),
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row
--**********************************************************************************
--**********************************************************************************




----**********************************************************************************
----**********************************************************************************
----AWC
----exec POP_HEDIS_FACT_AWC '20071231', '20070101', '20071231'
----**********************************************************************************
----**********************************************************************************
--
----**********************************************************************************
----**********************************************************************************
--truncate table utb_hedis_systematic_sample
--
--insert into	dbo.utb_hedis_systematic_sample
--(		ihds_member_id,
--		last_name,
--		first_name,
--		dob )
--select	ihds_member_id			= a.ihds_member_id,
--		last_name				= d.NameLast,
--		first_name				= d.NameFirst,
--		dob						= c.dob
--from	utb_hedis_awc a
--		inner join dw_hedis_member_elig b on
--			a.ihds_member_id = b.ihds_member_id and
--			'20071231' between eff_date and term_date
--		inner join dw_hedis_member c on
--			a.ihds_member_id = c.ihds_member_id 
--		inner join member d on
--			a.ihds_member_id = d.ihds_member_id
--where	awc_hedis_eligibility_flag = '1' and
--		awc_denominator_flag = '1' and
--		awc_exclusion_flag = '0' and
--		case	when lob = 'MDE' then 'MCD'
--				when lob = 'MD'  then 'MCD'
--				when lob = 'MLI' then 'MCD'
--				when lob = 'MRB' then 'MCD'
--				when lob = 'MR'  then 'MCR'
--				when lob = 'MP'  then 'MP'
--				when lob = 'MC'  then 'MCR'
--				when lob = 'PPO' then 'PPO'
--				when lob = 'POS' then 'COM'
--				when lob = 'HMO' then 'COM'
--				when lob = 'CHP' then 'CHP'
--				else ''
--		  end = 'CHP'
--
--exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.10'
--
--
--truncate table utb_hedis_awc_sampleframe_CHP
--
--insert	into dbo.utb_hedis_awc_sampleframe_CHP
--select	a.ihds_member_id,
--		memid				= ltrim(rtrim(CustomerMemberID)),
--		dob					= ltrim(rtrim(dob)),
--		first_name			= ltrim(rtrim(first_name)),
--		last_name			= ltrim(rtrim(last_name)),
--		product				= 'CHP',
--		hedis_measure_init	= 'AWC',
--		systematic_order_row = systematic_order_row,
--		sample_row			= sample_row,
--		sample_indicator	=	convert(varchar(10),
--								case	when sample_type = 'primary'
--										then 'sample'
--										when sample_type = 'auxiliary'
--										then 'oversample'
--								end) ,
--		systematic_sample_mrss				= a.systematic_sample_mrss,
--		systematic_sample_em				= a.systematic_sample_em,
--		systematic_sample_fss				= a.systematic_sample_fss,
--		systematic_sample_n					= a.systematic_sample_n,
--		systematic_sample_start				= a.systematic_sample_start,
--		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
--		systematic_sample_rand				= a.systematic_sample_rand,
--		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
--from	utb_hedis_systematic_sample a
--		inner join member b on
--			a.ihds_member_id = b.ihds_member_id
--order by systematic_order_row,
--		sample_row
----**********************************************************************************
----**********************************************************************************
--
--
----**********************************************************************************
----**********************************************************************************
--truncate table utb_hedis_systematic_sample
--
--insert into	dbo.utb_hedis_systematic_sample
--(		ihds_member_id,
--		last_name,
--		first_name,
--		dob )
--select	ihds_member_id			= a.ihds_member_id,
--		last_name				= d.NameLast,
--		first_name				= d.NameFirst,
--		dob						= c.dob
--from	utb_hedis_awc a
--		inner join dw_hedis_member_elig b on
--			a.ihds_member_id = b.ihds_member_id and
--			'20071231' between eff_date and term_date
--		inner join dw_hedis_member c on
--			a.ihds_member_id = c.ihds_member_id 
--		inner join member d on
--			a.ihds_member_id = d.ihds_member_id
--where	awc_hedis_eligibility_flag = '1' and
--		awc_denominator_flag = '1' and
--		awc_exclusion_flag = '0' and
--		case	when lob = 'MDE' then 'MCD'
--				when lob = 'MD'  then 'MCD'
--				when lob = 'MLI' then 'MCD'
--				when lob = 'MRB' then 'MCD'
--				when lob = 'MR'  then 'MCR'
--				when lob = 'MP'  then 'MP'
--				when lob = 'MC'  then 'MCR'
--				when lob = 'PPO' then 'PPO'
--				when lob = 'POS' then 'COM'
--				when lob = 'HMO' then 'COM'
--				when lob = 'CHP' then 'CHP'
--				else ''
--		  end = 'MCD'
--
--exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.10'
--
--
--truncate table utb_hedis_awc_sampleframe_MCD
--
--insert into	dbo.utb_hedis_awc_sampleframe_MCD
--select	a.ihds_member_id,
--		memid				= ltrim(rtrim(CustomerMemberID)),
--		dob					= ltrim(rtrim(dob)),
--		first_name			= ltrim(rtrim(first_name)),
--		last_name			= ltrim(rtrim(last_name)),
--		product				= 'MCD',
--		hedis_measure_init	= 'AWC',
--		systematic_order_row = systematic_order_row,
--		sample_row			= sample_row,
--		sample_indicator	=	convert(varchar(10),
--								case	when sample_type = 'primary'
--										then 'sample'
--										when sample_type = 'auxiliary'
--										then 'oversample'
--								end) ,
--		systematic_sample_mrss				= a.systematic_sample_mrss,
--		systematic_sample_em				= a.systematic_sample_em,
--		systematic_sample_fss				= a.systematic_sample_fss,
--		systematic_sample_n					= a.systematic_sample_n,
--		systematic_sample_start				= a.systematic_sample_start,
--		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
--		systematic_sample_rand				= a.systematic_sample_rand,
--		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
--from	utb_hedis_systematic_sample a
--		inner join member b on
--			a.ihds_member_id = b.ihds_member_id
--order by systematic_order_row,
--		sample_row
----**********************************************************************************
----**********************************************************************************







--**********************************************************************************
--**********************************************************************************
--CIS
--exec POP_HEDIS_FACT_CIS '20071231', '20070101', '20071231'
--**********************************************************************************
--**********************************************************************************

--**********************************************************************************
--**********************************************************************************
truncate table utb_hedis_systematic_sample

insert into	dbo.utb_hedis_systematic_sample
(		ihds_member_id,
		last_name,
		first_name,
		dob )
select	ihds_member_id			= a.ihds_member_id,
		last_name				= d.NameLast,
		first_name				= d.NameFirst,
		dob						= c.dob 
from	utb_hedis_cis a
		inner join dw_hedis_member_elig b on
			a.ihds_member_id = b.ihds_member_id and
			cis_cont_elig_eval_end between eff_date and term_date
		inner join dw_hedis_member c on
			a.ihds_member_id = c.ihds_member_id 
		inner join member d on
			a.ihds_member_id = d.ihds_member_id
where	cis_hedis_eligibility_flag = 1 and
		cis_denominator_flag = 1 and
		cis_exclusion_flag = 0 and
		case	when lob = 'MDE' then 'MCD'
				when lob = 'MD'  then 'MCD'
				when lob = 'MLI' then 'MCD'
				when lob = 'MRB' then 'MCD'
				when lob = 'MR'  then 'MCR'
				when lob = 'MP'  then 'MP'
				when lob = 'MC'  then 'MCR'
				when lob = 'PPO' then 'PPO'
				when lob = 'POS' then 'COM'
				when lob = 'HMO' then 'COM'
				when lob = 'CHP' then 'CHP'
				else ''
		  end = 'CHP'

exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.35'


truncate table utb_hedis_cis_sampleframe_CHP

insert	into dbo.utb_hedis_cis_sampleframe_CHP
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'CHP',
		hedis_measure_init	= 'CIS',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row




truncate table utb_hedis_lsc_sampleframe_CHP

insert	into dbo.utb_hedis_lsc_sampleframe_CHP
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'CHP',
		hedis_measure_init	= 'LSC',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row
--**********************************************************************************
--**********************************************************************************


--**********************************************************************************
--**********************************************************************************
truncate table utb_hedis_systematic_sample

insert into	dbo.utb_hedis_systematic_sample
(		ihds_member_id,
		last_name,
		first_name,
		dob )
select	ihds_member_id			= a.ihds_member_id,
		last_name				= d.NameLast,
		first_name				= d.NameFirst,
		dob						= c.dob
from	utb_hedis_cis a
		inner join dw_hedis_member_elig b on
			a.ihds_member_id = b.ihds_member_id and
			cis_cont_elig_eval_end between eff_date and term_date
		inner join dw_hedis_member c on
			a.ihds_member_id = c.ihds_member_id 
		inner join member d on
			a.ihds_member_id = d.ihds_member_id
where	cis_hedis_eligibility_flag = 1 and
		cis_denominator_flag = 1 and
		cis_exclusion_flag = 0 and
		case	when lob = 'MDE' then 'MCD'
				when lob = 'MD'  then 'MCD'
				when lob = 'MLI' then 'MCD'
				when lob = 'MRB' then 'MCD'
				when lob = 'MR'  then 'MCR'
				when lob = 'MP'  then 'MP'
				when lob = 'MC'  then 'MCR'
				when lob = 'PPO' then 'PPO'
				when lob = 'POS' then 'COM'
				when lob = 'HMO' then 'COM'
				when lob = 'CHP' then 'CHP'
				else ''
		  end = 'MCD'

exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.35'


truncate table utb_hedis_cis_sampleframe_MCD

insert into	dbo.utb_hedis_cis_sampleframe_MCD
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'MCD',
		hedis_measure_init	= 'CIS',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row



truncate table utb_hedis_lsc_sampleframe_MCD

insert into	dbo.utb_hedis_lsc_sampleframe_MCD
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'MCD',
		hedis_measure_init	= 'LSC',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row
--**********************************************************************************
--**********************************************************************************





----**********************************************************************************
----**********************************************************************************
----CMC
----exec POP_HEDIS_FACT_CMC '20071231', '20070101', '20071231'
----**********************************************************************************
----**********************************************************************************
--
----**********************************************************************************
----**********************************************************************************
--truncate table utb_hedis_systematic_sample
--
--insert into	dbo.utb_hedis_systematic_sample
--(		ihds_member_id,
--		last_name,
--		first_name,
--		dob )
--select	ihds_member_id			= a.ihds_member_id,
--		last_name				= d.NameLast,
--		first_name				= d.NameFirst,
--		dob						= c.dob
--from	utb_hedis_cmc a
--		inner join dw_hedis_member_elig b on
--			a.ihds_member_id = b.ihds_member_id and
--			'20071231' between eff_date and term_date
--		inner join dw_hedis_member c on
--			a.ihds_member_id = c.ihds_member_id 
--		inner join member d on
--			a.ihds_member_id = d.ihds_member_id
--where	cmc_hedis_eligibility_flag = 1 and
--		cmc_denominator_flag = 1 and
--		cmc_exclusion_flag = 0 and
--		case	when lob = 'MDE' then 'MCD'
--				when lob = 'MD'  then 'MCD'
--				when lob = 'MLI' then 'MCD'
--				when lob = 'MRB' then 'MCD'
--				when lob = 'MR'  then 'MCR'
--				when lob = 'MP'  then 'MP'
--				when lob = 'MC'  then 'MCR'
--				when lob = 'PPO' then 'PPO'
--				when lob = 'POS' then 'COM'
--				when lob = 'HMO' then 'COM'
--				when lob = 'CHP' then 'CHP'
--				else ''
--		  end = 'CHP'
--
--exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.04'
--
--
--truncate table utb_hedis_cmc_sampleframe_CHP
--
--insert	into dbo.utb_hedis_cmc_sampleframe_CHP
--select	a.ihds_member_id,
--		memid				= ltrim(rtrim(CustomerMemberID)),
--		dob					= ltrim(rtrim(dob)),
--		first_name			= ltrim(rtrim(first_name)),
--		last_name			= ltrim(rtrim(last_name)),
--		product				= 'CHP',
--		hedis_measure_init	= 'CMC',
--		systematic_order_row = systematic_order_row,
--		sample_row			= sample_row,
--		sample_indicator	=	convert(varchar(10),
--								case	when sample_type = 'primary'
--										then 'sample'
--										when sample_type = 'auxiliary'
--										then 'oversample'
--								end) ,
--		systematic_sample_mrss				= a.systematic_sample_mrss,
--		systematic_sample_em				= a.systematic_sample_em,
--		systematic_sample_fss				= a.systematic_sample_fss,
--		systematic_sample_n					= a.systematic_sample_n,
--		systematic_sample_start				= a.systematic_sample_start,
--		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
--		systematic_sample_rand				= a.systematic_sample_rand,
--		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
--from	utb_hedis_systematic_sample a
--		inner join member b on
--			a.ihds_member_id = b.ihds_member_id
--order by systematic_order_row,
--		sample_row
----**********************************************************************************
----**********************************************************************************
--
--
----**********************************************************************************
----**********************************************************************************
--truncate table utb_hedis_systematic_sample
--
--insert into	dbo.utb_hedis_systematic_sample
--(		ihds_member_id,
--		last_name,
--		first_name,
--		dob )
--select	ihds_member_id			= a.ihds_member_id,
--		last_name				= d.NameLast,
--		first_name				= d.NameFirst,
--		dob						= c.dob
--from	utb_hedis_cmc a
--		inner join dw_hedis_member_elig b on
--			a.ihds_member_id = b.ihds_member_id and
--			'20071231' between eff_date and term_date
--		inner join dw_hedis_member c on
--			a.ihds_member_id = c.ihds_member_id 
--		inner join member d on
--			a.ihds_member_id = d.ihds_member_id
--where	cmc_hedis_eligibility_flag = 1 and
--		cmc_denominator_flag = 1 and
--		cmc_exclusion_flag = 0 and
--		case	when lob = 'MDE' then 'MCD'
--				when lob = 'MD'  then 'MCD'
--				when lob = 'MLI' then 'MCD'
--				when lob = 'MRB' then 'MCD'
--				when lob = 'MR'  then 'MCR'
--				when lob = 'MP'  then 'MP'
--				when lob = 'MC'  then 'MCR'
--				when lob = 'PPO' then 'PPO'
--				when lob = 'POS' then 'COM'
--				when lob = 'HMO' then 'COM'
--				when lob = 'CHP' then 'CHP'
--				else ''
--		  end = 'MCD'
--
--exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.04'
--
--
--
--truncate table utb_hedis_cmc_sampleframe_MCD
--
--insert into	dbo.utb_hedis_cmc_sampleframe_MCD
--select	a.ihds_member_id,
--		memid				= ltrim(rtrim(CustomerMemberID)),
--		dob					= ltrim(rtrim(dob)),
--		first_name			= ltrim(rtrim(first_name)),
--		last_name			= ltrim(rtrim(last_name)),
--		product				= 'MCD',
--		hedis_measure_init	= 'CMC',
--		systematic_order_row = systematic_order_row,
--		sample_row			= sample_row,
--		sample_indicator	=	convert(varchar(10),
--								case	when sample_type = 'primary'
--										then 'sample'
--										when sample_type = 'auxiliary'
--										then 'oversample'
--								end) ,
--		systematic_sample_mrss				= a.systematic_sample_mrss,
--		systematic_sample_em				= a.systematic_sample_em,
--		systematic_sample_fss				= a.systematic_sample_fss,
--		systematic_sample_n					= a.systematic_sample_n,
--		systematic_sample_start				= a.systematic_sample_start,
--		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
--		systematic_sample_rand				= a.systematic_sample_rand,
--		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
--from	utb_hedis_systematic_sample a
--		inner join member b on
--			a.ihds_member_id = b.ihds_member_id
--order by systematic_order_row,
--		sample_row
----**********************************************************************************
----**********************************************************************************







----**********************************************************************************
----**********************************************************************************
----W15
----exec POP_HEDIS_FACT_W15 '20071231', '20070101', '20071231'
----**********************************************************************************
----**********************************************************************************
--
----**********************************************************************************
----**********************************************************************************
--truncate table utb_hedis_systematic_sample
--
--insert into	dbo.utb_hedis_systematic_sample
--(		ihds_member_id,
--		last_name,
--		first_name,
--		dob )
--select	ihds_member_id			= a.ihds_member_id,
--		last_name				= d.NameLast,
--		first_name				= d.NameFirst,
--		dob						= c.dob
--from	utb_hedis_w15 a
--		inner join dw_hedis_member_elig b on
--			a.ihds_member_id = b.ihds_member_id and
--			w15_cont_elig_eval_end between eff_date and term_date
--		inner join dw_hedis_member c on
--			a.ihds_member_id = c.ihds_member_id 
--		inner join member d on
--			a.ihds_member_id = d.ihds_member_id
--where	w15_hedis_eligibility_flag = 1 and
--		w15_denominator_flag = 1 and
--		case	when lob = 'MDE' then 'MCD'
--				when lob = 'MD'  then 'MCD'
--				when lob = 'MLI' then 'MCD'
--				when lob = 'MRB' then 'MCD'
--				when lob = 'MR'  then 'MCR'
--				when lob = 'MP'  then 'MP'
--				when lob = 'MC'  then 'MCR'
--				when lob = 'PPO' then 'PPO'
--				when lob = 'POS' then 'COM'
--				when lob = 'HMO' then 'COM'
--				when lob = 'CHP' then 'CHP'
--				else ''
--		  end = 'CHP'
--
--exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.66'
--
--
--truncate table utb_hedis_w15_sampleframe_CHP
--
--insert	into dbo.utb_hedis_w15_sampleframe_CHP
--select	a.ihds_member_id,
--		memid				= ltrim(rtrim(CustomerMemberID)),
--		dob					= ltrim(rtrim(dob)),
--		first_name			= ltrim(rtrim(first_name)),
--		last_name			= ltrim(rtrim(last_name)),
--		product				= 'CHP',
--		hedis_measure_init	= 'W15',
--		systematic_order_row = systematic_order_row,
--		sample_row			= sample_row,
--		sample_indicator	=	convert(varchar(10),
--								case	when sample_type = 'primary'
--										then 'sample'
--										when sample_type = 'auxiliary'
--										then 'oversample'
--								end) ,
--		systematic_sample_mrss				= a.systematic_sample_mrss,
--		systematic_sample_em				= a.systematic_sample_em,
--		systematic_sample_fss				= a.systematic_sample_fss,
--		systematic_sample_n					= a.systematic_sample_n,
--		systematic_sample_start				= a.systematic_sample_start,
--		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
--		systematic_sample_rand				= a.systematic_sample_rand,
--		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
--from	utb_hedis_systematic_sample a
--		inner join member b on
--			a.ihds_member_id = b.ihds_member_id
--order by systematic_order_row,
--		sample_row
----**********************************************************************************
----**********************************************************************************
--
--
----**********************************************************************************
----**********************************************************************************
--truncate table utb_hedis_systematic_sample
--
--insert into	dbo.utb_hedis_systematic_sample
--(		ihds_member_id,
--		last_name,
--		first_name,
--		dob )
--select	ihds_member_id			= a.ihds_member_id,
--		last_name				= d.NameLast,
--		first_name				= d.NameFirst,
--		dob						= c.dob
--from	utb_hedis_w15 a
--		inner join dw_hedis_member_elig b on
--			a.ihds_member_id = b.ihds_member_id and
--			w15_cont_elig_eval_end between eff_date and term_date
--		inner join dw_hedis_member c on
--			a.ihds_member_id = c.ihds_member_id 
--		inner join member d on
--			a.ihds_member_id = d.ihds_member_id
--where	w15_hedis_eligibility_flag = 1 and
--		w15_denominator_flag = 1 and
--		case	when lob = 'MDE' then 'MCD'
--				when lob = 'MD'  then 'MCD'
--				when lob = 'MLI' then 'MCD'
--				when lob = 'MRB' then 'MCD'
--				when lob = 'MR'  then 'MCR'
--				when lob = 'MP'  then 'MP'
--				when lob = 'MC'  then 'MCR'
--				when lob = 'PPO' then 'PPO'
--				when lob = 'POS' then 'COM'
--				when lob = 'HMO' then 'COM'
--				when lob = 'CHP' then 'CHP'
--				else ''
--		  end = 'MCD'
--
--exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.66'
--
--
--truncate table utb_hedis_w15_sampleframe_MCD
--
--insert into	dbo.utb_hedis_w15_sampleframe_MCD
--select	a.ihds_member_id,
--		memid				= ltrim(rtrim(CustomerMemberID)),
--		dob					= ltrim(rtrim(dob)),
--		first_name			= ltrim(rtrim(first_name)),
--		last_name			= ltrim(rtrim(last_name)),
--		product				= 'MCD',
--		hedis_measure_init	= 'W15',
--		systematic_order_row = systematic_order_row,
--		sample_row			= sample_row,
--		sample_indicator	=	convert(varchar(10),
--								case	when sample_type = 'primary'
--										then 'sample'
--										when sample_type = 'auxiliary'
--										then 'oversample'
--								end) ,
--		systematic_sample_mrss				= a.systematic_sample_mrss,
--		systematic_sample_em				= a.systematic_sample_em,
--		systematic_sample_fss				= a.systematic_sample_fss,
--		systematic_sample_n					= a.systematic_sample_n,
--		systematic_sample_start				= a.systematic_sample_start,
--		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
--		systematic_sample_rand				= a.systematic_sample_rand,
--		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
--from	utb_hedis_systematic_sample a
--		inner join member b on
--			a.ihds_member_id = b.ihds_member_id
--order by systematic_order_row,
--		sample_row
----**********************************************************************************
----**********************************************************************************
--
--
--
--
--
--
--
--
----**********************************************************************************
----**********************************************************************************
----W34
----exec POP_HEDIS_FACT_W34 '20071231', '20070101', '20071231'
----**********************************************************************************
----**********************************************************************************
--
----**********************************************************************************
----**********************************************************************************
--truncate table utb_hedis_systematic_sample
--
--insert into	dbo.utb_hedis_systematic_sample
--(		ihds_member_id,
--		last_name,
--		first_name,
--		dob )
--select	ihds_member_id			= a.ihds_member_id,
--		last_name				= d.NameLast,
--		first_name				= d.NameFirst,
--		dob						= c.dob
--from	utb_hedis_w34 a
--		inner join dw_hedis_member_elig b on
--			a.ihds_member_id = b.ihds_member_id and
--			'20071231' between eff_date and term_date
--		inner join dw_hedis_member c on
--			a.ihds_member_id = c.ihds_member_id 
--		inner join member d on
--			a.ihds_member_id = d.ihds_member_id
--where	w34_hedis_eligibility_flag = 1 and
--		w34_denominator_flag = 1 and
--		w34_exclusion_flag = 0 and
--		case	when lob = 'MDE' then 'MCD'
--				when lob = 'MD'  then 'MCD'
--				when lob = 'MLI' then 'MCD'
--				when lob = 'MRB' then 'MCD'
--				when lob = 'MR'  then 'MCR'
--				when lob = 'MP'  then 'MP'
--				when lob = 'MC'  then 'MCR'
--				when lob = 'PPO' then 'PPO'
--				when lob = 'POS' then 'COM'
--				when lob = 'HMO' then 'COM'
--				when lob = 'CHP' then 'CHP'
--				else ''
--		  end = 'CHP'
--
--exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.48'
--
--
--
--truncate table utb_hedis_w34_sampleframe_CHP
--
--insert	into dbo.utb_hedis_w34_sampleframe_CHP
--select	a.ihds_member_id,
--		memid				= ltrim(rtrim(CustomerMemberID)),
--		dob					= ltrim(rtrim(dob)),
--		first_name			= ltrim(rtrim(first_name)),
--		last_name			= ltrim(rtrim(last_name)),
--		product				= 'CHP',
--		hedis_measure_init	= 'W34',
--		systematic_order_row = systematic_order_row,
--		sample_row			= sample_row,
--		sample_indicator	=	convert(varchar(10),
--								case	when sample_type = 'primary'
--										then 'sample'
--										when sample_type = 'auxiliary'
--										then 'oversample'
--								end) ,
--		systematic_sample_mrss				= a.systematic_sample_mrss,
--		systematic_sample_em				= a.systematic_sample_em,
--		systematic_sample_fss				= a.systematic_sample_fss,
--		systematic_sample_n					= a.systematic_sample_n,
--		systematic_sample_start				= a.systematic_sample_start,
--		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
--		systematic_sample_rand				= a.systematic_sample_rand,
--		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
--from	utb_hedis_systematic_sample a
--		inner join member b on
--			a.ihds_member_id = b.ihds_member_id
--order by systematic_order_row,
--		sample_row
----**********************************************************************************
----**********************************************************************************
--
--
----**********************************************************************************
----**********************************************************************************
--truncate table utb_hedis_systematic_sample
--
--insert into	dbo.utb_hedis_systematic_sample
--(		ihds_member_id,
--		last_name,
--		first_name,
--		dob )
--select	ihds_member_id			= a.ihds_member_id,
--		last_name				= d.NameLast,
--		first_name				= d.NameFirst,
--		dob						= c.dob
--from	utb_hedis_w34 a
--		inner join dw_hedis_member_elig b on
--			a.ihds_member_id = b.ihds_member_id and
--			'20071231' between eff_date and term_date
--		inner join dw_hedis_member c on
--			a.ihds_member_id = c.ihds_member_id 
--		inner join member d on
--			a.ihds_member_id = d.ihds_member_id
--where	w34_hedis_eligibility_flag = 1 and
--		w34_denominator_flag = 1 and
--		w34_exclusion_flag = 0 and
--		case	when lob = 'MDE' then 'MCD'
--				when lob = 'MD'  then 'MCD'
--				when lob = 'MLI' then 'MCD'
--				when lob = 'MRB' then 'MCD'
--				when lob = 'MR'  then 'MCR'
--				when lob = 'MP'  then 'MP'
--				when lob = 'MC'  then 'MCR'
--				when lob = 'PPO' then 'PPO'
--				when lob = 'POS' then 'COM'
--				when lob = 'HMO' then 'COM'
--				when lob = 'CHP' then 'CHP'
--				else ''
--		  end = 'MCD'
--
--exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.48'
--
--
--truncate table utb_hedis_w34_sampleframe_MCD
--
--insert into	dbo.utb_hedis_w34_sampleframe_MCD
--select	a.ihds_member_id,
--		memid				= ltrim(rtrim(CustomerMemberID)),
--		dob					= ltrim(rtrim(dob)),
--		first_name			= ltrim(rtrim(first_name)),
--		last_name			= ltrim(rtrim(last_name)),
--		product				= 'MCD',
--		hedis_measure_init	= 'W34',
--		systematic_order_row = systematic_order_row,
--		sample_row			= sample_row,
--		sample_indicator	=	convert(varchar(10),
--								case	when sample_type = 'primary'
--										then 'sample'
--										when sample_type = 'auxiliary'
--										then 'oversample'
--								end) ,
--		systematic_sample_mrss				= a.systematic_sample_mrss,
--		systematic_sample_em				= a.systematic_sample_em,
--		systematic_sample_fss				= a.systematic_sample_fss,
--		systematic_sample_n					= a.systematic_sample_n,
--		systematic_sample_start				= a.systematic_sample_start,
--		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
--		systematic_sample_rand				= a.systematic_sample_rand,
--		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
--from	utb_hedis_systematic_sample a
--		inner join member b on
--			a.ihds_member_id = b.ihds_member_id
--order by systematic_order_row,
--		sample_row
----**********************************************************************************
----**********************************************************************************








--**********************************************************************************
--**********************************************************************************
--CBP
--exec POP_HEDIS_FACT_CBP '20071231', '20070101', '20071231'
--**********************************************************************************
--**********************************************************************************

--**********************************************************************************
--**********************************************************************************
truncate table utb_hedis_systematic_sample

insert into	dbo.utb_hedis_systematic_sample
(		ihds_member_id,
		last_name,
		first_name,
		dob )
select	ihds_member_id			= a.ihds_member_id,
		last_name				= d.NameLast,
		first_name				= d.NameFirst,
		dob						= c.dob --select top 10 *
from	utb_hedis_cbp a
		inner join dw_hedis_member_elig b on
			a.ihds_member_id = b.ihds_member_id and
			@lcEndDate between eff_date and term_date
		inner join dw_hedis_member c on
			a.ihds_member_id = c.ihds_member_id 
		inner join member d on
			a.ihds_member_id = d.ihds_member_id
where	cbp_hedis_eligibility_flag = 1 and
		cbp_denominator_flag = 1 and
		cbp_exclusion_flag = 0 and
		case	when lob = 'MDE' then 'MCD'
				when lob = 'MD'  then 'MCD'
				when lob = 'MLI' then 'MCD'
				when lob = 'MRB' then 'MCD'
				when lob = 'MR'  then 'MCR'
				when lob = 'MP'  then 'MP'
				when lob = 'MC'  then 'MCR'
				when lob = 'PPO' then 'PPO'
				when lob = 'POS' then 'COM'
				when lob = 'HMO' then 'COM'
				when lob = 'CHP' then 'CHP'
				else ''
		  end = 'CHP'

exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.15', '0.49'



truncate table utb_hedis_cbp_sampleframe_CHP

insert	into dbo.utb_hedis_cbp_sampleframe_CHP
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'CHP',
		hedis_measure_init	= 'CBP',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row
--**********************************************************************************
--**********************************************************************************


--**********************************************************************************
--**********************************************************************************
truncate table utb_hedis_systematic_sample

insert into	dbo.utb_hedis_systematic_sample
(		ihds_member_id,
		last_name,
		first_name,
		dob )
select	ihds_member_id			= a.ihds_member_id,
		last_name				= d.NameLast,
		first_name				= d.NameFirst,
		dob						= c.dob
from	utb_hedis_cbp a
		inner join dw_hedis_member_elig b on
			a.ihds_member_id = b.ihds_member_id and
			@lcEndDate between eff_date and term_date
		inner join dw_hedis_member c on
			a.ihds_member_id = c.ihds_member_id 
		inner join member d on
			a.ihds_member_id = d.ihds_member_id
where	cbp_hedis_eligibility_flag = 1 and
		cbp_denominator_flag = 1 and
		cbp_exclusion_flag = 0 and
		case	when lob = 'MDE' then 'MCD'
				when lob = 'MD'  then 'MCD'
				when lob = 'MLI' then 'MCD'
				when lob = 'MRB' then 'MCD'
				when lob = 'MR'  then 'MCR'
				when lob = 'MP'  then 'MP'
				when lob = 'MC'  then 'MCR'
				when lob = 'PPO' then 'PPO'
				when lob = 'POS' then 'COM'
				when lob = 'HMO' then 'COM'
				when lob = 'CHP' then 'CHP'
				else ''
		  end = 'MCD'

exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.15', '0.49'


truncate table utb_hedis_cbp_sampleframe_MCD

insert into	dbo.utb_hedis_cbp_sampleframe_MCD
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'MCD',
		hedis_measure_init	= 'CBP',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row
--**********************************************************************************
--**********************************************************************************








--**********************************************************************************
--**********************************************************************************
--CCS
--exec POP_HEDIS_FACT_CCS '20071231', '20070101', '20071231'
--**********************************************************************************
--**********************************************************************************

--**********************************************************************************
--**********************************************************************************
truncate table utb_hedis_systematic_sample

insert into	dbo.utb_hedis_systematic_sample
(		ihds_member_id,
		last_name,
		first_name,
		dob )
select	ihds_member_id			= a.ihds_member_id,
		last_name				= d.NameLast,
		first_name				= d.NameFirst,
		dob						= c.dob --select top 10 *
from	utb_hedis_ccs a
		inner join dw_hedis_member_elig b on
			a.ihds_member_id = b.ihds_member_id and
			@lcEndDate between eff_date and term_date
		inner join dw_hedis_member c on
			a.ihds_member_id = c.ihds_member_id 
		inner join member d on
			a.ihds_member_id = d.ihds_member_id
where	ccs_hedis_eligible_flag = 1 and
		ccs_denominator_flag = 1 and
		ccs_exclusion_flag = 0 and
		case	when lob = 'MDE' then 'MCD'
				when lob = 'MD'  then 'MCD'
				when lob = 'MLI' then 'MCD'
				when lob = 'MRB' then 'MCD'
				when lob = 'MR'  then 'MCR'
				when lob = 'MP'  then 'MP'
				when lob = 'MC'  then 'MCR'
				when lob = 'PPO' then 'PPO'
				when lob = 'POS' then 'COM'
				when lob = 'HMO' then 'COM'
				when lob = 'CHP' then 'CHP'
				else ''
		  end = 'CHP'

exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.45'



truncate table utb_hedis_ccs_sampleframe_CHP

insert	into dbo.utb_hedis_ccs_sampleframe_CHP
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'CHP',
		hedis_measure_init	= 'CCS',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row
--**********************************************************************************
--**********************************************************************************


--**********************************************************************************
--**********************************************************************************
truncate table utb_hedis_systematic_sample

insert into	dbo.utb_hedis_systematic_sample
(		ihds_member_id,
		last_name,
		first_name,
		dob )
select	ihds_member_id			= a.ihds_member_id,
		last_name				= d.NameLast,
		first_name				= d.NameFirst,
		dob						= c.dob
from	utb_hedis_ccs a
		inner join dw_hedis_member_elig b on
			a.ihds_member_id = b.ihds_member_id and
			@lcEndDate between eff_date and term_date
		inner join dw_hedis_member c on
			a.ihds_member_id = c.ihds_member_id 
		inner join member d on
			a.ihds_member_id = d.ihds_member_id
where	ccs_hedis_eligible_flag = 1 and
		ccs_denominator_flag = 1 and
		ccs_exclusion_flag = 0 and
		case	when lob = 'MDE' then 'MCD'
				when lob = 'MD'  then 'MCD'
				when lob = 'MLI' then 'MCD'
				when lob = 'MRB' then 'MCD'
				when lob = 'MR'  then 'MCR'
				when lob = 'MP'  then 'MP'
				when lob = 'MC'  then 'MCR'
				when lob = 'PPO' then 'PPO'
				when lob = 'POS' then 'COM'
				when lob = 'HMO' then 'COM'
				when lob = 'CHP' then 'CHP'
				else ''
		  end = 'MCD'

exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.45'


truncate table utb_hedis_ccs_sampleframe_MCD

insert into	dbo.utb_hedis_ccs_sampleframe_MCD
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'MCD',
		hedis_measure_init	= 'CCS',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row
--**********************************************************************************
--**********************************************************************************






--**********************************************************************************
--**********************************************************************************
--PPC
--exec POP_HEDIS_FACT_PPC '20071231', '20070101', '20071231'
--**********************************************************************************
--**********************************************************************************

--**********************************************************************************
--**********************************************************************************
truncate table utb_hedis_systematic_sample

insert into	dbo.utb_hedis_systematic_sample
(		ihds_member_id,
		last_name,
		first_name,
		dob )
select	ihds_member_id			= a.ihds_member_id,
		last_name				= d.NameLast,
		first_name				= d.NameFirst,
		dob						= c.dob --select top 10 *
from	utb_hedis_ppc a
		inner join dw_hedis_member_elig b on
			a.ihds_member_id = b.ihds_member_id and
			ppc_cont_elig_eval_end between eff_date and term_date
		inner join dw_hedis_member c on
			a.ihds_member_id = c.ihds_member_id 
		inner join member d on
			a.ihds_member_id = d.ihds_member_id
where	ppc_hedis_eligible_flag = 1 and
		ppc_prenatal_care_den_flag = 1 and
		case	when lob = 'MDE' then 'MCD'
				when lob = 'MD'  then 'MCD'
				when lob = 'MLI' then 'MCD'
				when lob = 'MRB' then 'MCD'
				when lob = 'MR'  then 'MCR'
				when lob = 'MP'  then 'MP'
				when lob = 'MC'  then 'MCR'
				when lob = 'PPO' then 'PPO'
				when lob = 'POS' then 'COM'
				when lob = 'HMO' then 'COM'
				when lob = 'CHP' then 'CHP'
				else ''
		  end = 'CHP'

exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.26'


truncate table utb_hedis_ppc_sampleframe_CHP

insert	into dbo.utb_hedis_ppc_sampleframe_CHP
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'CHP',
		hedis_measure_init	= 'PPC',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row
--**********************************************************************************
--**********************************************************************************


--**********************************************************************************
--**********************************************************************************
truncate table utb_hedis_systematic_sample

insert into	dbo.utb_hedis_systematic_sample
(		ihds_member_id,
		last_name,
		first_name,
		dob )
select	ihds_member_id			= a.ihds_member_id,
		last_name				= d.NameLast,
		first_name				= d.NameFirst,
		dob						= c.dob
from	utb_hedis_ppc a
		inner join dw_hedis_member_elig b on
			a.ihds_member_id = b.ihds_member_id and
			ppc_cont_elig_eval_end between eff_date and term_date
		inner join dw_hedis_member c on
			a.ihds_member_id = c.ihds_member_id 
		inner join member d on
			a.ihds_member_id = d.ihds_member_id
where	ppc_hedis_eligible_flag = 1 and
		ppc_prenatal_care_den_flag = 1 and
		case	when lob = 'MDE' then 'MCD'
				when lob = 'MD'  then 'MCD'
				when lob = 'MLI' then 'MCD'
				when lob = 'MRB' then 'MCD'
				when lob = 'MR'  then 'MCR'
				when lob = 'MP'  then 'MP'
				when lob = 'MC'  then 'MCR'
				when lob = 'PPO' then 'PPO'
				when lob = 'POS' then 'COM'
				when lob = 'HMO' then 'COM'
				when lob = 'CHP' then 'CHP'
				else ''
		  end = 'MCD'

exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.26'


truncate table utb_hedis_ppc_sampleframe_MCD

insert into	dbo.utb_hedis_ppc_sampleframe_MCD
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'MCD',
		hedis_measure_init	= 'PPC',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row




truncate table utb_hedis_fpc_sampleframe_MCD

insert into	dbo.utb_hedis_fpc_sampleframe_MCD
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'MCD',
		hedis_measure_init	= 'FPC',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row

--**********************************************************************************
--**********************************************************************************









--**********************************************************************************
--**********************************************************************************
--ABA
--exec POP_HEDIS_FACT_ABA @lcEndDate, '20080101', @lcEndDate
--**********************************************************************************
--**********************************************************************************
--select	aba_denominator_flag = sum(aba_denominator_flag),
--		aba_numerator_flag = sum(aba_numerator_flag)
----select *
--from	utb_hedis_aba
--where	aba_denominator_flag = 1 and
--		aba_hedis_eligible_flag = 1 and
--		aba_exclusion_flag = 0
--**********************************************************************************
--**********************************************************************************
truncate table utb_hedis_systematic_sample

insert into	dbo.utb_hedis_systematic_sample
(		ihds_member_id,
		last_name,
		first_name,
		dob )
select	ihds_member_id			= a.ihds_member_id,
		last_name				= d.NameLast,
		first_name				= d.NameFirst,
		dob						= c.dob --select top 10 *
from	utb_hedis_aba a
		inner join dw_hedis_member_elig b on
			a.ihds_member_id = b.ihds_member_id and
			a.aba_last_cont_elig_day between eff_date and term_date
		inner join dw_hedis_member c on
			a.ihds_member_id = c.ihds_member_id 
		inner join member d on
			a.ihds_member_id = d.ihds_member_id
where	aba_denominator_flag = 1 and
		aba_hedis_eligible_flag = 1 and
		aba_exclusion_flag = 0 and
		case	when lob = 'MDE' then 'MCD'
				when lob = 'MD'  then 'MCD'
				when lob = 'MLI' then 'MCD'
				when lob = 'MRB' then 'MCD'
				when lob = 'MR'  then 'MCR'
				when lob = 'MP'  then 'MP'
				when lob = 'MC'  then 'MCR'
				when lob = 'PPO' then 'PPO'
				when lob = 'POS' then 'COM'
				when lob = 'HMO' then 'COM'
				when lob = 'CHP' then 'CHP'
				else ''
		  end = 'CHP'

exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.97'


truncate table utb_hedis_aba_sampleframe_CHP

insert	into dbo.utb_hedis_aba_sampleframe_CHP
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'CHP',
		hedis_measure_init	= 'ABA',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row
--**********************************************************************************
--**********************************************************************************


--**********************************************************************************
--**********************************************************************************
truncate table utb_hedis_systematic_sample

insert into	dbo.utb_hedis_systematic_sample
(		ihds_member_id,
		last_name,
		first_name,
		dob )
select	ihds_member_id			= a.ihds_member_id,
		last_name				= d.NameLast,
		first_name				= d.NameFirst,
		dob						= c.dob --select top 10 *
from	utb_hedis_aba a
		inner join dw_hedis_member_elig b on
			a.ihds_member_id = b.ihds_member_id and
			a.aba_last_cont_elig_day between eff_date and term_date
		inner join dw_hedis_member c on
			a.ihds_member_id = c.ihds_member_id 
		inner join member d on
			a.ihds_member_id = d.ihds_member_id
where	aba_denominator_flag = 1 and
		aba_hedis_eligible_flag = 1 and
		aba_exclusion_flag = 0 and
		case	when lob = 'MDE' then 'MCD'
				when lob = 'MD'  then 'MCD'
				when lob = 'MLI' then 'MCD'
				when lob = 'MRB' then 'MCD'
				when lob = 'MR'  then 'MCR'
				when lob = 'MP'  then 'MP'
				when lob = 'MC'  then 'MCR'
				when lob = 'PPO' then 'PPO'
				when lob = 'POS' then 'COM'
				when lob = 'HMO' then 'COM'
				when lob = 'CHP' then 'CHP'
				else ''
		  end = 'MCD'

exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.97'


truncate table utb_hedis_aba_sampleframe_MCD

insert into	dbo.utb_hedis_aba_sampleframe_MCD
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'MCD',
		hedis_measure_init	= 'ABA',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row
--**********************************************************************************
--**********************************************************************************





--**********************************************************************************
--**********************************************************************************
--WCC
--exec POP_HEDIS_FACT_WCC @lcEndDate, '20080101', @lcEndDate
--**********************************************************************************
--**********************************************************************************
--select	wcc_denominator_flag			= sum(wcc_denominator_flag),
--		wcc_numerator_bmi				= sum(wcc_numerator_bmi),
--		wcc_numerator_nutrition_counsel = sum(wcc_numerator_nutrition_counsel),
--		wcc_numerator_physical_activity = sum(wcc_numerator_physical_activity)
----select *
--from	utb_hedis_wcc
--where	wcc_denominator_flag = 1 and
--		wcc_hedis_eligible_flag = 1 and
--		wcc_exclusion_flag = 0
--**********************************************************************************
--**********************************************************************************

truncate table utb_hedis_systematic_sample

insert into	dbo.utb_hedis_systematic_sample
(		ihds_member_id,
		last_name,
		first_name,
		dob )
select	ihds_member_id			= a.ihds_member_id,
		last_name				= d.NameLast,
		first_name				= d.NameFirst,
		dob						= c.dob --select top 10 *
from	utb_hedis_wcc a
		inner join dw_hedis_member_elig b on
			a.ihds_member_id = b.ihds_member_id and
			a.wcc_last_cont_elig_day between eff_date and term_date
		inner join dw_hedis_member c on
			a.ihds_member_id = c.ihds_member_id 
		inner join member d on
			a.ihds_member_id = d.ihds_member_id
where	wcc_denominator_flag = 1 and
		wcc_hedis_eligible_flag = 1 and
		wcc_exclusion_flag = 0 and
		case	when lob = 'MDE' then 'MCD'
				when lob = 'MD'  then 'MCD'
				when lob = 'MLI' then 'MCD'
				when lob = 'MRB' then 'MCD'
				when lob = 'MR'  then 'MCR'
				when lob = 'MP'  then 'MP'
				when lob = 'MC'  then 'MCR'
				when lob = 'PPO' then 'PPO'
				when lob = 'POS' then 'COM'
				when lob = 'HMO' then 'COM'
				when lob = 'CHP' then 'CHP'
				else ''
		  end = 'CHP'

exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.15'


truncate table utb_hedis_wcc_sampleframe_CHP

insert	into dbo.utb_hedis_wcc_sampleframe_CHP
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'CHP',
		hedis_measure_init	= 'WCC',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row
--**********************************************************************************
--**********************************************************************************


--**********************************************************************************
--**********************************************************************************
truncate table utb_hedis_systematic_sample

insert into	dbo.utb_hedis_systematic_sample
(		ihds_member_id,
		last_name,
		first_name,
		dob )
select	ihds_member_id			= a.ihds_member_id,
		last_name				= d.NameLast,
		first_name				= d.NameFirst,
		dob						= c.dob --select top 10 *
from	utb_hedis_wcc a
		inner join dw_hedis_member_elig b on
			a.ihds_member_id = b.ihds_member_id and
			a.wcc_last_cont_elig_day between eff_date and term_date
		inner join dw_hedis_member c on
			a.ihds_member_id = c.ihds_member_id 
		inner join member d on
			a.ihds_member_id = d.ihds_member_id
where	wcc_denominator_flag = 1 and
		wcc_hedis_eligible_flag = 1 and
		wcc_exclusion_flag = 0 and
		case	when lob = 'MDE' then 'MCD'
				when lob = 'MD'  then 'MCD'
				when lob = 'MLI' then 'MCD'
				when lob = 'MRB' then 'MCD'
				when lob = 'MR'  then 'MCR'
				when lob = 'MP'  then 'MP'
				when lob = 'MC'  then 'MCR'
				when lob = 'PPO' then 'PPO'
				when lob = 'POS' then 'COM'
				when lob = 'HMO' then 'COM'
				when lob = 'CHP' then 'CHP'
				else ''
		  end = 'MCD'

exec POP_HEDIS_SYSTEMATIC_SAMPLE '411', '0.05', '0.15'


truncate table utb_hedis_wcc_sampleframe_MCD

insert into	dbo.utb_hedis_wcc_sampleframe_MCD
select	a.ihds_member_id,
		memid				= ltrim(rtrim(CustomerMemberID)),
		dob					= ltrim(rtrim(dob)),
		first_name			= ltrim(rtrim(first_name)),
		last_name			= ltrim(rtrim(last_name)),
		product				= 'MCD',
		hedis_measure_init	= 'WCC',
		systematic_order_row = systematic_order_row,
		sample_row			= sample_row,
		sample_indicator	=	convert(varchar(10),
								case	when sample_type = 'primary'
										then 'sample'
										when sample_type = 'auxiliary'
										then 'oversample'
								end) ,
		systematic_sample_mrss				= a.systematic_sample_mrss,
		systematic_sample_em				= a.systematic_sample_em,
		systematic_sample_fss				= a.systematic_sample_fss,
		systematic_sample_n					= a.systematic_sample_n,
		systematic_sample_start				= a.systematic_sample_start,
		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
		systematic_sample_rand				= a.systematic_sample_rand,
		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
from	utb_hedis_systematic_sample a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
order by systematic_order_row,
		sample_row
--**********************************************************************************
--**********************************************************************************




--
--
----**********************************************************************************
----**********************************************************************************
--
----**********************************************************************************
----**********************************************************************************
--select	hiv_ccs_denominator_flag			= sum(hiv_ccs_denominator_flag),
--		hiv_ccs_numerator_flag				= sum(hiv_ccs_numerator_flag)
----select *
--from	utb_hedis_hiv
--where	hiv_ccs_denominator_flag = 1 and
--		hiv_ccs_excl_flag = 0
--
--select	hiv_arv_undetect_vl_denominator_flag			= sum(hiv_arv_undetect_vl_denominator_flag),
--		hiv_arv_undetect_vl_detect_numerator_flag		= sum(hiv_arv_undetect_vl_detect_numerator_flag),
--		hiv_arv_undetect_vl_noresult_numerator_flag		= sum(hiv_arv_undetect_vl_noresult_numerator_flag),
--		hiv_arv_undetect_vl_notest_numerator_flag		= sum(hiv_arv_undetect_vl_notest_numerator_flag)
----select *
--from	utb_hedis_hiv
--where	hiv_arv_undetect_vl_denominator_flag = 1 
--
----**********************************************************************************
----**********************************************************************************
--
--truncate table utb_hedis_systematic_sample
--
--insert into	dbo.utb_hedis_systematic_sample
--(		ihds_member_id,
--		last_name,
--		first_name,
--		dob )
--select	ihds_member_id			= a.ihds_member_id,
--		last_name				= d.NameLast,
--		first_name				= d.NameFirst,
--		dob						= c.dob --select top 10 *
--from	utb_hedis_hiv a
--		inner join dw_hedis_member_elig b on
--			a.ihds_member_id = b.ihds_member_id and
--			@lcEndDate between eff_date and term_date
--		inner join dw_hedis_member c on
--			a.ihds_member_id = c.ihds_member_id 
--		inner join member d on
--			a.ihds_member_id = d.ihds_member_id
--where	hiv_ccs_denominator_flag = 1 and
--		hiv_ccs_excl_flag = 0 and
--		case	when lob = 'MDE' then 'MCD'
--				when lob = 'MD'  then 'MCD'
--				when lob = 'MLI' then 'MCD'
--				when lob = 'MRB' then 'MCD'
--				when lob = 'MR'  then 'MCR'
--				when lob = 'MP'  then 'MP'
--				when lob = 'MC'  then 'MCR'
--				when lob = 'PPO' then 'PPO'
--				when lob = 'POS' then 'COM'
--				when lob = 'HMO' then 'COM'
--				when lob = 'CHP' then 'CHP'
--				else ''
--		  end = 'CHP'
--
--exec POP_HEDIS_SYSTEMATIC_SAMPLE '100', '0.10', '0.61'
--
--
--truncate table utb_hedis_hi4_sampleframe_CHP
--
--insert	into dbo.utb_hedis_hi4_sampleframe_CHP
--select	a.ihds_member_id,
--		memid				= ltrim(rtrim(CustomerMemberID)),
--		dob					= ltrim(rtrim(dob)),
--		first_name			= ltrim(rtrim(first_name)),
--		last_name			= ltrim(rtrim(last_name)),
--		product				= 'CHP',
--		hedis_measure_init	= 'HI4',
--		systematic_order_row = systematic_order_row,
--		sample_row			= sample_row,
--		sample_indicator	=	convert(varchar(10),
--								case	when sample_type = 'primary'
--										then 'sample'
--										when sample_type = 'auxiliary'
--										then 'oversample'
--								end) ,
--		systematic_sample_mrss				= a.systematic_sample_mrss,
--		systematic_sample_em				= a.systematic_sample_em,
--		systematic_sample_fss				= a.systematic_sample_fss,
--		systematic_sample_n					= a.systematic_sample_n,
--		systematic_sample_start				= a.systematic_sample_start,
--		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
--		systematic_sample_rand				= a.systematic_sample_rand,
--		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
--from	utb_hedis_systematic_sample a
--		inner join member b on
--			a.ihds_member_id = b.ihds_member_id
--order by systematic_order_row,
--		sample_row
----**********************************************************************************
----**********************************************************************************
--
--
----**********************************************************************************
----**********************************************************************************
--truncate table utb_hedis_systematic_sample
--
--insert into	dbo.utb_hedis_systematic_sample
--(		ihds_member_id,
--		last_name,
--		first_name,
--		dob )
--select	ihds_member_id			= a.ihds_member_id,
--		last_name				= d.NameLast,
--		first_name				= d.NameFirst,
--		dob						= c.dob --select top 10 *
--from	utb_hedis_hiv a
--		inner join dw_hedis_member_elig b on
--			a.ihds_member_id = b.ihds_member_id and
--			@lcEndDate between eff_date and term_date
--		inner join dw_hedis_member c on
--			a.ihds_member_id = c.ihds_member_id 
--		inner join member d on
--			a.ihds_member_id = d.ihds_member_id
--where	hiv_ccs_denominator_flag = 1 and
--		hiv_ccs_excl_flag = 0 and
--		case	when lob = 'MDE' then 'MCD'
--				when lob = 'MD'  then 'MCD'
--				when lob = 'MLI' then 'MCD'
--				when lob = 'MRB' then 'MCD'
--				when lob = 'MR'  then 'MCR'
--				when lob = 'MP'  then 'MP'
--				when lob = 'MC'  then 'MCR'
--				when lob = 'PPO' then 'PPO'
--				when lob = 'POS' then 'COM'
--				when lob = 'HMO' then 'COM'
--				when lob = 'CHP' then 'CHP'
--				else ''
--		  end = 'MCD'
--
--exec POP_HEDIS_SYSTEMATIC_SAMPLE '100', '0.10', '0.61'
--
--
--truncate table utb_hedis_hi4_sampleframe_MCD
--
--insert into	dbo.utb_hedis_hi4_sampleframe_MCD
--select	a.ihds_member_id,
--		memid				= ltrim(rtrim(CustomerMemberID)),
--		dob					= ltrim(rtrim(dob)),
--		first_name			= ltrim(rtrim(first_name)),
--		last_name			= ltrim(rtrim(last_name)),
--		product				= 'MCD',
--		hedis_measure_init	= 'HI4',
--		systematic_order_row = systematic_order_row,
--		sample_row			= sample_row,
--		sample_indicator	=	convert(varchar(10),
--								case	when sample_type = 'primary'
--										then 'sample'
--										when sample_type = 'auxiliary'
--										then 'oversample'
--								end) ,
--		systematic_sample_mrss				= a.systematic_sample_mrss,
--		systematic_sample_em				= a.systematic_sample_em,
--		systematic_sample_fss				= a.systematic_sample_fss,
--		systematic_sample_n					= a.systematic_sample_n,
--		systematic_sample_start				= a.systematic_sample_start,
--		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
--		systematic_sample_rand				= a.systematic_sample_rand,
--		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
--from	utb_hedis_systematic_sample a
--		inner join member b on
--			a.ihds_member_id = b.ihds_member_id
--order by systematic_order_row,
--		sample_row
----**********************************************************************************
----**********************************************************************************
--
--
--
--
--
--
--
----**********************************************************************************
----**********************************************************************************
--
----**********************************************************************************
----**********************************************************************************
--select	hiv_arv_undetect_vl_denominator_flag			= sum(hiv_arv_undetect_vl_denominator_flag),
--		hiv_arv_undetect_vl_detect_numerator_flag		= sum(hiv_arv_undetect_vl_detect_numerator_flag),
--		hiv_arv_undetect_vl_noresult_numerator_flag		= sum(hiv_arv_undetect_vl_noresult_numerator_flag),
--		hiv_arv_undetect_vl_notest_numerator_flag		= sum(hiv_arv_undetect_vl_notest_numerator_flag)
----select *
--from	utb_hedis_hiv
--where	hiv_arv_undetect_vl_denominator_flag = 1 
--
----**********************************************************************************
----**********************************************************************************
--
--truncate table utb_hedis_systematic_sample
--
--insert into	dbo.utb_hedis_systematic_sample
--(		ihds_member_id,
--		last_name,
--		first_name,
--		dob )
--select	ihds_member_id			= a.ihds_member_id,
--		last_name				= d.NameLast,
--		first_name				= d.NameFirst,
--		dob						= c.dob --select top 10 *
--from	utb_hedis_hiv a
--		inner join dw_hedis_member_elig b on
--			a.ihds_member_id = b.ihds_member_id and
--			@lcEndDate between eff_date and term_date
--		inner join dw_hedis_member c on
--			a.ihds_member_id = c.ihds_member_id 
--		inner join member d on
--			a.ihds_member_id = d.ihds_member_id
--where	hiv_arv_undetect_vl_denominator_flag = 1  and
--		case	when lob = 'MDE' then 'MCD'
--				when lob = 'MD'  then 'MCD'
--				when lob = 'MLI' then 'MCD'
--				when lob = 'MRB' then 'MCD'
--				when lob = 'MR'  then 'MCR'
--				when lob = 'MP'  then 'MP'
--				when lob = 'MC'  then 'MCR'
--				when lob = 'PPO' then 'PPO'
--				when lob = 'POS' then 'COM'
--				when lob = 'HMO' then 'COM'
--				when lob = 'CHP' then 'CHP'
--				else ''
--		  end = 'CHP'
--
--exec POP_HEDIS_SYSTEMATIC_SAMPLE '100', '0.10', '0.61'
--
--
--truncate table utb_hedis_hi5_sampleframe_CHP
--
--insert	into dbo.utb_hedis_hi5_sampleframe_CHP
--select	a.ihds_member_id,
--		memid				= ltrim(rtrim(CustomerMemberID)),
--		dob					= ltrim(rtrim(dob)),
--		first_name			= ltrim(rtrim(first_name)),
--		last_name			= ltrim(rtrim(last_name)),
--		product				= 'CHP',
--		hedis_measure_init	= 'HI5',
--		systematic_order_row = systematic_order_row,
--		sample_row			= sample_row,
--		sample_indicator	=	convert(varchar(10),
--								case	when sample_type = 'primary'
--										then 'sample'
--										when sample_type = 'auxiliary'
--										then 'oversample'
--								end) ,
--		systematic_sample_mrss				= a.systematic_sample_mrss,
--		systematic_sample_em				= a.systematic_sample_em,
--		systematic_sample_fss				= a.systematic_sample_fss,
--		systematic_sample_n					= a.systematic_sample_n,
--		systematic_sample_start				= a.systematic_sample_start,
--		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
--		systematic_sample_rand				= a.systematic_sample_rand,
--		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
--from	utb_hedis_systematic_sample a
--		inner join member b on
--			a.ihds_member_id = b.ihds_member_id
--order by systematic_order_row,
--		sample_row
----**********************************************************************************
----**********************************************************************************
--
--
----**********************************************************************************
----**********************************************************************************
--truncate table utb_hedis_systematic_sample
--
--insert into	dbo.utb_hedis_systematic_sample
--(		ihds_member_id,
--		last_name,
--		first_name,
--		dob )
--select	ihds_member_id			= a.ihds_member_id,
--		last_name				= d.NameLast,
--		first_name				= d.NameFirst,
--		dob						= c.dob --select top 10 *
--from	utb_hedis_hiv a
--		inner join dw_hedis_member_elig b on
--			a.ihds_member_id = b.ihds_member_id and
--			@lcEndDate between eff_date and term_date
--		inner join dw_hedis_member c on
--			a.ihds_member_id = c.ihds_member_id 
--		inner join member d on
--			a.ihds_member_id = d.ihds_member_id
--where	hiv_arv_undetect_vl_denominator_flag = 1  and
--		case	when lob = 'MDE' then 'MCD'
--				when lob = 'MD'  then 'MCD'
--				when lob = 'MLI' then 'MCD'
--				when lob = 'MRB' then 'MCD'
--				when lob = 'MR'  then 'MCR'
--				when lob = 'MP'  then 'MP'
--				when lob = 'MC'  then 'MCR'
--				when lob = 'PPO' then 'PPO'
--				when lob = 'POS' then 'COM'
--				when lob = 'HMO' then 'COM'
--				when lob = 'CHP' then 'CHP'
--				else ''
--		  end = 'MCD'
--
--exec POP_HEDIS_SYSTEMATIC_SAMPLE '100', '0.10', '0.61'
--
--
--truncate table utb_hedis_hi5_sampleframe_MCD
--
--insert into	dbo.utb_hedis_hi5_sampleframe_MCD
--select	a.ihds_member_id,
--		memid				= ltrim(rtrim(CustomerMemberID)),
--		dob					= ltrim(rtrim(dob)),
--		first_name			= ltrim(rtrim(first_name)),
--		last_name			= ltrim(rtrim(last_name)),
--		product				= 'MCD',
--		hedis_measure_init	= 'HI5',
--		systematic_order_row = systematic_order_row,
--		sample_row			= sample_row,
--		sample_indicator	=	convert(varchar(10),
--								case	when sample_type = 'primary'
--										then 'sample'
--										when sample_type = 'auxiliary'
--										then 'oversample'
--								end) ,
--		systematic_sample_mrss				= a.systematic_sample_mrss,
--		systematic_sample_em				= a.systematic_sample_em,
--		systematic_sample_fss				= a.systematic_sample_fss,
--		systematic_sample_n					= a.systematic_sample_n,
--		systematic_sample_start				= a.systematic_sample_start,
--		systematic_sample_oversample_rate	= a.systematic_sample_oversample_rate,
--		systematic_sample_rand				= a.systematic_sample_rand,
--		systematic_sample_draw_datetime		= a.systematic_sample_draw_datetime
--from	utb_hedis_systematic_sample a
--		inner join member b on
--			a.ihds_member_id = b.ihds_member_id
--order by systematic_order_row,
--		sample_row
----**********************************************************************************
----**********************************************************************************





--**********************************************************************************
--**********************************************************************************


--**********************************************************************************
--**********************************************************************************








--truncate table utb_hedis_all_sampleframe_archive

insert into utb_hedis_all_sampleframe_archive
--select * from utb_hedis_cdc_sampleframe_CHP union all --no
select * from utb_hedis_cdc_sampleframe_MCD union all
--select * from utb_hedis_awc_sampleframe_CHP union all
--select * from utb_hedis_awc_sampleframe_MCD union all
select * from utb_hedis_cis_sampleframe_CHP union all
select * from utb_hedis_cis_sampleframe_MCD union all
select * from utb_hedis_lsc_sampleframe_CHP union all
select * from utb_hedis_lsc_sampleframe_MCD union all
--select * from utb_hedis_cmc_sampleframe_CHP union all --no
--select * from utb_hedis_cmc_sampleframe_MCD union all
--select * from utb_hedis_w15_sampleframe_CHP union all
--select * from utb_hedis_w15_sampleframe_MCD union all
--select * from utb_hedis_w34_sampleframe_CHP union all
--select * from utb_hedis_w34_sampleframe_MCD union all
--select * from utb_hedis_cbp_sampleframe_CHP union all --no
select * from utb_hedis_cbp_sampleframe_MCD union all
--select * from utb_hedis_ccs_sampleframe_CHP union all --no
select * from utb_hedis_ccs_sampleframe_MCD union all
--select * from utb_hedis_apc_sampleframe_CHP union all
--select * from utb_hedis_apc_sampleframe_MCD union all
--select * from utb_hedis_ppc_sampleframe_CHP union all --no
select * from utb_hedis_ppc_sampleframe_MCD union all
select * from utb_hedis_fpc_sampleframe_MCD union all
select * from utb_hedis_aba_sampleframe_CHP union all
select * from utb_hedis_aba_sampleframe_MCD union all
select * from utb_hedis_wcc_sampleframe_CHP union all
select * from utb_hedis_wcc_sampleframe_MCD 



--select	hedis_measure_init,
--		product,
--		total_members	= count(*),
--		mrss_member		= sum(case when sample_indicator = 'sample' then 1 else 0 end),
--		fss_member		= sum(case when sample_indicator is not null then 1 else 0 end)
--from	utb_hedis_all_sampleframe_archive
----where	convert(varchar(8),systematic_sample_draw_datetime,112) = '20080208'
--group by hedis_measure_init,
--		product
--order by 1,2
--
--hedis_measure_init product total_members mrss_member fss_member
-------------------- ------- ------------- ----------- -----------
--ABA                MCD     6037          411         432
--CBP                MCD     2419          411         473
--CCS                MCD     9483          411         432
--CDC                MCD     1724          548         576
--CIS                CHP     214           214         214
--CIS                MCD     1954          411         432
--FPC                MCD     2560          411         432
--PPC                MCD     2560          411         432
--WCC                CHP     10525         411         432
--WCC                MCD     13773         411         432


GO

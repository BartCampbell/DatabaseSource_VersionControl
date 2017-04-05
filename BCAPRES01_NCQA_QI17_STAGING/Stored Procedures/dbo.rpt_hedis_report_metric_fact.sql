SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[rpt_hedis_report_metric_fact]
as




select	distinct 
		medical_group_name_qarr,
		e2.panel_code,
		pcp_id,
		HPN_address1,
		HPN_address2,
		HPN_telephone,
		HPN_fax,
		HPN_qarr_contact,
		HPN_qarr_email,
		last_name,
		first_name,
		subscriber_no,
		person_no,
		dob = convert(varchar(8),dob,112),
		gender_code,
		pcp_name1,
		f.hedis_measure_init,
		hedis_measure_desc,
		sample_type,
		sample_draw_order
		--,a.*
--select top 10 * select count(*), count(distinct subscriber_no+person_no )
from	dbo.hedis_report_metric_fact a
		inner join hedis_member_measure_sample_dim b on
			a.hedis_member_measure_sample_key = b.hedis_member_measure_sample_key 
		inner join hedis_medical_record_site_dim c on
			a.hedis_medical_record_site_key = c.hedis_medical_record_site_key 
		inner join member_dim d on
			a.member_key = d.member_key
		inner join pcp_dim e on
			a.pcp_key = e.pcp_key
		inner join panel_dim e2 on
			a.panel_key = e2.panel_key
		inner join hedis_measure_dim f on
			a.hedis_measure_key = f.hedis_measure_key
		inner join gender_dim g on
			a.gender_key = g.gender_key

where	hedis_eligible_value = 1 and
		exclusion_value = 0 and
		denominator_value = 1 and
		exists (	select	*
					from	dbo.hedis_member_measure_sample_dim b2
					where	a.hedis_member_measure_sample_key = b2.hedis_member_measure_sample_key and
							numerator_pursuit_status = 0 and
							(sample_type in ('sample','oversample') or hedis_measure_init='CDC') ) --and
--		exists (	select	*
--					from	dbo.hedis_measure_dim f2
--					where	a.hedis_measure_key = f2.hedis_measure_key and
--							hedis_measure_init = 'AWC') --and
--		exists (	select	*
--					from	dbo.hedis_medical_record_site_dim c2
--					where	a.hedis_medical_record_site_key = c2.hedis_medical_record_site_key and
--							medical_group_name_qarr = 'Access Medical Group')
order by 1,2,3,8,9







select	medical_group_name_qarr		= c.medical_group_name_qarr,
		HPN_address1				= c.HPN_address1,
		HPN_address2				= c.HPN_address2,
		HPN_telephone				= c.HPN_telephone,
		HPN_fax						= c.HPN_fax,
		HPN_qarr_contact			= c.HPN_qarr_contact,
		HPN_qarr_email				= c.HPN_qarr_email,
		last_name					= NameLast,
		first_name					= NameFirst,
		subscriber_no				= left(a.CustomerMemberID,7),
		person_no					= right(a.CustomerMemberID,2),
		dob							= convert(varchar(8),DateOfBirth,112),
		gender_code					= Gender,
		diamond_provid				= a.CustomerProviderID,
		diamond_provname			= PANAME1,
		hedis_measure_init			= 'PPC',
		hedis_measure_desc			= 'Prenatal and Postpartum Care',
		sample_type					= sample_type,
		sample_draw_order			= sample_draw_order
		--,a.*
--select top 10 *
--select count(*) --select a.customermemberid
from	hh08_ihds_ds01..utb_hedis_medical_record_pursuit a 
		inner join member b on
			a.customermemberid = b.customermemberid
		left join hedis_medical_record_site_dim c on
			a.CustomerProviderID = c.provider_id and
			primary_site_flag = 1 
		left join hh08_ihds_ds01..jprovfm0_dat d on
			a.CustomerProviderID = d.PAPROVID
		left join hedis_member_measure_sample_dim e on
			b.ihds_member_id = e.ihds_member_id
where	HEDISMeasureInitial = 'PPC' 
		and PrimaryPursuitFlag = 1 
		and numerator_pursuit_status = 0 
		and sample_type in ('sample','oversample')






/*
select	*
from	hh08_ihds_ds01..utb_hedis_cis a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
where	customermemberid in ('106995001','101802301','103062702')


select	*
from	hh08_ihds_ds01..utb_hedis_awc a
		inner join member b on
			a.ihds_member_id = b.ihds_member_id
--where	awc_denominator_flag = 1 and awc_exclusion_flag = 0 and awc_hedis_eligibility_flag = 1
where	customermemberid in ('100415903','108644203','100717602')

ihds_member_id service_char_full_date awc_inst    awc_denominator_flag awc_exclusion_flag awc_numerator_flag awc_hedis_eligibility_flag resp_seq_prov_id MemberID    Address1                                           Address2                                           City                           Client               CustomerMemberID     DataSource                                         DateOfBirth             Gender HedisMeasureID ihds_member_id NameFirst                      NameLast                       NameMiddleInitial NamePrefix NameSuffix RelationshipToSubscriber SSN       State SubscriberID ZipCode    Race Ethnicity MemberLanguage InterpreterFlag RowID       HashValue
-------------- ---------------------- ----------- -------------------- ------------------ ------------------ -------------------------- ---------------- ----------- -------------------------------------------------- -------------------------------------------------- ------------------------------ -------------------- -------------------- -------------------------------------------------- ----------------------- ------ -------------- -------------- ------------------------------ ------------------------------ ----------------- ---------- ---------- ------------------------ --------- ----- ------------ ---------- ---- --------- -------------- --------------- ----------- ----------------------------------
35874          20071201               0           1                    0                  0                  1                          NULL             7803        NULL                                               NULL                                               NULL                           HHP                  100415903            JMEMBRM0_DAT                                       1994-12-08 00:00:00.000 M      NULL           35874          Joseph                         Schroeder                      W                 NULL       NULL       NULL                     073843258 NULL  1004159      12791      NULL NULL      NULL           NULL            NULL        NULL
86880          20071201               0           1                    0                  0                  1                          NULL             15304       NULL                                               NULL                                               NULL                           HHP                  100717602            JMEMBRM0_DAT                                       1993-07-14 00:00:00.000 M      NULL           86880          Curtis                         Zayas                          J                 NULL       NULL       NULL                     081825864 NULL  1007176      12758      NULL NULL      NULL           NULL            NULL        NULL
9033           20071201               0           1                    0                  0                  1                          NULL             149596      NULL                                               NULL                                               NULL                           HHP                  108644203            JMEMBRM0_DAT                                       1992-03-30 00:00:00.000 F      NULL           9033           Deanna                         Yeneic                                           NULL       NULL       NULL                     092805227 NULL  1086442      12758      NULL NULL      NULL           NULL            NULL        NULL

exec hh08_ihds_ds01..rpt_member_detail '86880'

*/

GO

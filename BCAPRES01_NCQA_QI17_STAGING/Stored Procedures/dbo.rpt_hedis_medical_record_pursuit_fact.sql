SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[rpt_hedis_medical_record_pursuit_fact]
as




select	distinct 
		medical_group_name_qarr,
--		e2.panel_code,
--		pcp_id,
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
		hedis_measure_init,
		sample_type,
		sample_draw_order
		--,a.*
--select top 10 * 
--select count(*)
--select 40164-count(*)
from	dbo.hedis_medical_record_pursuit_fact a
		inner join hedis_member_measure_sample_dim b on
			a.hedis_member_measure_sample_key = b.hedis_member_measure_sample_key 
		inner join hedis_medical_record_site_dim c on
			a.hedis_medical_record_site_key = c.hedis_medical_record_site_key 
		inner join member_dim d on
			a.member_key = d.member_key
		inner join servicing_prov_dim e on
			a.provider_key = e.servicing_prov_key
		inner join hedis_medical_record_pursuit_hdr_dim f on
			a.hedis_medical_record_pursuit_hdr_key = f.hedis_medical_record_pursuit_hdr_key

where	exists (	select	*
					from	dbo.hedis_member_measure_sample_dim b2
					where	a.hedis_member_measure_sample_key = b2.hedis_member_measure_sample_key and
							numerator_pursuit_status = 0 and
							(sample_type in ('sample','oversample') or hedis_measure_init='CDC') ) and
		exists (	select	*
					from	dbo.hedis_medical_record_pursuit_hdr_dim f2
					where	a.hedis_medical_record_pursuit_hdr_key = f2.hedis_medical_record_pursuit_hdr_key and
							pursuit_source in ('Claims') and
							pursuit_type in ('Most Used Prenatal') ) --and
							--pursuit_type in ('Most Used OBGYN') ) --and
							--left(pursuit_type,16) in ('Visited Provider') ) --and




GO

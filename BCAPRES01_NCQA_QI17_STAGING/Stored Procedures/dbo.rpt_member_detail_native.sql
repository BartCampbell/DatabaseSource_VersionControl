SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[rpt_member_detail_native]
@ihds_member_id int
as

/*
This is a temporary sp to facilitate testing created by Randy Wilson
*/

-------------------------------------------------
--DECLARE @ihds_member_id int
--SET @ihds_member_id = '1224462'
-------------------------------------------------



print 'member_gm'
select	*
from	ncqa_qi10_rdsm..member_gm
where	ihds_member_id = @ihds_member_id


print 'member_en'
select	*
from	ncqa_qi10_rdsm..member_en
where	ihds_member_id = @ihds_member_id


print 'visit'
select	* --select top 10 *
from	ncqa_qi10_rdsm..visit
where	ihds_member_id = @ihds_member_id


print 'pharm'
select	* 
from	ncqa_qi10_rdsm..pharm
where	ihds_member_id = @ihds_member_id


print 'lab'
select	*  --select top 10 *
from	ncqa_qi10_rdsm..lab
where	ihds_member_id = @ihds_member_id

GO

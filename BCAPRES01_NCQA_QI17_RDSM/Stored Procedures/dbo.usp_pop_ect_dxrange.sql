SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE    PROC [dbo].[usp_pop_ect_dxrange]
/*
exec usp_pop_ect_dxrange '630', '630', 'ABA-C'
*/
	@lowcode	varchar(3),
	@highcode	varchar(3),
	@tableid	varchar(10)

AS

--*******************************
--declare @lowcode	varchar(10),
--		@highcode	varchar(10),
--		@tableid	varchar(10)
--set		@lowcode	= '630'
--set		@highcode	= '630'
--set		@tableid	= 'ABA-C'
--*******************************

--select * from #temp_codeset
--select * from #new_codes

declare @prefix_p1	varchar(10),
		@prefix_p2	varchar(10),
		@prefix		varchar(10),
		@suffix		varchar(10),
		@loop_len	int,
		@icntr		int


IF OBJECT_ID('tempdb..#temp_codeset') is not null
    DROP TABLE #temp_codeset

create table #temp_codeset
(	codeid	varchar(10) )

--*********************************************************************
set		@prefix		= ''
set		@suffix		= ''
set		@loop_len	= 3

set		@icntr = convert(int,@lowcode)

while	@icntr <= convert(int,@highcode)
begin

insert into #temp_codeset
select	@prefix+
		REPLICATE('0',@loop_len-len(convert(varchar(8),@icntr)))+
		convert(varchar(8),@icntr)+
		@suffix

set		@icntr = @icntr + 1
end
--*********************************************************************




--*********************************************************************
declare @lowsuffix	varchar(10),
		@highsuffix	varchar(10)

set		@prefix_p1	= @lowcode

while @prefix_p1 <= @highcode
begin

	set		@prefix_p2	= '.'
	set		@prefix		= @prefix_p1+@prefix_p2
	set		@suffix		= ''
	set		@loop_len	= 1
	set		@lowsuffix	= '0'
	set		@highsuffix	= '9'

	set		@icntr = convert(int,@lowsuffix)

		while	@icntr <= convert(int,@highsuffix)
		begin
		
			insert into #temp_codeset
			select	@prefix+
					REPLICATE('0',@loop_len-len(convert(varchar(8),@icntr)))+
					convert(varchar(8),@icntr)+
					@suffix

			set		@icntr = @icntr + 1
		
		end

	set		@prefix_p1	= convert(varchar(3),convert(int,@prefix_p1)+1)
	set		@prefix_p1	= REPLICATE('0',3-len(convert(varchar(8),@prefix_p1)))+@prefix_p1

end
--*********************************************************************





--*********************************************************************
set		@prefix_p1	= @lowcode

while @prefix_p1 <= @highcode
begin

	set		@prefix_p2	= '.'
	set		@prefix		= @prefix_p1+@prefix_p2
	set		@suffix		= ''
	set		@loop_len	= 2
	set		@lowsuffix	= '00'
	set		@highsuffix	= '99'

	set		@icntr = convert(int,@lowsuffix)

		while	@icntr <= convert(int,@highsuffix)
		begin
		
			insert into #temp_codeset
			select	@prefix+
					REPLICATE('0',@loop_len-len(convert(varchar(8),@icntr)))+
					convert(varchar(8),@icntr)+
					@suffix

			set		@icntr = @icntr + 1
		
		end

	set		@prefix_p1	= convert(varchar(3),convert(int,@prefix_p1)+1)
	set		@prefix_p1	= REPLICATE('0',3-len(convert(varchar(8),@prefix_p1)))+@prefix_p1

end
--*********************************************************************



declare @modelCodeValue		varchar(10)
declare @modeldescription	varchar(50)

set	@modelCodeValue		= (	select	top 1 CodeValue --select *
							from	ncqa_rdsm..tblCodeSets_2009
							WHERE	tableid = @tableid
									AND left(CodeValue,3) = left(@lowcode,3)
									AND codetype in('ICD-9-CM_Diagnosis') 
							order by CodeValue,
									description)

set	@modeldescription	= (	select	top 1 Description --select *
							from	ncqa_rdsm..tblCodeSets_2009
							WHERE	tableid = @tableid
									AND left(CodeValue,3) = left(@lowcode,3)
									AND codetype in('ICD-9-CM_Diagnosis')
							order by CodeValue,
									description)





IF OBJECT_ID('tempdb..#new_codes') is not null
    DROP TABLE #new_codes

select	*
into	#new_codes
from	#temp_codeset
where	codeid not in (		select	CodeValue --select *
							from	ncqa_rdsm..tblCodeSets_2009
							WHERE	tableid = @tableid
									AND ISNULL(Description,'') = ISNULL(@modeldescription,'')
									AND codetype in('ICD-9-CM_Diagnosis') )


if	(	select	count(*)
		from	ncqa_rdsm..tblCodeSets_2009 a
		where	tableid = @tableid
				and CodeValue = @modelCodeValue
				AND ISNULL(Description,'') = ISNULL(@modeldescription,'')
				AND codetype in('ICD-9-CM_Diagnosis') ) = 1
begin

	insert into ncqa_rdsm..tblCodeSets_2009
	select	TableId				= TableId,
			Description			= Description,
			CodeType			= CodeType,
			CodeValue			= codeid --select *
	from	ncqa_rdsm..tblCodeSets_2009 a
			cross join #new_codes b
	where	tableid = @tableid
			and CodeValue = @modelCodeValue
			AND ISNULL(Description,'') = ISNULL(@modeldescription,'')
			AND codetype in('ICD-9-CM_Diagnosis')


	print 'Codes in selected range:'
	select count(*) from #temp_codeset
	print ''
	print 'Missing codes loaded:'
	select count(*) from #new_codes


end






GO

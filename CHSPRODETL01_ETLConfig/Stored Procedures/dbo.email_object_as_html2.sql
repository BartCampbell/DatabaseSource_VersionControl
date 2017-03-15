SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[email_object_as_html2]
    @source_db    sysname,       --  Where the @object_name is resident
    @schema       sysname,   --  Schema name eg.. dbo.
    @object_name  sysname,  
	@object_name2  sysname = '',      --  Table or view to email
	@object_name3 sysname,
	@object_name4 sysname,
    @order_clause nvarchar(max), --  The order by clause eg. x, y, z
	@email        nvarchar(max),  --  Email recipient list
	@subject nvarchar(max), 
	@Body_FirstLine NVARCHAR(MAX),
	@Body_SecondLine NVARCHAR(MAX),
	@Body_ThirdLine NVARCHAR(MAX),
	@Body_FourthLine NVARCHAR(MAX)
as
begin

    declare --@subject nvarchar(max),
               @body1    nvarchar(max),
			   @body2    nvarchar(max),
			   @body3    nvarchar(max),
			   @body4    nvarchar(max),
			    @FullBody NVARCHAR(max) 
 
    --  Get columns for table headers..
    exec( '
    declare col_cur cursor for
        select name
        from ' + @source_db + '.sys.columns
        where object_id = object_id( ''' + @source_db + '.' + @schema + '.' + @object_name + ''')
        order by column_id
        ' )
 
    open col_cur
 
    declare @col_name sysname
    declare @col_list nvarchar(max)
 
    fetch next from col_cur into @col_name
 
    set @body1 = N'<table border=1 cellpadding=1 cellspacing=1><tr>'
 
    while @@fetch_status = 0
    begin
        set @body1 = cast( @body1 as nvarchar(max) )
                  + N'<th>' + @col_name + '</th>'
 
        set @col_list = coalesce( @col_list + ',', '' ) + ' td = ' + cast( @col_name as nvarchar(max) ) + ', '''''
 
        fetch next from col_cur into @col_name
 
    end
 
    deallocate col_cur
 
    set @body1 = cast( @body1 as nvarchar(max) )
              + '</tr>'
 
    declare @query_result nvarchar(max)
    declare @nsql nvarchar(max)
 
    --  Form the query, use XML PATH to get the HTML
    set @nsql = '
        select @qr =
               cast( ( select ' + cast( @col_list as nvarchar(max) )+ '
                       from ' + @source_db + '.' + @schema + '.' + @object_name + '
                   	   order by ' + @order_clause + '
                       for xml path( ''tr'' ), type
                       ) as nvarchar(max) )'
 
    exec sp_executesql @nsql, N'@qr nvarchar(max) output', @query_result output
 
    set @body1 = cast( @body1 as nvarchar(max) )
              + @query_result
 
    --  Send notification
    --set @subject = 'Wellcare Fax Receipt Report: '+ CONVERT(varchar(8), GETDATE(), 112)
 
    set @body1 = @body1 + cast( '</table><br>' as nvarchar(max) )
 
    set @body1 = '<p>'+@Body_FirstLine+' </p>'
              + cast( @body1 as nvarchar(max) )

	DECLARE @FirstTableBody NVARCHAR(max) = @body1




IF (@object_name2 <> '')
Begin
   --  Get columns for table headers..

    exec( '
    declare col_cur2 cursor for
        select name
        from ' + @source_db + '.sys.columns
        where object_id = object_id( ''' + @source_db + '.' + @schema + '.' + @object_name2 + ''')
        order by column_id
        ' )
 
    open col_cur2
 
   declare @col_name2 sysname
   declare @col_list2 nvarchar(max)
 
    fetch next from col_cur2 into @col_name2
		
    set @body2 = N'<table border=1 cellpadding=1 cellspacing=1><tr>'
 
    while @@fetch_status = 0
    begin
        set @body2 = cast( @body2 as nvarchar(max) )
                  + N'<th>' + @col_name2 + '</th>'
 
        set @col_list2 = coalesce( @col_list2 + ',', '' ) + ' td = ' + cast( @col_name2 as nvarchar(max) ) + ', '''''
 
        fetch next from col_cur2 into @col_name2
 
    end
 
    deallocate col_cur2
 
    set @body2 = cast( @body2 as nvarchar(max) )
              + '</tr>'
 
    declare @query_result2 nvarchar(max)
    declare @nsql2 nvarchar(max)
 
    --  Form the query, use XML PATH to get the HTML
    set @nsql2 = '
        select @qr =
               cast( ( select ' + cast( @col_list2 as nvarchar(max) )+ '
                       from ' + @source_db + '.' + @schema + '.' + @object_name2 + '
                   	   order by ' + @order_clause + '
                       for xml path( ''tr'' ), type
                       ) as nvarchar(max) )'
 
    exec sp_executesql @nsql2, N'@qr nvarchar(max) output', @query_result2 output
 
    set @body2 = cast( @body2 as nvarchar(max) )
              + @query_result2
 
    --  Send notification
    --set @subject = 'Wellcare Fax Receipt Report: '+ CONVERT(varchar(8), GETDATE(), 112)
 
    set @body2 = @body2 + cast( '</table><br>' as nvarchar(max) )
 
    set @body2 = '<p>'+@Body_SecondLine+' </p>'
              + cast( @body2 as nvarchar(max) )

 
		
END



IF (@object_name3 <> '')
Begin
   --  Get columns for table headers..

    exec( '
    declare col_cur3 cursor for
        select name
        from ' + @source_db + '.sys.columns
        where object_id = object_id( ''' + @source_db + '.' + @schema + '.' + @object_name3 + ''')
        order by column_id
        ' )
 
    open col_cur3
 
   declare @col_name3 sysname
   declare @col_list3 nvarchar(max)
 
    fetch next from col_cur3 into @col_name3
		
    set @body3 = N'<table border=1 cellpadding=1 cellspacing=1><tr>'
 
    while @@fetch_status = 0
    begin
        set @body3 = cast( @body3 as nvarchar(max) )
                  + N'<th>' + @col_name3 + '</th>'
 
        set @col_list3 = coalesce( @col_list3 + ',', '' ) + ' td = ' + cast( @col_name3 as nvarchar(max) ) + ', '''''
 
        fetch next from col_cur3 into @col_name3
 
    end
 
    deallocate col_cur3
 
    set @body3 = cast( @body3 as nvarchar(max) )
              + '</tr>'
 
    declare @query_result3 nvarchar(max)
    declare @nsql3 nvarchar(max)
 
    --  Form the query, use XML PATH to get the HTML
    set @nsql3 = '
        select @qr =
               cast( ( select ' + cast( @col_list3 as nvarchar(max) )+ '
                       from ' + @source_db + '.' + @schema + '.' + @object_name3 + '
                   	   order by ' + @order_clause + '
                       for xml path( ''tr'' ), type
                       ) as nvarchar(max) )'
 
    exec sp_executesql @nsql3, N'@qr nvarchar(max) output', @query_result3 output
 
    set @body3 = cast( @body3 as nvarchar(max) )
              + @query_result3
 
    --  Send notification
    --set @subject = 'Wellcare Fax Receipt Report: '+ CONVERT(varchar(8), GETDATE(), 112)
 
    set @body3 = @body3 + cast( '</table><br>' as nvarchar(max) )
 
    set @body3 = '<p>'+@Body_ThirdLine+' </p>'
              + cast( @body3 as nvarchar(max) )

 
		
END




IF (@object_name4 <> '')
Begin
   --  Get columns for table headers..

    exec( '
    declare col_cur4 cursor for
        select name
        from ' + @source_db + '.sys.columns
        where object_id = object_id( ''' + @source_db + '.' + @schema + '.' + @object_name4 + ''')
        order by column_id
        ' )
 
    open col_cur4
 
   declare @col_name4 sysname
   declare @col_list4 nvarchar(max)
 
    fetch next from col_cur4 into @col_name4
		
    set @body4 = N'<table border=1 cellpadding=1 cellspacing=1><tr>'
 
    while @@fetch_status = 0
    begin
        set @body4 = cast( @body4 as nvarchar(max) )
                  + N'<th>' + @col_name4 + '</th>'
 
        set @col_list4 = coalesce( @col_list4 + ',', '' ) + ' td = ' + cast( @col_name4 as nvarchar(max) ) + ', '''''
 
        fetch next from col_cur4 into @col_name4
 
    end
 
    deallocate col_cur4
 
    set @body4 = cast( @body4 as nvarchar(max) )
              + '</tr>'
 
    declare @query_result4 nvarchar(max)
    declare @nsql4 nvarchar(max)
 
    --  Form the query, use XML PATH to get the HTML
    set @nsql4 = '
        select @qr =
               cast( ( select ' + cast( @col_list4 as nvarchar(max) )+ '
                       from ' + @source_db + '.' + @schema + '.' + @object_name4 + '
                   	   order by ' + @order_clause + '
                       for xml path( ''tr'' ), type
                       ) as nvarchar(max) )'
 
    exec sp_executesql @nsql4, N'@qr nvarchar(max) output', @query_result4 output
 
    set @body4 = cast( @body4 as nvarchar(max) )
              + @query_result4
 
    --  Send notification
    --set @subject = 'Wellcare Fax Receipt Report: '+ CONVERT(varchar(8), GETDATE(), 112)
 
    set @body4 = @body4 + cast( '</table><br>' as nvarchar(max) )
 
    set @body4 = '<p>'+@Body_FourthLine+' </p>'
              + cast( @body4 as nvarchar(max) )

 
		
END



SET @FullBody = @body1+'<br>'+ @body2 +'<br>'+  @body3 +'<br>'+@body4 + '<br><br>* This includes all files received through sFax, Provider Portal, FTP, mail and from copy centers submitting charts via ftp. It currently does not include the Chart Scanner or Print Utility files.'

    EXEC msdb.dbo.sp_send_dbmail  @profile_name = 'Notify',
                                  @recipients = @email,
                                  @body = @FullBody,
                                  @body_format = 'HTML',
                                  @subject = @subject
 
end
GO

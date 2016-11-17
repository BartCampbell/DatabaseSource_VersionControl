SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create FUNCTION [dbo].[ufsReadfileAsString]
(
@Path VARCHAR(255),
@Filename VARCHAR(100)
)
RETURNS 
 Varchar(max)
AS
BEGIN

DECLARE  @objFileSystem int
        ,@objTextStream int,
		@objErrorObject int,
		@strErrorMessage Varchar(1000),
	    @Command varchar(1000),
		@Chunk Varchar(8000),
		@String varchar(max),
	    @hr int,
		@YesOrNo int

Select @String=''
select @strErrorMessage='opening the File System Object'
EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT


if @HR=0 Select @objErrorObject=@objFileSystem, @strErrorMessage='Opening file "'+@path+'\'+@filename+'"',@command=@path+'\'+@filename

if @HR=0 execute @hr = sp_OAMethod   @objFileSystem  , 'OpenTextFile'
	, @objTextStream OUT, @command,1,false,0--for reading, FormatASCII

WHILE @hr=0
	BEGIN
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage='finding out if there is more to read in "'+@filename+'"'
	if @HR=0 execute @hr = sp_OAGetProperty @objTextStream, 'AtEndOfStream', @YesOrNo OUTPUT

	IF @YesOrNo<>0  break
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage='reading from the output file "'+@filename+'"'
	if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Read', @chunk OUTPUT,4000
	SELECT @String=@string+@chunk
	end
if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage='closing the output file "'+@filename+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Close'


if @hr<>0
	begin
	Declare 
		@Source varchar(255),
		@Description Varchar(255),
		@Helpfile Varchar(255),
		@HelpID int
	
	EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
		@source output,@Description output,@Helpfile output,@HelpID output
	Select @strErrorMessage='Error whilst '
			+coalesce(@strErrorMessage,'doing something')
			+', '+coalesce(@Description,'')
	select @String=@strErrorMessage
	end
EXECUTE  sp_OADestroy @objTextStream
	-- Fill the table variable with the rows for your result set
	
	RETURN @string
END
GO

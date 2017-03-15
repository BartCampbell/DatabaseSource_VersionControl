SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[SplitSegment]
(
	@delimiter varchar(1),
	@segment nvarchar(max)
)
RETURNS 
@elements TABLE (Ref tinyint, Element varchar(max))
AS
BEGIN
    declare @reference int
    declare @frontIndex int
    declare @backIndex int

    set @reference = 1
    set @frontIndex = charindex(@delimiter, @segment, 1)
    set @backIndex = charindex(@delimiter, @segment, @frontIndex + 1)

    while (@backIndex > @frontIndex)
    begin
        insert into @elements values (@reference, substring(@segment, @frontIndex + 1, @backIndex - @frontIndex - 1))

        set @frontIndex = @backIndex
        set @backIndex = charindex(@delimiter, @segment, @frontIndex + 1)
        set @reference = @reference + 1
    end
    
    insert into @elements values (@reference, substring (@segment, @frontIndex + 1,len(@segment)-@frontIndex))

	RETURN 
END
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*


	select * from [dbo].[fnSplit]('Here,There,Everywhere',',')

*/
CREATE  FUNCTION [dbo].[fnSplit]
(
    @RowData NVARCHAR(MAX) ,
    @SplitOn NVARCHAR(5)
)
RETURNS @ReturnValue TABLE ( Name NVARCHAR(MAX) )
AS 
    BEGIN
        DECLARE @Counter INT
        SET @Counter = 1 
        WHILE ( CHARINDEX(@SplitOn, @RowData) > 0 ) 
            BEGIN  
                INSERT  INTO @ReturnValue
                        ( Name
                        )
                        SELECT  Data = LTRIM(RTRIM(SUBSTRING(@RowData, 1,
                                                             CHARINDEX(@SplitOn,
                                                              @RowData) - 1)))
                SET @RowData = SUBSTRING(@RowData,
                                         CHARINDEX(@SplitOn, @RowData) + 1,
                                         LEN(@RowData)) 
                SET @Counter = @Counter + 1  
            END 
        INSERT  INTO @ReturnValue
                ( Name )
                SELECT  Data = LTRIM(RTRIM(@RowData))  
        RETURN  
    END;
GO

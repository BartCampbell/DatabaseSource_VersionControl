SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[usp_generateIdentifier]
    @minLen int = 1
    , @maxLen int = 1
    , @seed int output
    , @string varchar(8000) output
as
begin
    set nocount on;
    declare @length int;
    declare @alpha varchar(8000)
        , @digit varchar(8000)
        , @specials varchar(8000)
        , @first varchar(8000)
    declare @step bigint = rand(@seed) * 2147483647;

    select @alpha = 'qwertyuiopasdfghjklzxcvbnm'
   
    select @first = @alpha;

    set  @seed = (rand((@seed+@step)%2147483647)*2147483647);

    select @length = @minLen + rand(@seed) * (@maxLen-@minLen)
        , @seed = (rand((@seed+@step)%2147483647)*2147483647);

    declare @dice int;
    select @dice = rand(@seed) * len(@first),
        @seed = (rand((@seed+@step)%2147483647)*2147483647);
    select @string = substring(@first, @dice, 1);

    while 0 < @length 
    begin
        select @dice = rand(@seed) * 100
            , @seed = (rand((@seed+@step)%2147483647)*2147483647);
        begin
            declare @preseed int = @seed;
            select @dice = rand(@seed) * len(@alpha)+1
                , @seed = (rand((@seed+@step)%2147483647)*2147483647);

            select @string = @string + substring(@alpha, @dice, 1);
       end

        select @length = @length - 1;   
   end
end
GO

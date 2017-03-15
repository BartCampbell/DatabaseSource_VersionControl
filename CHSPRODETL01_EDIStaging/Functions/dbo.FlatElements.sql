SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[FlatElements]
(	
	@delimiter varchar(1),
	@segment nvarchar(max)
)
RETURNS TABLE 
AS
RETURN 
(
	with elements as (
select Ref, Element 
from [dbo].SplitSegment(@delimiter,@segment)
)
select 
  [01] = (select Element from elements where Ref = 1),
  [02] = (select Element from elements where Ref = 2),
  [03] = (select Element from elements where Ref = 3),
  [04] = (select Element from elements where Ref = 4),
  [05] = (select Element from elements where Ref = 5),
  [06] = (select Element from elements where Ref = 6),
  [07] = (select Element from elements where Ref = 7),
  [08] = (select Element from elements where Ref = 8),
  [09] = (select Element from elements where Ref = 9),
  [10] = (select Element from elements where Ref = 10),
  [11] = (select Element from elements where Ref = 11),
  [12] = (select Element from elements where Ref = 12),
  [13] = (select Element from elements where Ref = 13),
  [14] = (select Element from elements where Ref = 14),
  [15] = (select Element from elements where Ref = 15),
  [16] = (select Element from elements where Ref = 16),
  [17] = (select Element from elements where Ref = 17),
  [18] = (select Element from elements where Ref = 18),
  [19] = (select Element from elements where Ref = 19),
  [20] = (select Element from elements where Ref = 20),
  [21] = (select Element from elements where Ref = 21),
  [22] = (select Element from elements where Ref = 22),
  [23] = (select Element from elements where Ref = 23),
  [24] = (select Element from elements where Ref = 24),
  [25] = (select Element from elements where Ref = 25),
  [26] = (select Element from elements where Ref = 26),
  [27] = (select Element from elements where Ref = 27),
  [28] = (select Element from elements where Ref = 28),
  [29] = (select Element from elements where Ref = 29),
  [30] = (select Element from elements where Ref = 30),
  [31] = (select Element from elements where Ref = 31),
  [32] = (select Element from elements where Ref = 32),
  [33] = (select Element from elements where Ref = 33),
  [34] = (select Element from elements where Ref = 34)
)
GO

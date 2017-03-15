SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevBHT]
AS
select *
from [dbo].[BHT] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[BHT] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO

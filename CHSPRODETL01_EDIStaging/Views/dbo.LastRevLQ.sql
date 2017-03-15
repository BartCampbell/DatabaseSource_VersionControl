SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevLQ]
AS
select *
from [dbo].[LQ] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[LQ] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO

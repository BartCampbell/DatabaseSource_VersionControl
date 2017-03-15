SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevLIN]
AS
select *
from [dbo].[LIN] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[LIN] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO

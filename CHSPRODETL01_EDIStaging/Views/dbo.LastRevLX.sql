SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevLX]
AS
select *
from [dbo].[LX] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[LX] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO

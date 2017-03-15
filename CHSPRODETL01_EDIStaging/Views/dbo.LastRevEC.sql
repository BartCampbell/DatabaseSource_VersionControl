SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevEC]
AS
select *
from [dbo].[EC] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[EC] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO

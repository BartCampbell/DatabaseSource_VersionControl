SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevRAS]
AS
select *
from [dbo].[RAS] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[RAS] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO

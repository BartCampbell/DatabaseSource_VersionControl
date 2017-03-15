SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevOI]
AS
select *
from [dbo].[OI] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[OI] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevMEA]
AS
select *
from [dbo].[MEA] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[MEA] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO

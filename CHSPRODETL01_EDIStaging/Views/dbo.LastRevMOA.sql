SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevMOA]
AS
select *
from [dbo].[MOA] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[MOA] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevN3]
AS
select *
from [dbo].[N3] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[N3] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO

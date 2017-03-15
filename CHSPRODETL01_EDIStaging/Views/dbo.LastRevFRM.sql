SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevFRM]
AS
select *
from [dbo].[FRM] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[FRM] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO

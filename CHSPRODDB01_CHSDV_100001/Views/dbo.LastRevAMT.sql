SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevAMT]
AS
select *
from [dbo].[AMT] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[AMT] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevCOB]
AS
select *
from [dbo].[COB] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[COB] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO

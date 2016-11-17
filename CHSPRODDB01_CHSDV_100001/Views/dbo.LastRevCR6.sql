SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevCR6]
AS
select *
from [dbo].[CR6] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[CR6] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO

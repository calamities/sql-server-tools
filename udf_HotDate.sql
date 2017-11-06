
-- =============================================
-- Author: Cal Walsman
-- Create date: 2017-10-30
-- Description:
-- Creates a user defined table value function
-- that outputs a calendar table based on a
-- start and end date.
-- =============================================

CREATE FUNCTION dbo.udf_HotDate (@datestart datetime2, @dateend datetime2)
RETURNS @calendar TABLE (
  [day] int,
  [date] datetime2,
  [weekday] varchar(50),
  [month] varchar(50),
  [ismonth] varchar(50)
)
AS

BEGIN

  DECLARE @rows int
  DECLARE @i int = 1

  SELECT
    @rows = DATEDIFF(DAY, @datestart, @dateend)

  WHILE (@i <= @rows)
  BEGIN

    INSERT INTO @calendar ([day])
      VALUES (@i)

    SET @i = @i + 1

  END

 UPDATE a
  SET [date] = DATEADD(DAY, [day] - 1, @datestart), weekday=datepart(dw,DATEADD(day,day-1,@datestart)), month = datepart(mm,DATEADD(day,day-1,@datestart)), ismonth = case when datepart(d,DATEADD(day,day-1,@datestart)) =1 then 1 else 0 end
  --select *, DATEADD(day,day-1,@datestart), datepart(dw,DATEADD(day,day-1,@datestart)), case when datepart(d,DATEADD(day,day-1,@datestart)) =1 then datepart(mm,DATEADD(day,day-1,@datestart)) else 0 end
  FROM @calendar a

  RETURN
END

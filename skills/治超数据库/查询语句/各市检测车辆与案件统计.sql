-- =============================================
-- 各市检测车辆和案件数统计
-- 时间范围：2021年11月 - 2026年5月
-- =============================================
WITH 检测车辆 AS (
    -- 从首检视图 + 预检表获取检测车辆数据
    SELECT
        bs.fCityID,
        c.fName AS 城市名称,
        COUNT(*) AS 检测车辆数
    FROM (
        SELECT fCheckStation
        FROM vw_ZC_CheckData_FirstAll
        WHERE fTime >= '2021-11-01' AND fTime < '2026-06-01'
          AND fState NOT IN (-1, 4, 5, 6, 14, 24, 25, 98, 99)
        UNION ALL
        SELECT fCheckStation
        FROM CP.ERoad_ZC_BD.dbo.ZC_CheckData_Preview
        WHERE fTime >= '2021-11-01' AND fTime < '2026-06-01'
          AND fState NOT IN (-1, 4, 5, 6, 14, 24, 25, 98, 99)
    ) t
    INNER JOIN dbo.Base_Station bs ON bs.fNO = t.fCheckStation
    INNER JOIN dbo.Base_City c ON bs.fCityID = c.fID
    WHERE bs.fType = 0          -- 仅治超站
      AND bs.fNoUsed = 0        -- 未停用
    GROUP BY bs.fCityID, c.fName
),
案件 AS (
    -- 从案件表获取案件数据
    SELECT
        bs.fCityID,
        c.fName AS 城市名称,
        COUNT(*) AS 案件数
    FROM dbo.ZC_CheckData_Other o
    INNER JOIN dbo.Base_Station bs ON bs.fNO = o.fStationNO
    INNER JOIN dbo.Base_City c ON bs.fCityID = c.fID
    WHERE o.fTime >= '2021-11-01' AND o.fTime < '2026-06-01'
      AND o.fState IN (0, 2, 3)   -- 0:编辑 2:待归档 3:完结
      AND bs.fType = 0
      AND bs.fNoUsed = 0
    GROUP BY bs.fCityID, c.fName
)
SELECT
    COALESCE(v.城市名称, c.城市名称) AS 城市名称,
    ISNULL(v.检测车辆数, 0) AS 检测车辆数,
    ISNULL(c.案件数, 0) AS 案件数
FROM 检测车辆 v
FULL JOIN 案件 c ON v.fCityID = c.fCityID
ORDER BY 检测车辆数 DESC;

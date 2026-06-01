-- =============================================
-- 抄告率统计 — 按月分类（2025年）
-- 应抄告和已抄告都按检测时间(f.fTime)分组
-- 这样每月看的是：当月检测的案件，有多少已被抄告
-- =============================================
WITH 每月案件 AS (
    SELECT
        o.fID,
        YEAR(f.fTime) AS 年份,
        MONTH(f.fTime) AS 月份
    FROM ZC_CheckData_Other o WITH (NOLOCK)
    INNER JOIN ZC_CheckData_First f WITH (NOLOCK) ON o.fMainID = f.fID
    INNER JOIN Base_Province p WITH (NOLOCK)
        ON LEFT(f.fboardtrucknew, 1) = p.fName
        AND LEFT(f.fboardtrucknew, 1) <> '冀'
    INNER JOIN Base_Station s WITH (NOLOCK)
        ON o.fStationNO = s.fNO
        AND ISNULL(s.fJJDepartment, '') <> ''
    WHERE o.fState = 3
      AND ISNULL(o.fIsUploadJTB, 0) = 1
      AND f.fTime >= '2025-01-01' AND f.fTime < '2026-01-01'
),
应抄告 AS (
    SELECT 年份, 月份, COUNT(*) AS 应抄告总数
    FROM 每月案件
    GROUP BY 年份, 月份
),
已抄告 AS (
    SELECT
        YEAR(f.fTime) AS 年份,
        MONTH(f.fTime) AS 月份,
        COUNT(DISTINCT u.fOtherID) AS 实际已抄告数
    FROM dbo.ZC_CheckData_UpLoadJTBI u WITH (NOLOCK)
    INNER JOIN ZC_CheckData_Other o WITH (NOLOCK) ON u.fOtherID = o.fID
    INNER JOIN ZC_CheckData_First f WITH (NOLOCK) ON o.fMainID = f.fID
    WHERE ((u.fMessage LIKE '%同一案件只可抄告同一类型同一对象一次%' AND u.fState = -1)
        OR u.fState = 1)
      AND f.fTime >= '2025-01-01' AND f.fTime < '2026-01-01'
    GROUP BY YEAR(f.fTime), MONTH(f.fTime)
)
SELECT
    a.年份,
    a.月份,
    a.应抄告总数,
    ISNULL(b.实际已抄告数, 0) AS 实际已抄告数,
    CASE
        WHEN a.应抄告总数 > 0
        THEN CAST(ISNULL(b.实际已抄告数, 0) * 100.0 / a.应抄告总数 AS DECIMAL(5, 2))
        ELSE 0
    END AS 抄告率_pct,
    a.应抄告总数 - ISNULL(b.实际已抄告数, 0) AS 未抄告数
FROM 应抄告 a
LEFT JOIN 已抄告 b ON a.年份 = b.年份 AND a.月份 = b.月份
ORDER BY a.年份, a.月份;

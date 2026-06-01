-- =============================================
-- 抄告率统计 — 按案件ID精确匹配（2025年）
-- 应抄告和已抄告通过 fOtherID ↔ o.fID 一对一核对
-- 两边都保证是外省车辆
-- =============================================
WITH 应抄告案件 AS (
    SELECT
        o.fID AS 案件ID,
        f.fboardtrucknew AS 车牌号,
        f.fTime AS 检测时间,
        s.fName AS 检测站,
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
已抄告记录 AS (
    SELECT DISTINCT u.fOtherID
    FROM dbo.ZC_CheckData_UpLoadJTBI u WITH (NOLOCK)
    WHERE ((u.fMessage LIKE '%同一案件只可抄告同一类型同一对象一次%' AND u.fState = -1)
        OR u.fState = 1)
)
-- 明细表：每条应抄告案件是否已抄告
SELECT
    a.案件ID,
    a.车牌号,
    a.检测时间,
    a.检测站,
    a.年份,
    a.月份,
    CASE WHEN b.fOtherID IS NOT NULL THEN '已抄告' ELSE '未抄告' END AS 抄告状态
FROM 应抄告案件 a
LEFT JOIN 已抄告记录 b ON a.案件ID = b.fOtherID
ORDER BY a.检测时间 DESC;

-- 汇总表：按月统计（精确匹配）
-- 取消注释即可运行
/*
SELECT
    a.年份,
    a.月份,
    COUNT(*) AS 应抄告总数,
    COUNT(CASE WHEN b.fOtherID IS NOT NULL THEN 1 END) AS 实际已抄告数,
    CAST(COUNT(CASE WHEN b.fOtherID IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS 抄告率_pct,
    COUNT(*) - COUNT(CASE WHEN b.fOtherID IS NOT NULL THEN 1 END) AS 未抄告数
FROM 应抄告案件 a
LEFT JOIN 已抄告记录 b ON a.案件ID = b.fOtherID
GROUP BY a.年份, a.月份
ORDER BY a.年份, a.月份;
*/

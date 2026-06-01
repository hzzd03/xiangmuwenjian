-- =============================================
-- 复检表(ZC_CheckData_Second) → 初检表(ZC_CheckData_First) 数据转移
-- 提供两种方式，根据实际需求选择
-- =============================================

-- =============================================
-- 方式一：INSERT — 把复检记录作为新的初检记录插入
-- 场景：复检表里有些数据本身就是初检数据，误存到复检表了
-- =============================================
/*
INSERT INTO dbo.ZC_CheckData_First (
    fID,                -- 新ID
    fNO,                -- 检测单编号
    fBoardTruck,        -- 货车牌号
    fWeightCheck,       -- 车货总重
    fWeightTruck,       -- 车货限重
    fWeightOverLoad,    -- 超限量
    fWeightOverLoadRate,-- 超限率
    fVehicleAxle,       -- 轴数
    fVehicleAxleType,   -- 轴型
    fOperator,          -- 操作员
    fTime,              -- 检测时间
    fCheckStation,      -- 检测站编号
    fCheckPlace,        -- 检测地点
    fIsUpServer,        -- 是否已上传
    fRemark,            -- 备注
    fTrailerNO,         -- 挂车牌号
    fIsLink,            -- 是否已关联
    fState,             -- 状态
    fDesc,              -- 说明
    fManagementAgency,  -- 管理机构
    fboardtrucknew,     -- 修改后车牌号 ← Second 的 fBoardTruckNew
    fVehicleAxleNew,    -- 修改后轴数
    fStandardWeightID,
    fGoodName,
    fJTBNO,
    fJTBIndex,
    fLaneNumber,
    fEquipCode,
    fEquipCodeStr,
    fIsUploadJTB,
    fLength,
    fWidth,
    fHeight,
    fDirection,
    fWay,
    fCreateTime         -- 创建时间
)
SELECT
    NEWID(),                    -- 生成新 GUID
    s.fNO,
    s.fBoardTruck,
    s.fWeightCheck,
    s.fWeightTruck,
    s.fWeightOverLoad,
    s.fWeightOverLoadRate,
    s.fVehicleAxle,
    s.fVehicleAxleType,
    s.fOperator,
    s.fTime,
    s.fCheckStation,
    s.fCheckPlace,
    s.fIsUpServer,
    s.fRemark,
    s.fTrailerNO,
    s.fIsLink,
    s.fState,
    s.fDesc,
    s.fManagementAgency,
    s.fBoardTruckNew,           -- → fboardtrucknew
    s.fVehicleAxleNew,
    s.fStandardWeightID,
    s.fGoodName,
    s.fJTBNO,
    s.fJTBIndex,
    s.fLaneNumber,
    s.fEquipCode,
    s.fEquipCodeStr,
    s.fIsUploadJTB,
    s.fLength,
    s.fWidth,
    s.fHeight,
    s.fDirection,
    s.fWay,
    GETDATE()                   -- 创建时间取当前时间
FROM dbo.ZC_CheckData_Second s
-- 防重复：按需加条件，比如按检测单号或检测站+时间+车牌去重
LEFT JOIN dbo.ZC_CheckData_First f
    ON f.fNO = s.fNO           -- 如果 fNO 已存在则跳过
WHERE f.fID IS NULL
  -- AND s.fState NOT IN (...)  -- 可按状态过滤
*/

-- =============================================
-- 方式二：UPDATE — 用复检数据更新已关联的初检记录
-- 场景：初检表已有记录(通过 fSecondID 关联)，用复检的称重数据回写
-- =============================================
/*
UPDATE f
SET
    f.fWeightCheck       = s.fWeightCheck,
    f.fWeightTruck       = s.fWeightTruck,
    f.fWeightOverLoad    = s.fWeightOverLoad,
    f.fWeightOverLoadRate= s.fWeightOverLoadRate,
    f.fVehicleAxle       = s.fVehicleAxle,
    f.fVehicleAxleType   = s.fVehicleAxleType,
    f.fBoardTruck        = s.fBoardTruck,
    f.fboardtrucknew     = s.fBoardTruckNew,
    f.fVehicleAxleNew    = s.fVehicleAxleNew,
    f.fOperator          = s.fOperator,
    f.fCheckPlace        = s.fCheckPlace,
    f.fTrailerNO         = s.fTrailerNO,
    f.fRemark            = s.fRemark,
    f.fDesc              = s.fDesc,
    f.fTime              = s.fTime,     -- 用复检时间覆盖
    -- IServiceProvider / 修改者等信息可按需更新
    f.fIsLink            = 1
FROM dbo.ZC_CheckData_First f
INNER JOIN dbo.ZC_CheckData_Second s ON f.fSecondID = s.fID
WHERE s.fState NOT IN (-1, 4, 5, 6, 14, 24, 25, 98, 99)  -- 按有效状态过滤
*/

-- =============================================
-- 方式三：检查关联数据（执行前先预览）
-- =============================================
-- 查看初检表已关联复检的数据量
SELECT COUNT(*) AS 已关联数量
FROM dbo.ZC_CheckData_First
WHERE fSecondID IS NOT NULL;

-- 查看复检表中哪些记录可以被 INSERT（按 fNO 去重）
SELECT s.fNO, s.fBoardTruck, s.fTime, s.fCheckStation
FROM dbo.ZC_CheckData_Second s
LEFT JOIN dbo.ZC_CheckData_First f ON f.fNO = s.fNO
WHERE f.fID IS NULL;

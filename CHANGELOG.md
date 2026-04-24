# Changelog | 更新日志

## Table of Contents | 目录

- [English](#english)
- [中文](#中文)

---

## English

### [0.4.0] - 2026-04-24

#### Added

- **Real Location Retrieval**
  - Android: LocationManager implementation
  - iOS: CLLocationManager implementation
  - Permission checking (Android + iOS)
  - Location service checking (Android + iOS)
  - Cache optimization (< 5 minutes)
  - Timeout protection (30 seconds)
  - Provider selection (GPS > Network > Any)

#### Changed

- Platform channel implementation (previously mock only)
- Better error messages for permission and service issues
- Improved location selection algorithm

#### Fixed

- LocationData.toLatLong() constructor call
- Test timestamp null value issue

---

### [0.3.0] - 2026-04-23

#### Changed

- **Complete Redesign**: Minimal API with no dependencies
  - Removed geolocator dependency
  - Removed permission_handler dependency
  - Removed permission handling features
  - Removed settings integration features
  - Removed streaming features
  - Removed Result type (use try-catch instead)

#### Added

- **Minimal API**
  - `getCurrentLocation()` - Get current location (throws exception on error)
  - `calculateDistance()` - Calculate distance between points (Haversine formula)

- **Simple Models**
  - `LocationData` - Basic location data (lat, lng, accuracy, timestamp)
  - `LatLong` - Geographic coordinate
  - `LocationException` - Simple exception for errors

- **Zero Dependencies** - Pure Dart implementation

#### Removed

- All permission handling features
- All settings integration features
- Result type (simplified to exceptions)
- Permission model
- Error types
- Streaming functionality

#### Documentation

- Rewritten README emphasizing minimal design
- Clear separation of kit vs app layer responsibilities
- Platform channel implementation guide
- Application layer examples

---

### [0.2.0] - 2026-04-23

#### Changed

- Complete rebuild based on Geolocator (later abandoned)
- Added geolocator ^11.0.0 dependency
- Added permission_handler ^11.0.0 dependency
- Rewrote all APIs

---

### [0.1.0] - 2026-04-23

#### Added

- Initial release of LocationKit package
- LocationData model
- LatLong model
- Mock implementation
- Distance calculation

---

## 中文

### [0.4.0] - 2026-04-24

#### 新增

- **真实定位功能**
  - Android: LocationManager 实现
  - iOS: CLLocationManager 实现
  - 权限检查（Android + iOS）
  - 定位服务检查（Android + iOS）
  - 缓存优化（< 5 分钟）
  - 超时保护（30 秒）
  - Provider 选择（GPS > Network > 任意可用）

#### 变更

- Platform Channel 实现（之前只有 mock）
- 更好的权限和服务错误提示
- 改进的位置选择算法

#### 修复

- LocationData.toLatLong() 构造函数调用
- 测试中 timestamp 空值问题

---

### [0.3.0] - 2026-04-23

#### 变更

- **完全重新设计**：最小化 API，零依赖
  - 移除 geolocator 依赖
  - 移除 permission_handler 依赖
  - 移除权限处理功能
  - 移除设置集成功能
  - 移除流式更新功能
  - 移除 Result 类型（改用 try-catch）

#### 新增

- **最小化 API**
  - `getCurrentLocation()` - 获取当前位置（出错时抛出异常）
  - `calculateDistance()` - 计算两点距离（Haversine 公式）

- **简单模型**
  - `LocationData` - 基础位置数据（纬度、经度、精度、时间戳）
  - `LatLong` - 地理坐标
  - `LocationException` - 简单的错误异常

- **零依赖** - 纯 Dart 实现

#### 移除

- 所有权限处理功能
- 所有设置集成功能
- Result 类型（简化为异常）
- 权限模型
- 错误类型
- 流式功能

#### 文档

- 重写 README 强调最小化设计
- 明确区分 kit 层和应用层职责
- Platform Channel 实现指南
- 应用层示例代码

---

### [0.2.0] - 2026-04-23

#### 变更

- 基于 Geolocator 完全重构（后来放弃）
- 添加 geolocator ^11.0.0 依赖
- 添加 permission_handler ^11.0.0 依赖
- 重写所有 API

---

### [0.1.0] - 2026-04-23

#### 新增

- LocationKit 包初始版本
- LocationData 模型
- LatLong 模型
- Mock 实现
- 距离计算功能

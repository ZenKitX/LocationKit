# Changelog | 更新日志

## Table of Contents | 目录

- [English](#english)
- [中文](#中文)

---

## English

### [0.1.0] - 2024-04-20

#### Added

- Initial release of LocationKit package
- **Core Features**
  - LocationService for managing location data
  - Mock implementation for development and testing
  - LocationData model for representing location information
  - LatLong model for geographic coordinates

- **Distance Calculation**
  - Distance calculation between locations
  - Haversine formula implementation

- **Error Handling**
  - LocationResult<T> type for error handling
  - Result type pattern for safe operations

- **Permission Management**
  - Permission management interface (to be implemented)
  - Platform-specific permission handling

#### Documentation

- Comprehensive README with usage examples
- API documentation for all public interfaces
- Mock implementation guide

#### Tested On

- Flutter 3.24.0+
- Dart 3.11.0+
- iOS and Android platforms

---

## 中文

### [0.1.0] - 2024-04-20

#### 新增

- LocationKit 包首次发布
- **核心功能**
  - LocationService 用于管理位置数据
  - 用于开发和测试的 Mock 实现
  - LocationData 模型用于表示位置信息
  - LatLong 模型用于地理坐标

- **距离计算**
  - 位置之间的距离计算
  - Haversine 公式实现

- **错误处理**
  - LocationResult<T> 类型用于错误处理
  - Result 类型模式用于安全操作

- **权限管理**
  - 权限管理接口（待实现）
  - 平台特定的权限处理

#### 文档

- 包含使用示例的完整 README
- 所有公共接口的 API 文档
- Mock 实现指南

#### 测试环境

- Flutter 3.24.0+
- Dart 3.11.0+
- iOS 和 Android 平台

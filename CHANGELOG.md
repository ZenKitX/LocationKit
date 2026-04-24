# Changelog | 更新日志

## Table of Contents | 目录

- [English](#english)
- [中文](#中文)

---

## English

### [0.2.0] - 2026-04-23

#### Changed

- **Complete Rewrite**: Rebuilt LocationKit based on Geolocator
  - Now depends on geolocator ^11.0.0
  - Now depends on permission_handler ^11.0.0
  - Removed custom implementation in favor of mature, tested solution

#### Added

- **Permission Handling**
  - `checkPermission()` - Check current permission status
  - `requestPermission()` - Request location permission
  - `LocationPermission` enum with extension methods
  - `LocationError.permissionPermanentlyDenied` error type

- **Location Services**
  - `isLocationServiceEnabled()` - Check if location service is enabled
  - `getLastKnownPosition()` - Get last known position
  - `getLocationStream()` - Stream location updates

- **Settings Integration**
  - `openAppSettings()` - Open app settings
  - `openLocationSettings()` - Open location settings

- **Navigation Helpers**
  - `calculateBearing()` - Calculate bearing between coordinates

- **Enhanced Models**
  - `LocationData` with additional fields (altitudeAccuracy, headingAccuracy, speedAccuracy, isMocked)
  - `LocationPermission` enum with extension methods
  - `LocationError` with comprehensive error types
  - `Result<T>` type for safe error handling

- **Cross-Platform Support**
  - Android, iOS, Web, macOS, Linux, Windows
  - Platform-specific configuration guides

#### Removed

- Custom GPS implementation (replaced by Geolocator)
- Mock implementation (use Geolocator's mock feature instead)

#### Documentation

- Completely rewritten README with comprehensive usage examples
- Platform-specific configuration guides
- Error handling examples
- API reference table

### [0.1.0] - 2026-04-23

#### Added

- Initial release of LocationKit package
- LocationData model for representing location information
- LatLong model for geographic coordinates
- Mock implementation for development and testing
- Distance calculation using Haversine formula
- LocationResult<T> type for error handling

#### Documentation

- Initial README with usage examples
- API documentation for all public interfaces

#### Tested On

- Flutter 3.24.0+
- Dart 3.5.0+
- iOS and Android platforms

---

## 中文

### [0.2.0] - 2026-04-23

#### 变更

- **完全重写**：基于 Geolocator 重建 LocationKit
  - 现在依赖 geolocator ^11.0.0
  - 现在依赖 permission_handler ^11.0.0
  - 移除自定义实现，改用成熟、经过测试的解决方案

#### 新增

- **权限处理**
  - `checkPermission()` - 检查当前权限状态
  - `requestPermission()` - 请求位置权限
  - `LocationPermission` 枚举及扩展方法
  - `LocationError.permissionPermanentlyDenied` 错误类型

- **位置服务**
  - `isLocationServiceEnabled()` - 检查位置服务是否启用
  - `getLastKnownPosition()` - 获取上次已知位置
  - `getLocationStream()` - 流式位置更新

- **设置集成**
  - `openAppSettings()` - 打开应用设置
  - `openLocationSettings()` - 打开位置设置

- **导航辅助**
  - `calculateBearing()` - 计算坐标之间的方位角

- **增强模型**
  - `LocationData` 包含额外字段（altitudeAccuracy、headingAccuracy、speedAccuracy、isMocked）
  - `LocationPermission` 枚举及扩展方法
  - `LocationError` 包含全面的错误类型
  - `Result<T>` 类型用于安全错误处理

- **跨平台支持**
  - Android、iOS、Web、macOS、Linux、Windows
  - 平台特定配置指南

#### 移除

- 自定义 GPS 实现（由 Geolocator 替代）
- Mock 实现（使用 Geolocator 的 mock 功能）

#### 文档

- 完全重写 README，包含全面的使用示例
- 平台特定配置指南
- 错误处理示例
- API 参考表

### [0.1.0] - 2026-04-23

#### 新增

- LocationKit 包首次发布
- LocationData 模型用于表示位置信息
- LatLong 模型用于地理坐标
- 用于开发和测试的 Mock 实现
- 使用 Haversine 公式的距离计算
- LocationResult<T> 类型用于错误处理

#### 文档

- 包含使用示例的初始 README
- 所有公共接口的 API 文档

#### 测试环境

- Flutter 3.24.0+
- Dart 3.5.0+
- iOS 和 Android 平台

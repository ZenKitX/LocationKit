# LocationKit 重构方案

## 📊 当前问题

从零实现导致的问题：
1. 缺少权限管理
2. 缺少平台特定实现
3. 缺少完整的错误处理
4. 功能过于简单
5. 缺少平台接口抽象

## 🎯 参考项目分析

### Geolocator (by Baseflow)

**优点：**
- ✅ 最流行（>100k likes）
- ✅ 功能完整（权限、定位、距离计算）
- ✅ 跨平台支持（Android/iOS/Web/Mac/Linux/Windows）
- ✅ 完善的错误处理
- ✅ 平台接口抽象
- ✅ 代码质量高

**架构：**
```
geolocator/                    # 主包
  └── Geolocator (静态方法)

geolocator_platform_interface/ # 平台接口
  ├── GeolocatorPlatform
  ├── Position (域模型)
  ├── LocationPermission
  └── LocationSettings

geolocator_android/            # Android 实现
  └── GeolocatorAndroid

geolocator_apple/              # iOS/macOS 实现
  └── GeolocatorApple

geolocator_web/                # Web 实现
  └── GeolocatorWeb

geolocator_linux/              # Linux 实现
  └── GeolocatorLinux

geolocator_windows/            # Windows 实现
  └── GeolocatorWindows
```

**核心 API：**
```dart
// 权限检查
await Geolocator.checkPermission()
await Geolocator.requestPermission()

// 服务检查
await Geolocator.isLocationServiceEnabled()

// 获取位置
await Geolocator.getCurrentPosition()
await Geolocator.getLastKnownPosition()

// 流式监听
Geolocator.getPositionStream()

// 距离计算
Geolocator.distanceBetween(startLat, startLng, endLat, endLng)
```

### Permission Handler (by Baseflow)

**优点：**
- ✅ 权限管理专业化
- ✅ 跨平台支持
- ✅ 完善的权限类型

**核心 API：**
```dart
// 检查权限
await Permission.location.status

// 请求权限
await Permission.location.request()

// 永久拒绝检查
await Permission.location.isPermanentlyDenied

// 打开设置
await openAppSettings()
```

## 🎨 新设计方案

### 方案 A: 直接依赖 Geolocator（推荐）

**优点：**
- ✅ 代码最少
- ✅ 稳定性最高
- ✅ 维护成本低
- ✅ 功能完整

**实现：**
```yaml
dependencies:
  geolocator: ^11.0.0
  permission_handler: ^11.0.0
```

**LocationKit 提供：**
1. 友好的 API 封装
2. ZenKit 风格的错误处理（Result 类型）
3. 与 WeatherKit/SolarTermKit 集成
4. 简化的使用接口

```dart
// LocationKit API
class LocationKit {
  // 获取当前位置
  static Future<Result<LocationData>> getCurrentLocation()

  // 持续监听位置
  static Stream<Result<LocationData>> getLocationStream()

  // 检查权限
  static Future<Result<LocationPermission>> checkPermission()

  // 请求权限
  static Future<Result<LocationPermission>> requestPermission()

  // 距离计算
  static double calculateDistance(LatLong start, LatLong end)
}
```

### 方案 B: Fork Geolocator

**优点：**
- ✅ 可以自定义
- ✅ 完全控制

**缺点：**
- ❌ 维护成本高
- ❌ 需要跟随上游更新

### 方案 C: 使用 platform channel

**优点：**
- ✅ 完全自主

**缺点：**
- ❌ 开发成本高
- ❌ 需要原生代码
- ❌ 维护成本高

## 🚀 推荐实现（方案 A）

### 目录结构

```
LocationKit/
├── lib/
│   ├── location_kit.dart           # 主入口
│   └── src/
│       ├── location_kit.dart       # LocationKit 类
│       ├── models/
│       │   ├── location_data.dart  # 位置数据模型
│       │   ├── location_permission.dart
│       │   └── lat_long.dart
│       ├── errors/
│       │   └── location_errors.dart
│       └── adapters/
│           └── geolocator_adapter.dart  # Geolocator 适配器
└── pubspec.yaml
```

### 核心代码

```dart
// location_kit.dart
class LocationKit {
  // 获取当前位置
  static Future<Result<LocationData>> getCurrentLocation({
    LocationSettings? settings,
  }) async {
    try {
      // 检查服务
      if (!await Geolocator.isLocationServiceEnabled()) {
        return Result.failure(
          LocationError.serviceDisabled('Location service is disabled'),
        );
      }

      // 检查权限
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          return Result.failure(
            LocationError.permissionDenied('Permission denied'),
          );
        }
      }

      // 获取位置
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: settings?.accuracy ?? LocationAccuracy.best,
      );

      return Result.success(_convertPosition(position));
    } on Exception catch (e) {
      return Result.failure(
        LocationError.unknown(e.toString()),
      );
    }
  }

  // 距离计算
  static double calculateDistance(LatLong start, LatLong end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  // 内部转换方法
  static LocationData _convertPosition(Position position) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
      speed: position.speed,
      heading: position.heading,
    );
  }
}
```

### 错误处理

```dart
// location_errors.dart
enum LocationErrorType {
  permissionDenied,
  permissionPermanentlyDenied,
  serviceDisabled,
  timeout,
  unknown,
}

class LocationError {
  final LocationErrorType type;
  final String message;

  LocationError.permissionDenied(this.message)
      : type = LocationErrorType.permissionDenied;

  LocationError.serviceDisabled(this.message)
      : type = LocationErrorType.serviceDisabled;

  LocationError.unknown(this.message)
      : type = LocationErrorType.unknown;
}
```

## 📋 实施步骤

1. ✅ 分析 Geolocator 架构（已完成）
2. ⏳ 修改 pubspec.yaml 添加依赖
3. ⏳ 重写 location_kit.dart
4. ⏳ 更新错误处理
5. ⏳ 更新测试
6. ⏳ 更新文档
7. ⏳ 更新示例应用

## 🎯 预期结果

- ✅ 功能完整（权限、定位、距离计算）
- ✅ 稳定可靠（基于成熟的 Geolocator）
- ✅ 代码简洁（<500 行）
- ✅ 易于维护（依赖上游）
- ✅ ZenKit 风格（Result 类型、统一错误处理）

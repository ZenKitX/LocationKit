# LocationKit 架构设计

本文档描述 LocationKit 项目的架构设计原则和实现方案。

## 目录

1. [设计原则](#设计原则)
2. [目录结构](#目录结构)
3. [模块划分](#模块划分)
4. [数据流](#数据流)
5. [错误处理](#错误处理)
6. [未来扩展](#未来扩展)

## 设计原则

### 1. 简单性原则 (Simplicity)

LocationKit 提供简单直观的 API，易于理解和使用。

**优势:**

- 快速上手
- 减少学习成本
- 降低出错概率

### 2. 单一职责原则 (Single Responsibility Principle)

每个类只负责一个明确的功能。

**示例:**

- `LocationService` 只负责定位服务
- `LocationData` 只负责位置数据模型
- `LatLong` 只负责坐标计算

### 3. 类型安全 (Type Safety)

使用 `LocationResult<T>` 类型确保类型安全的错误处理。

**优势:**

- 编译时检查
- 避免空指针异常
- 明确的错误传播

### 4. 可扩展性 (Extensibility)

设计支持未来扩展到真实的 GPS 定位。

**优势:**

- 易于替换实现
- 支持多种定位源
- 灵活的错误处理

## 目录结构

```
lib/
├── location_kit.dart              # 主导出文件
└── src/
    ├── models/
    │   └── location_model.dart    # 位置模型
    └── services/
        └── location_service.dart  # 定位服务（当前为 Mock）

test/                              # 测试目录
└── location_test.dart

doc/                               # 文档目录
├── API.md
└── ARCHITECTURE.md

.github/workflows/                 # CI/CD 配置
└── dart.yml
```

## 模块划分

### Models（数据模型）

定义数据结构。

#### LatLong

**职责:**

- 表示经纬度坐标
- 提供距离计算
- 验证坐标有效性

**字段:**

```dart
double latitude   // 纬度（-90 到 90）
double longitude  // 经度（-180 到 180）
```

**方法:**

- `distanceTo(other)`: 计算到另一个坐标的距离
- `isValid`: 检查坐标是否有效

#### LocationData

**职责:**

- 表示位置信息
- 包含坐标、地址、国家等

**字段:**

```dart
String name         // 位置名称
LatLong coordinates // 坐标
String country      // 国家
String? region      // 地区/州（可选）
String? city        // 城市（可选）
String? address     // 详细地址（可选）
```

### Services（服务层）

实现业务逻辑。

#### LocationService

**职责:**

- 获取当前位置
- 反向地理编码
- 计算距离
- 管理权限

**主要方法:**

- `getCurrentLocation()`: 获取当前位置
- `reverseGeocode(coordinates)`: 反向地理编码
- `calculateDistance(from, to)`: 计算距离
- `hasPermission()`: 检查权限
- `requestPermission()`: 请求权限

### Errors（错误处理）

定义错误类型和结果类型。

#### LocationError

**职责:**

- 定义错误类型
- 包含错误消息

**错误类型:**

- `permissionDenied`: 权限被拒绝
- `serviceDisabled`: 服务已禁用
- `timeout`: 超时
- `unknown`: 未知错误

#### LocationResult<T>

**职责:**

- 包装可能失败的操作
- 提供类型安全的错误处理

**优势:**

- 避免异常
- 明确错误传播
- 支持链式操作

## 数据流

### 获取位置流程

```
1. 调用 getCurrentLocation()
   ↓
2. 检查权限
   ↓
3a. 无权限 → 返回 permissionDenied 错误
   ↓
3b. 有权限 → 获取位置
   ↓
4. 返回 LocationResult<LocationData>
```

### 反向地理编码流程

```
1. 调用 reverseGeocode(coordinates)
   ↓
2. 验证坐标有效性
   ↓
3a. 无效坐标 → 返回错误
   ↓
3b. 有效坐标 → 查询地址
   ↓
4. 返回 LocationResult<LocationData>
```

### 距离计算流程

```
1. 调用 calculateDistance(from, to)
   ↓
2. 验证坐标有效性
   ↓
3. 使用 Haversine 公式计算
   ↓
4. 返回距离（公里）
```

## 错误处理

### LocationResult<T> 模式

```dart
final result = await locationService.getCurrentLocation();

result.fold(
  (location) {
    // 成功处理
    print('Current location: ${location.name}');
  },
  (error) {
    // 错误处理
    print('Error: ${error.message}');
  },
);
```

### 错误类型映射

| 场景 | LocationErrorType | 处理方式 |
|------|------------------|---------|
| 权限被拒绝 | permissionDenied | 引导用户开启权限 |
| GPS 关闭 | serviceDisabled | 提示开启 GPS |
| 请求超时 | timeout | 提示稍后重试 |
| 未知错误 | unknown | 提示未知错误 |

## 未来扩展

### 真实 GPS 定位

当前实现是 Mock 版本，未来可以集成真实的 GPS 定位：

#### 方案 1: 使用 location 包

```yaml
dependencies:
  location: ^5.0.0
```

```dart
class LocationService {
  final Location _location = Location();

  Future<LocationResult<LocationData>> getCurrentLocation() async {
    try {
      final position = await _location.getLocation();
      final location = LocationData(
        name: 'Current Location',
        coordinates: LatLong(
          latitude: position.latitude!,
          longitude: position.longitude!,
        ),
        country: 'Unknown',
      );
      return LocationResult.success(location);
    } catch (e) {
      return LocationResult.failure(_handleError(e));
    }
  }
}
```

#### 方案 2: 使用 geolocator 包

```yaml
dependencies:
  geolocator: ^10.0.0
```

### 反向地理编码

集成真实的反向地理编码 API：

```dart
Future<LocationResult<LocationData>> reverseGeocode(LatLong coordinates) async {
  try {
    final response = await http.get(
      Uri.parse('https://maps.googleapis.com/maps/api/geocode/json'),
    );
    final data = jsonDecode(response.body);
    final address = data['results'][0]['formatted_address'];
    final location = LocationData(
      name: 'Unknown',
      coordinates: coordinates,
      country: data['results'][0]['address_components'].last['short_name'],
      address: address,
    );
    return LocationResult.success(location);
  } catch (e) {
    return LocationResult.failure(LocationError.unknown(e.toString()));
  }
}
```

### 权限管理

实现真正的权限管理：

```dart
Future<bool> requestPermission() async {
  final permission = await _location.requestPermission();
  return permission == PermissionStatus.granted;
}
```

## 性能优化

### 1. 距离计算优化

使用 Haversine 公式计算球面距离，精度高且性能好：

```dart
double distanceTo(LatLong other) {
  const double earthRadiusKm = 6371.0;

  final double lat1Rad = _toRadians(latitude);
  final double lat2Rad = _toRadians(other.latitude);
  final double deltaLatRad = _toRadians(other.latitude - latitude);
  final double deltaLonRad = _toRadians(other.longitude - longitude);

  final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
      cos(lat1Rad) * cos(lat2Rad) *
      sin(deltaLonRad / 2) * sin(deltaLonRad / 2);

  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadiusKm * c;
}

double _toRadians(double degrees) {
  return degrees * pi / 180;
}
```

### 2. 缓存位置数据

频繁访问的位置可以缓存，减少重复计算。

### 3. 懒加载

地址信息按需加载，减少不必要的请求。

## 扩展指南

### 添加新的定位源

1. 实现 `LocationService` 接口
2. 适配数据模型
3. 注册到服务容器

### 添加新的错误类型

1. 在 `LocationErrorType` 中添加新类型
2. 创建对应的工厂方法
3. 更新错误处理逻辑

### 自定义位置数据

扩展 `LocationData` 模型，添加更多字段：
- 时区
- 行政区划代码
- 邮政编码
- 国家代码

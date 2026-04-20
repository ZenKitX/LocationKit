# LocationKit API 参考文档

本文档提供 LocationKit 的完整 API 参考。

## 目录

- [LocationService](#locationservice)
- [LocationData](#locationdata)
- [LatLong](#latlong)
- [LocationResult](#locationresult)
- [LocationError](#locationerror)

---

## LocationService

定位服务类（当前为 Mock 实现）。

### 构造函数

```dart
LocationService()
```

### 方法

#### getCurrentLocation

获取当前位置。

```dart
Future<LocationResult<LocationData>> getCurrentLocation()
```

**返回:** `Future<LocationResult<LocationData>>`

#### reverseGeocode

反向地理编码，根据坐标获取地址信息。

```dart
Future<LocationResult<LocationData>> reverseGeocode(LatLong coordinates)
```

**参数:**
- `coordinates`: 坐标

**返回:** `Future<LocationResult<LocationData>>`

#### calculateDistance

计算两个位置之间的距离（公里）。

```dart
Future<double> calculateDistance(LatLong from, LatLong to)
```

**参数:**
- `from`: 起点坐标
- `to`: 终点坐标

**返回:** `Future<double>` - 距离（公里）

#### hasPermission

检查是否有定位权限。

```dart
Future<bool> hasPermission()
```

**返回:** `Future<bool>`

#### requestPermission

请求定位权限。

```dart
Future<bool> requestPermission()
```

**返回:** `Future<bool>` - 是否授权成功

---

## LocationData

位置数据模型。

### 构造函数

```dart
LocationData({
  required String name,
  required LatLong coordinates,
  required String country,
  String? region,
  String? city,
  String? address,
})
```

**参数:**
- `name`: 位置名称（必需）
- `coordinates`: 坐标（必需）
- `country`: 国家（必需）
- `region`: 地区/州（可选）
- `city`: 城市（可选）
- `address`: 详细地址（可选）

### 属性

```dart
String name        // 位置名称
LatLong coordinates // 坐标
String country     // 国家
String? region     // 地区/州
String? city       // 城市
String? address    // 详细地址
```

---

## LatLong

经纬度坐标模型。

### 构造函数

```dart
const LatLong({
  required double latitude,
  required double longitude,
})
```

**参数:**
- `latitude`: 纬度（-90 到 90）
- `longitude`: 经度（-180 到 180）

### 属性

```dart
double latitude  // 纬度
double longitude // 经度
```

### 方法

#### distanceTo

计算到另一个坐标的距离（公里）。

```dart
double distanceTo(LatLong other)
```

**参数:**
- `other`: 另一个坐标

**返回:** `double` - 距离（公里）

#### isValid

检查坐标是否有效。

```dart
bool get isValid
```

**返回:** `bool` - 是否有效

---

## LocationResult

位置结果类型，用于包装可能失败的操作。

### 静态工厂方法

```dart
LocationResult.success(T data)
LocationResult.failure(LocationError error)
```

### 属性

```dart
bool isSuccess         // 是否成功
bool isFailure         // 是否失败
T? data               // 成功数据
LocationError? error  // 错误信息
```

### 方法

#### fold

根据成功或失败状态执行不同的回调。

```dart
R fold<R>(R Function(T data) onSuccess, R Function(LocationError error) onFailure)
```

---

## LocationError

位置错误类。

### 构造函数

```dart
LocationError({
  required LocationErrorType type,
  required String message,
})
```

### 静态工厂方法

```dart
LocationError.permissionDenied(String message)
LocationError.serviceDisabled(String message)
LocationError.timeout(String message)
LocationError.unknown(String message)
```

### 属性

```dart
LocationErrorType type  // 错误类型
String message         // 错误消息
```

---

## LocationErrorType

位置错误类型枚举。

### 枚举值

```dart
enum LocationErrorType {
  permissionDenied,  // 权限被拒绝
  serviceDisabled,   // 服务已禁用
  timeout,          // 超时
  unknown,          // 未知错误
}
```

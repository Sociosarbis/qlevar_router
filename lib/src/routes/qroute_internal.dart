import '../../qlevar_router.dart';
import '../types/qroute_key.dart';
import 'qroute.dart';
import 'qroute_children.dart';

class QRouteInternal {
  /// The key
  final QKey key;

  /// The full path
  final String fullPath;

  /// The orginal definition for this route
  final QRoute route;

  final bool isNotFound;

  bool isProcessed = false;

  String? activePath;

  QParams? params;

  /// The children for this route
  QRouteChildren? children;

  /// The active parent for this route
  QRouteInternal? parent;

  /// The active child for this route
  QRouteInternal? child;

  QRouteInternal({
    required this.key,
    required this.fullPath,
    required this.route,
    required this.isNotFound,
    this.activePath,
    this.params,
    this.children,
    this.parent,
    this.child,
  });

  factory QRouteInternal.from(QRoute route, String cureentPath) {
    final key = QKey(route.name ?? route.path);
    if (!route.path.startsWith('/')) {
      route = route.copyWith(path: '/${route.path}');
    }
    final fullPath = '$cureentPath${route.path}';
    QR.treeInfo.namePath[route.name ?? route.path] = fullPath;
    return QRouteInternal(
        key: key,
        route: route,
        fullPath: fullPath,
        isNotFound: false,
        children: route.children == null
            ? null
            : QRouteChildren.from(route.children!, key, fullPath));
  }

  factory QRouteInternal.notfound(String notFoundPath) {
    final route = QR.settings.notFoundPage;
    final key = QKey(route.name ?? route.path);
    return QRouteInternal(
        key: key,
        route: route,
        fullPath: route.path,
        isNotFound: true,
        params: QParams(params: {}),
        activePath: notFoundPath,
        children: route.children == null
            ? null
            : QRouteChildren.from(route.children!, key, route.path));
  }

  void clean() {
    child = null;
    activePath = null;
    params = null;
    isProcessed = false;
  }

  bool isSame(QRouteInternal other) => key.isSame(other.key);

  bool get hasChild => child != null;

  String get name => route.name ?? route.path;

  @override
  String toString() => 'Route: $key, Full Path: $fullPath';

  bool get hasMiddlewares =>
      route.middleware != null && route.middleware!.isNotEmpty;

  String getLastActivePath() {
    if (child != null) {
      return child!.getLastActivePath();
    }
    return activePath!;
  }
}

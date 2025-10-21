import 'package:flutter/material.dart';
import '../services/resource_preloader.dart';

/// Provider widget for ResourcePreloader
class ResourcePreloaderProvider extends InheritedWidget {
  final ResourcePreloader preloader;

  const ResourcePreloaderProvider({
    super.key,
    required this.preloader,
    required super.child,
  });

  static ResourcePreloader of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ResourcePreloaderProvider>();
    assert(provider != null, 'ResourcePreloaderProvider not found in context');
    return provider!.preloader;
  }

  @override
  bool updateShouldNotify(ResourcePreloaderProvider oldWidget) {
    return preloader != oldWidget.preloader;
  }
}

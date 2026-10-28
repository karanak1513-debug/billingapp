import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  @override
  set state(int value) => super.state = value;

  void setIndex(int index) => state = index;
}

final selectedNavIndexProvider = NotifierProvider<NavigationIndexNotifier, int>(
  NavigationIndexNotifier.new,
);

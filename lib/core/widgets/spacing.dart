import 'package:flutter/widgets.dart';

abstract final class VSpace {
  static const xsmall = SizedBox(height: 4);
  static const small = SizedBox(height: 8);
  static const medium = SizedBox(height: 12);
  static const large = SizedBox(height: 16);
}

abstract final class HSpace {
  static const xsmall = SizedBox(width: 4);
  static const small = SizedBox(width: 8);
  static const medium = SizedBox(width: 12);
  static const large = SizedBox(width: 16);
}

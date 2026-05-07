import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/dev_http_overrides.dart';

void main() {
  if (!kIsWeb) {
    HttpOverrides.global = DevHttpOverrides();
  }
  runApp(const EducationApp());
}

// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'patro.dart';

/// Nepali Utilities
class Patro {
  static Patro _instance;

  /// Language for Nepali Utilities.
  ///
  /// Default is [Language.english], if not set.
  Language language = Language.english;

  Patro._();

  /// Nepali Utilities
  ///
  /// Default language for nepali utilities can be set using [lang].
  factory Patro([Language lang]) {
    _instance ??= Patro._();
    if (lang != null) _instance.language = lang;
    return _instance;
  }
}

#!/bin/bash
# Install Flutter
git clone https://github.com/aspect-build/flutter.git --branch 3.22.2 --depth 1
export PATH="$PWD/flutter/bin:$PATH"

# Build
flutter pub get
flutter build web --release

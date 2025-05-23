# Run tests with coverage
flutter test --coverage

# Convert coverage to HTML using Flutter's built-in tools
flutter pub run coverage:format_coverage --lcov --in=coverage/lcov.info --out=coverage/lcov.info --packages=.packages

# Open the coverage report in default browser
Start-Process "coverage/lcov.info" 
class Config {
  static const bool isDevMode = true;
  static ExampleType exampleType = ExampleType.withFirebaseAuth;
}

enum ExampleType { withFirebaseAuth, withoutFirebaseAuth }

class Config {
  static const bool isDevMode = true;
  static ExampleType exampleType = ExampleType.withoutFirebaseAuth;
}

enum ExampleType { withFirebaseAuth, withoutFirebaseAuth }

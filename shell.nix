let
  pkgs = (import <unstable> {});
in pkgs.mkShell {
  propagatedBuildInputs = [
    pkgs.awscli2
  ];
}

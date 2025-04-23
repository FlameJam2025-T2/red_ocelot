class LTRB {
  LTRB({this.left, this.top, this.right, this.bottom});

  double? left;
  double? top;
  double? right;
  double? bottom;

  double get width =>
      right != null && left != null ? right! - left! : double.nan;
  double get height =>
      bottom != null && top != null ? bottom! - top! : double.nan;

  void setFrom(LTRB other) {
    left = other.left;
    top = other.top;
    right = other.right;
    bottom = other.bottom;
  }
}

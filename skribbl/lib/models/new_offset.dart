class OffsetPoints {
  final double dx;
  final double dy;

  const OffsetPoints({required this.dx, required this.dy});

  factory OffsetPoints.fromMap(Map<String, dynamic> data) {
    return OffsetPoints(
      dx: data['dx'],
      dy: data['dy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dx': dx,
      'dy': dy,
    };
  }
}

class EqualizerBand {
  final int centerFrequency;
  final double gain;
  final int index;

  EqualizerBand({
    required this.centerFrequency,
    required this.gain,
    required this.index,
  });

  EqualizerBand copyWith({double? gain}) {
    return EqualizerBand(
      centerFrequency: centerFrequency,
      gain: gain ?? this.gain,
      index: index,
    );
  }
}

class EqualizerParameters {
  final List<EqualizerBand> bands;
  final double minDecibels;
  final double maxDecibels;

  EqualizerParameters({
    required this.bands,
    required this.minDecibels,
    required this.maxDecibels,
  });

  EqualizerParameters copyWith({
    List<EqualizerBand>? bands,
    double? minDecibels,
    double? maxDecibels,
  }) {
    return EqualizerParameters(
      bands: bands ?? this.bands,
      minDecibels: minDecibels ?? this.minDecibels,
      maxDecibels: maxDecibels ?? this.maxDecibels,
    );
  }
}

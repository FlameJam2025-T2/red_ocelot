import 'dart:math';
import 'dart:typed_data';

import 'package:mp_audio_stream/mp_audio_stream.dart';

extension Float32ListExtension on Float32List {
  // 50% stream mix
  operator +(Float32List other) {
    if (length != other.length) {
      throw ArgumentError('Length mismatch: $length != ${other.length}');
    }
    final Float32List result = Float32List(length);
    for (int i = 0; i < length; i++) {
      result[i] = this[i] * 0.5 + other[i] * 0.5;
    }
    return result;
  }
}

class GeneratedAudio {
  static final GeneratedAudio _instance = GeneratedAudio._internal();
  factory GeneratedAudio() => _instance;
  GeneratedAudio._internal();

  late final AudioStream audioStream;

  void init() {
    audioStream = getAudioStream();
    audioStream.init();
  }

  void play() {
    audioStream.resume();
  }

  void push(Float32List buffer) {
    audioStream.push(buffer);
  }

  Future<void> fromGenerator(AudioGenerator generator, {int count = 1}) async {
    final Float32List buffer = generator.generate();
    for (int i = 0; i < count; i++) {
      push(buffer);
    }
  }

  void stop() {
    audioStream.uninit();
  }
}

abstract class AudioGenerator {
  final int sampleRate;
  final int bufferSize;
  final int channels;

  AudioGenerator({
    required this.sampleRate,
    required this.bufferSize,
    this.channels = 1,
  });
  Float32List generate();
}

class SineWaveGenerator extends AudioGenerator {
  final double frequency;
  final double amplitude;

  SineWaveGenerator({
    required this.frequency,
    required this.amplitude,
    required super.sampleRate,
    required super.bufferSize,
    super.channels = 1,
  });

  @override
  Float32List generate() {
    final Float32List buffer = Float32List(bufferSize);
    final double increment = (2 * pi * frequency) / sampleRate;

    for (int i = 0; i < bufferSize; i++) {
      buffer[i] = amplitude * sin(increment * i);
    }

    return buffer;
  }
}

class SquareWaveGenerator extends AudioGenerator {
  final double frequency;
  final double amplitude;

  SquareWaveGenerator({
    required this.frequency,
    required this.amplitude,
    required super.sampleRate,
    required super.bufferSize,
    super.channels = 1,
  });

  @override
  Float32List generate() {
    final Float32List buffer = Float32List(bufferSize);
    final double period = sampleRate / frequency;

    for (int i = 0; i < bufferSize; i++) {
      buffer[i] = (i % period < period / 2) ? amplitude : -amplitude;
    }

    return buffer;
  }

  Iterable<double> generator() sync* {
    final double period = sampleRate / frequency;
    for (int i = 0; i < bufferSize; i++) {
      yield (i % period < period / 2) ? amplitude : -amplitude;
    }
  }
}

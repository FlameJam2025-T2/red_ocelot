import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mp_audio_stream/mp_audio_stream.dart';

extension Float32ListExtension on Float32List {
  // 50% stream mix
  Float32List operator +(Float32List other) {
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
  bool _playing = false;
  bool _stop = false;
  GeneratedAudio._internal();

  late final AudioStream audioStream;

  void init() {
    audioStream = getAudioStream();
    audioStream.init();
  }

  void initFromGenerator(AudioGenerator generator) {
    audioStream = getAudioStream();
    audioStream.init(
      bufferMilliSec: generator.bufferSize * 1000 ~/ generator.sampleRate,
      channels: generator.channels,
      sampleRate: generator.sampleRate,
    );
  }

  void play() {
    if (_playing) {
      return;
    }
    _playing = true;
    _stop = false;
    audioStream.resume();
  }

  void push(Float32List buffer) {
    audioStream.push(buffer);
  }

  Future<void> pushGenerator(
    AudioGenerator generator,
    Future<bool> futureStop,
  ) async {
    play();
    futureStop.whenComplete(() {
      _stop = true;
      stop();
    });

    while (!_stop) {
      final Float32List buffer = generator.generate();
      if (_stop) {
        stop();
        break;
      }
      audioStream.push(buffer);
    }
  }

  Future<void> pushGeneratorStream(
    AudioGenerator generator,
    Future<bool> futureStop,
  ) async {
    play();
    if (kDebugMode) {
      print('pushGeneratorStream');
    }
    futureStop.whenComplete(() {
      _stop = true;
      stop();
    });
    await for (final double sample in generator.generator()) {
      if (_stop) {
        stop();
        break;
      }
      final Float32List buffer = Float32List(generator.bufferSize);
      for (int i = 0; i < generator.bufferSize; i++) {
        buffer[i] = sample;
      }
      audioStream.push(buffer);
    }
    if (_stop) {
      stop();
    }
  }

  void stop() {
    _stop = true;
    if (!_playing) {
      return;
    }
    _playing = false;
    audioStream.uninit();
  }
}

abstract class AudioGeneratorStop {
  void stop();
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
  Stream<double> generator();
}

class SineWaveGenerator extends AudioGenerator {
  double frequency;
  double amplitude;

  SineWaveGenerator({
    required this.frequency,
    required this.amplitude,
    required super.sampleRate,
    required super.bufferSize,
    super.channels = 1,
  });

  double get period => sampleRate / frequency;
  double get increment => (2 * pi * frequency) / sampleRate;

  double _wave(int i) {
    return amplitude * sin(increment * i);
  }

  @override
  Float32List generate() {
    final Float32List buffer = Float32List(bufferSize);

    for (int i = 0; i < bufferSize; i++) {
      buffer[i] = _wave(i);
    }

    return buffer;
  }

  @override
  Stream<double> generator() async* {
    for (int i = 0; i < bufferSize; i++) {
      yield _wave(i);
    }
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

  double get period => sampleRate / frequency;
  double get halfPeriod => period / 2;

  double _wave(int i) {
    return (i % period < halfPeriod) ? amplitude : -amplitude;
  }

  @override
  Float32List generate() {
    final Float32List buffer = Float32List(bufferSize);

    for (int i = 0; i < bufferSize; i++) {
      buffer[i] = _wave(i);
    }

    return buffer;
  }

  @override
  Stream<double> generator() async* {
    for (int i = 0; i < bufferSize; i++) {
      yield _wave(i);
    }
  }
}

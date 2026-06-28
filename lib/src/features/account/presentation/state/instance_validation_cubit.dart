import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/foundation/networking/discovery/instance_discovery_service.dart' as instance_discovery;
import 'package:thunder/src/features/instance/domain/models/instance_discovery_result.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

typedef InstanceDiscoveryLookup = Future<InstanceDiscoveryResult?> Function(String instance);
typedef InstanceMetadataLookup = Future<ThunderInstanceInfo> Function(InstanceDiscoveryResult discovery);
typedef InstanceHostNormalizer = String? Function(String input);

/// Describes the current instance-input validation phase.
enum InstanceValidationStatus { idle, detecting, valid, invalid }

/// Validates instance input and loads full site metadata in the background.
class InstanceValidationCubit extends Cubit<InstanceValidationState> {
  InstanceValidationCubit({
    InstanceDiscoveryLookup? discoveryLookup,
    InstanceMetadataLookup? metadataLookup,
    InstanceHostNormalizer? hostNormalizer,
    Duration debounceDuration = const Duration(milliseconds: 150),
  })  : _discoveryLookup = discoveryLookup ?? instance_discovery.discoverInstance,
        _metadataLookup = metadataLookup ?? instance_discovery.loadInstanceInfo,
        _hostNormalizer = hostNormalizer ?? instance_discovery.normalizeInstanceHost,
        _debounceDuration = debounceDuration,
        super(const InstanceValidationState());

  final InstanceDiscoveryLookup _discoveryLookup;
  final InstanceMetadataLookup _metadataLookup;
  final InstanceHostNormalizer _hostNormalizer;
  final Duration _debounceDuration;

  Timer? _debounceTimer;
  Future<void>? _metadataFuture;
  int _generation = 0;

  /// Schedules validation for the latest instance [input].
  void instanceChanged(String input) {
    _debounceTimer?.cancel();
    _metadataFuture = null;
    final generation = ++_generation;
    final trimmedInput = input.trim();

    if (trimmedInput.isEmpty) {
      emit(const InstanceValidationState());
      return;
    }

    final host = _hostNormalizer(trimmedInput);
    if (host == null) {
      emit(InstanceValidationState(input: trimmedInput, status: InstanceValidationStatus.invalid));
      return;
    }

    emit(InstanceValidationState(
      input: trimmedInput,
      status: InstanceValidationStatus.detecting,
      normalizedHost: host,
    ));

    _debounceTimer = Timer(_debounceDuration, () => unawaited(_detect(host, generation)));
  }

  /// Waits for full metadata associated with the current valid input.
  Future<void> completeMetadata() async {
    await _metadataFuture;
  }

  Future<void> _detect(String host, int generation) async {
    final discovery = await _discoveryLookup(host);
    if (_isStale(generation)) return;

    if (discovery == null) {
      emit(state.copyWith(
        status: InstanceValidationStatus.invalid,
        normalizedHost: () => host,
        platform: () => null,
        detectedVersion: () => null,
        instanceInfo: () => null,
        isMetadataLoading: false,
      ));
      return;
    }

    emit(state.copyWith(
      status: InstanceValidationStatus.valid,
      normalizedHost: () => discovery.host,
      platform: () => discovery.platform,
      detectedVersion: () => discovery.version,
      instanceInfo: () => null,
      isMetadataLoading: true,
    ));

    late final Future<void> metadataFuture;
    metadataFuture = _loadMetadata(discovery, generation).whenComplete(() {
      if (identical(_metadataFuture, metadataFuture)) _metadataFuture = null;
    });
    _metadataFuture = metadataFuture;
    await metadataFuture;
  }

  Future<void> _loadMetadata(InstanceDiscoveryResult discovery, int generation) async {
    try {
      final instanceInfo = await _metadataLookup(discovery);
      if (_isStale(generation)) return;

      if (!instanceInfo.success) {
        emit(state.copyWith(
          status: InstanceValidationStatus.invalid,
          instanceInfo: () => null,
          isMetadataLoading: false,
        ));
        return;
      }

      emit(state.copyWith(
        status: InstanceValidationStatus.valid,
        normalizedHost: () => instanceInfo.domain,
        platform: () => instanceInfo.platform ?? discovery.platform,
        detectedVersion: () => instanceInfo.version ?? discovery.version,
        instanceInfo: () => instanceInfo,
        isMetadataLoading: false,
      ));
    } catch (_) {
      if (_isStale(generation)) return;
      emit(state.copyWith(
        status: InstanceValidationStatus.invalid,
        instanceInfo: () => null,
        isMetadataLoading: false,
      ));
    }
  }

  bool _isStale(int generation) => isClosed || generation != _generation;

  @override
  Future<void> close() {
    _generation++;
    _debounceTimer?.cancel();
    return super.close();
  }
}

/// Immutable instance-input validation state.
class InstanceValidationState extends Equatable {
  const InstanceValidationState({
    this.input = '',
    this.status = InstanceValidationStatus.idle,
    this.normalizedHost,
    this.platform,
    this.detectedVersion,
    this.instanceInfo,
    this.isMetadataLoading = false,
  });

  /// Latest trimmed user input.
  final String input;

  /// Current validation phase.
  final InstanceValidationStatus status;

  /// Canonical host derived from the input, when available.
  final String? normalizedHost;

  /// Supported platform identified by NodeInfo.
  final ThreadiversePlatform? platform;

  /// Platform version identified by NodeInfo or full metadata.
  final String? detectedVersion;

  /// Full site metadata, once its background request succeeds.
  final ThunderInstanceInfo? instanceInfo;

  /// Whether full site metadata is still loading.
  final bool isMetadataLoading;

  /// Whether NodeInfo has identified a supported instance.
  bool get isValid => status == InstanceValidationStatus.valid;

  InstanceValidationState copyWith({
    String? input,
    InstanceValidationStatus? status,
    String? Function()? normalizedHost,
    ThreadiversePlatform? Function()? platform,
    String? Function()? detectedVersion,
    ThunderInstanceInfo? Function()? instanceInfo,
    bool? isMetadataLoading,
  }) {
    return InstanceValidationState(
      input: input ?? this.input,
      status: status ?? this.status,
      normalizedHost: normalizedHost != null ? normalizedHost() : this.normalizedHost,
      platform: platform != null ? platform() : this.platform,
      detectedVersion: detectedVersion != null ? detectedVersion() : this.detectedVersion,
      instanceInfo: instanceInfo != null ? instanceInfo() : this.instanceInfo,
      isMetadataLoading: isMetadataLoading ?? this.isMetadataLoading,
    );
  }

  @override
  List<Object?> get props => [input, status, normalizedHost, platform, detectedVersion, instanceInfo, isMetadataLoading];
}

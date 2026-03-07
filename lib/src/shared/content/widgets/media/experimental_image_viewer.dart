import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/packages/ui/ui.dart' show ThunderImageViewer, ThunderImageViewerSource, showSnackbar;
import 'package:thunder/src/shared/content/utils/media/media_utils.dart';

/// An experimental Thunder-specific image viewer built on top of
/// [ThunderImageViewer].
///
/// This widget adds application-level behavior that should not live in the UI
/// package, such as system UI coordination, media actions, post navigation, and
/// the alt-text overlay.
///
/// The underlying gesture implementation is fully provided by
/// [ThunderImageViewer].
class ExperimentalImageViewer extends StatefulWidget {
  /// Creates an experimental image viewer.
  ///
  /// Either [url] or [bytes] must be provided.
  const ExperimentalImageViewer({
    super.key,
    this.altText,
    this.bytes,
    this.isPeek = false,
    this.navigateToPost,
    this.url,
  }) : assert(url != null || bytes != null);

  /// The alternative text displayed by the viewer, if available.
  final String? altText;

  /// The encoded image bytes to display.
  ///
  /// This is used when the viewer is opened from an in-memory image instead of
  /// a network URL.
  final Uint8List? bytes;

  /// Whether the viewer is being shown as a lightweight peek overlay.
  ///
  /// Peek mode suppresses the full viewer chrome and avoids system UI changes.
  final bool isPeek;

  /// Called when the user chooses to navigate to the originating post.
  final VoidCallback? navigateToPost;

  /// The URL of the image to display.
  final String? url;

  @override
  State<ExperimentalImageViewer> createState() => _ExperimentalImageViewerState();
}

class _ExperimentalImageViewerState extends State<ExperimentalImageViewer> {
  static const double _fullscreenScaleThreshold = 1.2;

  bool _autoFullscreen = false;
  bool _downloaded = false;
  bool _isChromeVisible = true;
  bool _isDownloadingMedia = false;
  bool _isSavingMedia = false;
  bool _showAltText = false;

  double _maxScale = 4.0;

  Size? _imageSize;

  ThunderImageViewerSource get _source {
    if (widget.url != null) {
      return ThunderImageViewerSource.network(widget.url!);
    }

    return ThunderImageViewerSource.memory(widget.bytes!);
  }

  @override
  void initState() {
    super.initState();
    _isChromeVisible = !widget.isPeek;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadImageSize();
      _syncSystemUiMode();
    });
  }

  @override
  void dispose() {
    _restoreSystemUi();
    super.dispose();
  }

  Future<void> _loadImageSize() async {
    try {
      final decodedImage = await retrieveImageDimensions(imageUrl: widget.url, imageBytes: widget.bytes).timeout(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _imageSize = decodedImage;
        _maxScale = max(decodedImage.width, decodedImage.height) / 128;
        if (_maxScale < 3) _maxScale = 3;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _maxScale = 4.0);
    }
  }

  void _syncSystemUiMode() {
    if (widget.isPeek) return;

    if (_isChromeVisible) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: SystemUiOverlay.values);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  void _restoreSystemUi() {
    if (widget.isPeek) return;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: SystemUiOverlay.values);
  }

  void _setChromeVisible(bool value) {
    if (_isChromeVisible == value) return;

    setState(() => _isChromeVisible = value);
    _syncSystemUiMode();
  }

  void _enterFullscreen({bool auto = false}) {
    if (widget.isPeek) return;

    _autoFullscreen = auto;
    _setChromeVisible(false);
  }

  void _exitFullscreen() {
    if (widget.isPeek) return;

    _autoFullscreen = false;
    _setChromeVisible(true);
  }

  void _toggleFullscreen() {
    if (_isChromeVisible) {
      _enterFullscreen();
    } else {
      _exitFullscreen();
    }
  }

  void _handleViewerLongPress() {
    if (widget.isPeek) return;

    HapticFeedback.lightImpact();
    _toggleFullscreen();
  }

  void _handleViewerScaleChanged(double scale) {
    if (widget.isPeek) return;

    if (scale > _fullscreenScaleThreshold) {
      _enterFullscreen(auto: true);
      return;
    }

    if (_autoFullscreen) {
      _exitFullscreen();
    }
  }

  void _handleViewerTap() {
    if (widget.isPeek) return;

    if (_isChromeVisible) {
      _closeViewer();
    } else {
      _exitFullscreen();
    }
  }

  void _closeViewer() {
    _restoreSystemUi();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<File> _resolveMediaFile() async {
    final url = widget.url;

    if (url == null) {
      final bytes = widget.bytes!;
      final directory = await getTemporaryDirectory();
      final file = File(path.join(directory.path, 'thunder-image-${DateTime.now().millisecondsSinceEpoch}.png'));
      return file.writeAsBytes(bytes, flush: true);
    }

    final cachedFile = await DefaultCacheManager().getFileFromCache(url);
    if (cachedFile != null) return cachedFile.file;

    return DefaultCacheManager().getSingleFile(url);
  }

  Future<void> _shareImage() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      setState(() => _isDownloadingMedia = true);
      final file = await _resolveMediaFile();

      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
      ));
    } catch (e) {
      showSnackbar(l10n.errorDownloadingMedia(e));
    } finally {
      if (mounted) {
        setState(() => _isDownloadingMedia = false);
      }
    }
  }

  Future<void> _saveImage() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      setState(() => _isSavingMedia = true);
      final file = await _resolveMediaFile();

      if (!kIsWeb) {
        final hasPermission = await Gal.hasAccess(toAlbum: true);
        if (!hasPermission) {
          await Gal.requestAccess(toAlbum: true);
        }
      }

      if (!kIsWeb && Platform.isLinux) {
        final filePath = '${(await getApplicationDocumentsDirectory()).path}/Thunder/${path.basename(file.path)}';

        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.readAsBytesSync());

        if (!mounted) return;
        setState(() => _downloaded = true);
        return;
      }

      await Gal.putImage(file.path, album: 'Thunder');

      if (!mounted) return;
      setState(() => _downloaded = true);
    } on GalException catch (e) {
      if (mounted) {
        showSnackbar(e.type.message);
        setState(() => _downloaded = false);
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(l10n.errorDownloadingMedia(e));
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingMedia = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final overlayStyle = const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _restoreSystemUi();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Material(
          color: Colors.black,
          child: Stack(
            children: [
              Positioned.fill(
                child: ThunderImageViewer(
                  backgroundColor: Colors.black,
                  contentSize: _imageSize,
                  dismissible: !widget.isPeek,
                  maxScale: _maxScale,
                  onLongPress: widget.isPeek ? null : _handleViewerLongPress,
                  onDismiss: widget.isPeek ? null : _closeViewer,
                  onScaleChanged: widget.isPeek ? null : _handleViewerScaleChanged,
                  onTap: widget.isPeek ? null : _handleViewerTap,
                  semanticLabel: widget.altText,
                  source: _source,
                ),
              ),
              if (!widget.isPeek) ...[
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: SafeArea(
                    bottom: false,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _isChromeVisible ? 1 : 0,
                      child: IgnorePointer(
                        ignoring: !_isChromeVisible,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black54, Colors.transparent],
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _closeViewer,
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: _toggleFullscreen,
                                icon: Icon(
                                  Icons.fullscreen_rounded,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                tooltip: l10n.fullscreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    top: false,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _isChromeVisible ? 1 : 0,
                      child: IgnorePointer(
                        ignoring: !_isChromeVisible,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black54],
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (widget.url != null || widget.bytes != null)
                                IconButton(
                                  onPressed: _isDownloadingMedia ? null : _shareImage,
                                  tooltip: l10n.share,
                                  icon: _isDownloadingMedia
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                        )
                                      : Icon(Icons.share_rounded, color: Colors.white.withValues(alpha: 0.9)),
                                ),
                              if (!kIsWeb && (widget.url != null || widget.bytes != null))
                                IconButton(
                                  onPressed: (_downloaded || _isSavingMedia) ? null : _saveImage,
                                  tooltip: l10n.save,
                                  icon: _isSavingMedia
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                        )
                                      : _downloaded
                                          ? Icon(Icons.check_circle_rounded, color: Colors.white.withValues(alpha: 0.9))
                                          : Icon(Icons.download_rounded, color: Colors.white.withValues(alpha: 0.9)),
                                ),
                              if (widget.navigateToPost != null)
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    widget.navigateToPost?.call();
                                  },
                                  tooltip: l10n.comments,
                                  icon: Icon(Icons.chat_rounded, color: Colors.white.withValues(alpha: 0.9)),
                                ),
                              if (widget.altText?.isNotEmpty == true)
                                IconButton(
                                  onPressed: () => setState(() => _showAltText = !_showAltText),
                                  tooltip: l10n.altText,
                                  icon: Icon(
                                    Icons.text_fields_rounded,
                                    color: Colors.white.withValues(alpha: _showAltText ? 0.9 : 0.55),
                                  ),
                                ),
                              IconButton(
                                onPressed: _toggleFullscreen,
                                tooltip: l10n.fullscreen,
                                icon: Icon(Icons.fullscreen_rounded, color: Colors.white.withValues(alpha: 0.9)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_showAltText && widget.altText?.isNotEmpty == true)
                  Positioned(
                    bottom: kBottomNavigationBarHeight + 32,
                    left: 16,
                    right: 16,
                    child: SafeArea(
                      top: false,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: _isChromeVisible ? 1 : 0,
                        child: IgnorePointer(
                          ignoring: !_isChromeVisible,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                widget.altText!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.95),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!_isChromeVisible)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: IconButton(
                        onPressed: _exitFullscreen,
                        tooltip: l10n.fullscreen,
                        icon: Icon(
                          Icons.fullscreen_exit_rounded,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

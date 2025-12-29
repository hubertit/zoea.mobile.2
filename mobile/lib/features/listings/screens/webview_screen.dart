import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

/// A polished in-app webview screen similar to Instagram's browser experience
class WebViewScreen extends StatefulWidget {
  final String url;
  final String? title;

  const WebViewScreen({
    super.key,
    required this.url,
    this.title,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String? _currentTitle;
  bool _canGoBack = false;
  bool _canGoForward = false;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    // Debug: Print URL to verify it's correct
    debugPrint('WebViewScreen: Loading URL: ${widget.url}');
    _initializeWebView();
  }

  void _initializeWebView() {
    // Parse and validate URL
    Uri? uri;
    try {
      String urlToLoad = widget.url.trim();
      
      // The router already decodes query parameters, so use URL as-is
      // But ensure it's a valid URI
      uri = Uri.tryParse(urlToLoad);
      
      // If parsing failed, try adding https://
      if (uri == null || !uri.hasScheme) {
        if (!urlToLoad.startsWith('http://') && !urlToLoad.startsWith('https://')) {
          urlToLoad = 'https://$urlToLoad';
        }
        uri = Uri.parse(urlToLoad);
      }
      
      debugPrint('WebViewScreen: Loading URL: ${uri.toString()}');
    } catch (e) {
      debugPrint('WebViewScreen: Error parsing URL: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Invalid URL: ${widget.url}';
        });
      }
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1')
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading state based on progress
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
                _isLoading = progress < 100;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _errorMessage = null;
                _loadingProgress = 0;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _loadingProgress = 100;
              });
              // Get page title
              _controller.getTitle().then((title) {
                if (mounted) {
                  setState(() {
                    _currentTitle = title ?? widget.title ?? 'Loading...';
                  });
                }
              });
              // Check navigation state
              _controller.canGoBack().then((canGoBack) {
                if (mounted) {
                  setState(() {
                    _canGoBack = canGoBack;
                  });
                }
              });
              _controller.canGoForward().then((canGoForward) {
                if (mounted) {
                  setState(() {
                    _canGoForward = canGoForward;
                  });
                }
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
                final baseMessage = error.description ?? 'Failed to load page';
                _errorMessage = 'Error ${error.errorCode}: $baseMessage';
              });
            }
          },
          onHttpError: (HttpResponseError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
                _errorMessage = 'HTTP Error: ${error.response?.statusCode ?? 'Unknown'}';
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(uri);

    // Add timeout to detect if page is stuck loading
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isLoading && !_hasError) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Page is taking too long to load. Please check your internet connection.';
        });
      }
    });
  }

  void _reload() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isLoading = true;
    });
    _controller.reload();
  }

  void _goBack() {
    if (_canGoBack) {
      _controller.goBack();
    }
  }

  void _goForward() {
    if (_canGoForward) {
      _controller.goForward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentTitle ?? widget.title ?? 'Loading...',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_isLoading)
              SizedBox(
                height: 2,
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  backgroundColor: AppTheme.dividerColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  minHeight: 2,
                ),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Navigation buttons
          if (_canGoBack)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.primaryTextColor),
              onPressed: _goBack,
              tooltip: 'Go back',
            ),
          if (_canGoForward)
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: AppTheme.primaryTextColor),
              onPressed: _goForward,
              tooltip: 'Go forward',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryTextColor),
            onPressed: _reload,
            tooltip: 'Reload',
          ),
          // Open in external browser option
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.primaryTextColor),
            onSelected: (value) async {
              if (value == 'open_external') {
                // Get current URL and open in external browser
                final currentUrl = await _controller.currentUrl();
                final urlToOpen = currentUrl ?? widget.url;
                
                try {
                  final uri = Uri.parse(urlToOpen);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      AppTheme.errorSnackBar(
                        message: 'Could not open URL in external browser',
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    AppTheme.errorSnackBar(
                      message: 'Error opening browser: ${e.toString()}',
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'open_external',
                child: Row(
                  children: [
                    Icon(Icons.open_in_browser, size: 20),
                    SizedBox(width: 12),
                    Text('Open in Browser'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView
          WebViewWidget(controller: _controller),
          
          // Loading indicator overlay
          if (_isLoading && !_hasError)
            Container(
              color: AppTheme.backgroundColor,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Error state
          if (_hasError)
            Container(
              color: AppTheme.backgroundColor,
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.errorColor.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load page',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}


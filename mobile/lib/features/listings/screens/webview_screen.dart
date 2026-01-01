import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';

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
                // error.description is non-nullable, use it directly
                final baseMessage = error.description.isEmpty 
                    ? 'Failed to load page'
                    : error.description;
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
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentTitle ?? widget.title ?? 'Loading...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_isLoading)
              SizedBox(
                height: 2,
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  backgroundColor: context.dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(context.primaryColorTheme),
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
              icon: Icon(Icons.arrow_back, color: context.primaryTextColor),
              onPressed: _goBack,
              tooltip: 'Go back',
            ),
          if (_canGoForward)
            IconButton(
              icon: Icon(Icons.arrow_forward, color: context.primaryTextColor),
              onPressed: _goForward,
              tooltip: 'Go forward',
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: context.primaryTextColor),
            onPressed: _reload,
            tooltip: 'Reload',
          ),
          // Open in external browser option
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: context.primaryTextColor),
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
              color: context.backgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(context.primaryColorTheme),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: context.secondaryTextColor,
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
              color: context.backgroundColor,
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: context.errorColor.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load page',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColorTheme,
                        foregroundColor: context.primaryTextColor,
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


// lib/app/modules/home/views/google_map_webview.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:top5/app/modules/home/controllers/home_controller.dart';

class GoogleMapWebView extends StatefulWidget {
  final String googleApiKey;
  final double originLat; // Geolocator lat
  final double originLng; // Geolocator lng

  const GoogleMapWebView({
    required this.googleApiKey,
    required this.originLat,
    required this.originLng,
    super.key,
  });

  @override
  State<GoogleMapWebView> createState() => _GoogleMapWebViewState();
}

class _GoogleMapWebViewState extends State<GoogleMapWebView> {
  final controller = Get.find<HomeController>();

  late final WebViewController _web;
  final RxString _mapError = ''.obs;
  bool _mapReady = false;

  String _pinDataUrl = '';     // location_pointer.png as data URL
  String _fallbackImgUrl = ''; // restaurant.jpg as data URL (fallback)

  late Worker _placesSub; // listen for top5Places changes

  @override
  void initState() {
    super.initState();

    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'MapBridge',
        onMessageReceived: (msg) {
          try {
            final data = jsonDecode(msg.message) as Map<String, dynamic>;
            switch (data['type']) {
              case 'map_ready':
                _mapReady = true;
                _centerOn(widget.originLat, widget.originLng, zoom: 14);
                // push current markers (in case top5Places finished loading after WebView)
                _pushPlacesToWeb();
                break;
              case 'gm_authFailure':
                _mapError.value =
                'Google Maps auth failure (check key/billing/restrictions).';
                break;
              case 'gm_script_error':
              case 'map_init_error':
                _mapError.value =
                    (data['message'] ?? 'Map failed to load').toString();
                break;
            }
          } catch (_) {}
        },
      );

    _initWeb();

    // 🔔 When the list of places changes (e.g., category change), update markers & recenter
    _placesSub = ever(controller.top5Places, (_) {
      _pushPlacesToWeb();
      if (controller.top5Places.isNotEmpty) {
        final p = controller.top5Places.first;
        if (p.latitude != null && p.longitude != null) {
          _centerOn(p.latitude!, p.longitude!, zoom: 14);
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant GoogleMapWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.originLat != oldWidget.originLat ||
        widget.originLng != oldWidget.originLng) {
      _centerOn(widget.originLat, widget.originLng, zoom: 14);
    }
    // Ensure JS markers match current places (covers parent rebuilds)
    _pushPlacesToWeb();
  }

  @override
  void dispose() {
    _placesSub.dispose();
    super.dispose();
  }

  Future<void> _initWeb() async {
    // Convert your assets to data URLs so WebView JS can use them
    _pinDataUrl = await _assetToDataUrl(
      'assets/images/home/location_pointer.png',
      mime: 'image/png',
    ).catchError((_) => '');

    _fallbackImgUrl = await _assetToDataUrl(
      'assets/images/home/restaurant.jpg',
      mime: 'image/jpeg',
    ).catchError((_) => '');

    // Build initial HTML with whatever is currently in top5Places
    final html = _htmlTemplate(
      apiKey: widget.googleApiKey,
      originLat: widget.originLat,
      originLng: widget.originLng,
      places: controller.top5Places.map((p) {
        final raw = (p.thumbnail ?? '').trim();
        final isHttp = raw.startsWith('http://') || raw.startsWith('https://');
        return {
          'lat': p.latitude ?? 0.0,
          'lng': p.longitude ?? 0.0,
          'name': p.name ?? 'Unknown',
          'img': isHttp ? raw : '',
        };
      }).toList(),
      pinImgDataUrl: _pinDataUrl,
      fallbackImgDataUrl: _fallbackImgUrl,
    );

    _web.loadHtmlString(html);
  }

  Future<String> _assetToDataUrl(String assetPath, {required String mime}) async {
    final bytes = await rootBundle.load(assetPath);
    final b64 = base64Encode(bytes.buffer.asUint8List());
    return 'data:$mime;base64,$b64';
  }

  /// Recenter the JS map
  Future<void> _centerOn(double lat, double lng, {int? zoom}) async {
    if (!_mapReady) return;
    final z = zoom != null ? zoom.toString() : 'null';
    final js =
        'window._setCenter(${lat.toStringAsFixed(7)}, ${lng.toStringAsFixed(7)}, $z);';
    try {
      await _web.runJavaScript(js);
    } catch (_) {}
  }

  /// Push the current top5Places to the JS map (refresh markers)
  void _pushPlacesToWeb() {
    if (!_mapReady) return;
    final arr = controller.top5Places.map((p) {
      final raw = (p.thumbnail ?? '').trim();
      final isHttp = raw.startsWith('http://') || raw.startsWith('https://');
      final img = isHttp ? raw : '';
      return {
        'lat': p.latitude ?? 0.0,
        'lng': p.longitude ?? 0.0,
        'name': p.name ?? 'Unknown',
        'img': img,
      };
    }).toList();

    // Pass as a quoted JSON string (so we don't fight with quotes in HTML)
    final jsArg = jsonEncode(arr);
    final js = 'window._setPlaces(${jsonEncode(jsArg)});';
    _web.runJavaScript(js);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: WebViewWidget(controller: _web)),
        Obx(() {
          if (_mapError.isEmpty) return const SizedBox.shrink();
          return Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(12),
              child: Text(
                _mapError.value,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }),
      ],
    );
  }

  String _htmlTemplate({
    required String apiKey,
    required double originLat,
    required double originLng,
    required List<Map<String, dynamic>> places,
    required String pinImgDataUrl,
    required String fallbackImgDataUrl,
  }) {
    final placesJs = places.map((m) {
      final lat = (m['lat'] ?? 0.0).toString();
      final lng = (m['lng'] ?? 0.0).toString();
      final name = (m['name'] ?? 'Unknown').toString().replaceAll("'", "\\'");
      final img = (m['img'] ?? '').toString().replaceAll("'", "\\'");
      return "{lat:$lat, lng:$lng, name:'$name', img:'$img'}";
    }).join(',');

    return """
<!doctype html>
<html>
<head>
  <meta name="viewport" content="initial-scale=1, width=device-width, height=device-height, user-scalable=no">
  <style>
    html, body { margin:0; padding:0; height:100vh; width:100vw; }
    #map { height:100vh; width:100vw; }

    .pin {
      position: relative;
      width: 23px;     /* adjust size if needed */
      height: 56px;    /* adjust size if needed */
      background: url('${pinImgDataUrl}') no-repeat center center / contain;
      pointer-events: auto;
      display: grid;
      place-items: center;
      transform: translateZ(0);
    }
    .pin .num {
      color: #fff;
      font-weight: 600;
      font-size: 10px;
      line-height: 1;
      text-shadow: 0 1px 2px rgba(0,0,0,.35);
      user-select: none;
      -webkit-user-select: none;
      -webkit-touch-callout: none;
    }

    /* Green popup like your Flutter container (no white bg, no X) */
    .popup {
      position: absolute;
      transform: translate(-50%, -65%) translateY(-70px); /* ABOVE the pin */
      background: #00A896;
      border-radius: 8px;
      padding: 6px 8px;
      display: flex;
      flex-direction: column;
      align-items: center;
      color: #fff;
      font-family: system-ui, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      box-shadow: 0 2px 6px rgba(0,0,0,0.25);
      z-index: 10;
      pointer-events: auto;
    }
    .popup .title {
      font-size: 12px;
      font-weight: 600;
      margin-bottom: 6px;
      text-align: center;
      white-space: nowrap;
      max-width: 200px;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .popup img {
      width: 104px;
      height: 64px;
      border-radius: 6px;
      object-fit: cover;
      display: block;
      background: rgba(255,255,255,.12);
    }
  </style>
</head>
<body>
  <div id="map"></div>

  <script>
    function post(type, payload) {
      try { if (window.MapBridge && window.MapBridge.postMessage) {
        MapBridge.postMessage(JSON.stringify({ type, ...payload }));
      } } catch (_) {}
    }

    window.gm_authFailure = function() { post('gm_authFailure', {}); };
    function mapsScriptError(evt) {
      post('gm_script_error', { message: 'Failed to load Maps JS', detail: String(evt && evt.message || '') });
    }

    let map;
    const origin = {lat: ${originLat.toString()}, lng: ${originLng.toString()}};
    const places = [${placesJs}];
    const FALLBACK_IMG = '${fallbackImgDataUrl}';

    function buildPin(serial) {
      const el = document.createElement('div');
      el.className = 'pin';
      const label = document.createElement('span');
      label.className = 'num';
      label.textContent = String(serial);
      el.appendChild(label);
      return el;
    }

    // ----- Custom popup overlay (no InfoWindow) -----
    let popupOverlay = null;
    let popupDiv = null;
    let popupLatLng = null;

    function ensurePopup() {
      if (popupOverlay) return;

      popupOverlay = new google.maps.OverlayView();
      popupOverlay.onAdd = function() {
        popupDiv = document.createElement('div');
        // content filled on marker click
        this.getPanes().floatPane.appendChild(popupDiv);
      };
      popupOverlay.draw = function() {
        if (!popupDiv || !popupLatLng) return;
        const proj = this.getProjection();
        const pos = proj.fromLatLngToDivPixel(popupLatLng);
        if (!pos) return;
        popupDiv.style.left = pos.x + 'px';
        popupDiv.style.top  = pos.y + 'px';
      };
      popupOverlay.onRemove = function() {
        if (popupDiv && popupDiv.parentNode) popupDiv.parentNode.removeChild(popupDiv);
        popupDiv = null;
      };
      popupOverlay.setMap(map);

      // keep popup pinned during camera moves
      map.addListener('bounds_changed', () => popupOverlay.draw());
      window.addEventListener('resize', () => popupOverlay.draw());
    }

    function showPopup(lat, lng, name, imgUrl) {
      ensurePopup();
      popupLatLng = new google.maps.LatLng(lat, lng);
      const src = (imgUrl && imgUrl.length) ? imgUrl : FALLBACK_IMG;
      const safeName = name || 'Unknown';

      popupDiv.className = 'popup';
      popupDiv.innerHTML = \`
        <div class="title">\${safeName}</div>
        <img src="\${src}" onerror="this.src='${fallbackImgDataUrl}'" />
      \`;
      popupOverlay.draw();
    }

    function hidePopup() {
      if (popupDiv) {
        popupDiv.innerHTML = '';
        popupDiv.className = '';
      }
      popupLatLng = null;
    }
    // -----------------------------------------------

    // --- marker management (support dynamic updates) ---
    let advMarkers = [];

    function clearMarkers() {
      advMarkers.forEach(m => m.map = null);
      advMarkers = [];
    }

    function renderMarkers() {
      clearMarkers();
      places.forEach((p, i) => {
        const content = buildPin(i + 1);
        const marker = new google.maps.marker.AdvancedMarkerElement({
          map,
          position: { lat: p.lat, lng: p.lng },
          content,
          gmpClickable: true
        });
        marker.addListener('gmp-click', () => {
          showPopup(p.lat, p.lng, p.name, p.img);
        });
        advMarkers.push(marker);
      });
    }

    // Called from Flutter: center map (and optionally set zoom)
    window._setCenter = function(lat, lng, zoom) {
      try {
        if (!map) return;
        const p = new google.maps.LatLng(lat, lng);
        map.setCenter(p);
        if (typeof zoom === 'number' && isFinite(zoom)) map.setZoom(zoom);
      } catch (e) {}
    };

    // Called from Flutter: replace markers with a new list (stringified JSON)
    window._setPlaces = function(placesJsonStr) {
      try {
        const arr = JSON.parse(placesJsonStr);
        places.length = 0;
        arr.forEach(o => places.push(o));
        renderMarkers();
        // Optional: show popup for first marker after update
        // if (places.length) { const p = places[0]; showPopup(p.lat, p.lng, p.name, p.img); }
      } catch (e) { /* ignore */ }
    };

    function initMap() {
      try {
        map = new google.maps.Map(document.getElementById('map'), {
          center: origin,
          zoom: 14,
          disableDefaultUI: true,
          gestureHandling: 'greedy',
          mapId: 'DEMO_MAP'
        });

        // Initial render
        renderMarkers();

        // Hide popup when tapping on the map
        map.addListener('click', hidePopup);

        post('map_ready', {});
      } catch (e) {
        post('map_init_error', { message: String(e) });
      }
    }
  </script>

  <script async
          src="https://maps.googleapis.com/maps/api/js?key=${apiKey}&callback=initMap&v=beta&libraries=marker&loading=async"
          onerror="mapsScriptError(event)"></script>
</body>
</html>
""";
  }
}




class GoogleMapPickerWebView extends StatefulWidget {
  final String googleApiKey;
  final double initialLat;
  final double initialLng;
  final ValueChanged<LatLng> onCenterChanged; // fires when map settles (idle)

  const GoogleMapPickerWebView({
    super.key,
    required this.googleApiKey,
    required this.initialLat,
    required this.initialLng,
    required this.onCenterChanged,
  });

  @override
  State<GoogleMapPickerWebView> createState() => _GoogleMapPickerWebViewState();
}

class _GoogleMapPickerWebViewState extends State<GoogleMapPickerWebView> {
  late final WebViewController _web;

  // Small HTML with Google Maps JS; posts center lat/lng on 'idle'
  String _buildHtml() {
    final apiKey = widget.googleApiKey;
    // Note: keep the page ultra-light. We rely on Flutter overlay for the pin.
    return """
<!doctype html>
<html>
<head>
  <meta name="viewport" content="initial-scale=1, width=device-width, height=device-height, user-scalable=no">
  <style>
    html, body, #map { margin:0; padding:0; width:100%; height:100%; overflow:hidden; }
  </style>
  <script src="https://maps.googleapis.com/maps/api/js?key=$apiKey&v=quarterly"></script>
</head>
<body>
  <div id="map"></div>
  <script>
    const initLat = ${widget.initialLat};
    const initLng = ${widget.initialLng};
    let map;

    function init() {
      map = new google.maps.Map(document.getElementById('map'), {
        center: {lat: initLat, lng: initLng},
        zoom: 15,
        disableDefaultUI: true,
        clickableIcons: false,
        gestureHandling: 'greedy',
      });

      // When user stops dragging/zooming, send center back to Flutter
      map.addListener('idle', () => {
        const c = map.getCenter();
        const payload = JSON.stringify({ lat: c.lat(), lng: c.lng() });
        if (window.FlutterChannel && window.FlutterChannel.postMessage) {
          window.FlutterChannel.postMessage(payload);
        }
      });
    }
    window.onload = init;
  </script>
</body>
</html>
""";
  }

  @override
  void initState() {
    super.initState();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (msg) {
          try {
            final m = jsonDecode(msg.message) as Map<String, dynamic>;
            final lat = (m['lat'] as num).toDouble();
            final lng = (m['lng'] as num).toDouble();
            widget.onCenterChanged(LatLng(lat, lng));
          } catch (_) {}
        },
      )
      ..loadHtmlString(_buildHtml());
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _web);
  }
}

// Tiny LatLng helper to avoid importing external packages here
class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);
}

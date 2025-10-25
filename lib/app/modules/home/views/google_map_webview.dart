// lib/app/modules/home/views/google_map_webview.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:top5/app/data/model/top_5_place_list.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleMapWebView extends StatefulWidget {
  final String googleApiKey;
  final double originLat; // Center lat
  final double originLng; // Center lng
  final List<Places> places; // List of places to display
  final List<int> originalIndices; // NEW: Original indices of places in the source list
  // Optionally exclude one marker (the current place) by its lat/lng
  final double? excludeLat;
  final double? excludeLng;

  const GoogleMapWebView({
    required this.googleApiKey,
    required this.originLat,
    required this.originLng,
    required this.places,
    required this.originalIndices, // NEW
    this.excludeLat,
    this.excludeLng,
    super.key,
  });

  @override
  State<GoogleMapWebView> createState() => _GoogleMapWebViewState();
}

class _GoogleMapWebViewState extends State<GoogleMapWebView> {
  late final WebViewController _web;
  final RxString _mapError = ''.obs;
  bool _mapReady = false;

  String _pinDataUrl = ''; // location_pointer.png as data URL
  String _fallbackImgUrl = ''; // restaurant.jpg as data URL (fallback)

  static const double _eps = 1e-6; // equality tolerance for lat/lng

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
                _pushPlacesToWeb();
                break;
              case 'gm_authFailure':
                _mapError.value = 'Google Maps auth failure (check key/billing/restrictions).';
                break;
              case 'gm_script_error':
              case 'map_init_error':
                _mapError.value = (data['message'] ?? 'Map failed to load').toString();
                break;
            }
          } catch (_) {}
        },
      );

    _initWeb();
  }

  @override
  void didUpdateWidget(covariant GoogleMapWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.originLat != oldWidget.originLat ||
        widget.originLng != oldWidget.originLng ||
        widget.places != oldWidget.places ||
        widget.originalIndices != oldWidget.originalIndices) { // NEW: Check for indices change
      _centerOn(widget.originLat, widget.originLng, zoom: 14);
      _pushPlacesToWeb();
    }
  }

  @override
  void dispose() {
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

    // Build initial HTML with filtered places and original serial numbers
    final html = _htmlTemplate(
      apiKey: widget.googleApiKey,
      originLat: widget.originLat,
      originLng: widget.originLng,
      places: _filteredPlaces().asMap().entries.map((entry) {
        final i = entry.key;
        final p = entry.value;
        final raw = (p.thumbnail ?? '').trim();
        final isHttp = raw.startsWith('http://') || raw.startsWith('https://');
        return {
          'lat': p.latitude ?? 0.0,
          'lng': p.longitude ?? 0.0,
          'name': p.name ?? 'Unknown',
          'img': isHttp ? raw : '',
          'serial': widget.originalIndices[i], // NEW: Use original index
        };
      }).toList(),
      pinImgDataUrl: _pinDataUrl,
      fallbackImgDataUrl: _fallbackImgUrl,
    );

    _web.loadHtmlString(html);
  }

  List<Places> _filteredPlaces() {
    final exLat = widget.excludeLat;
    final exLng = widget.excludeLng;
    if (exLat == null || exLng == null) {
      return widget.places;
    }
    return widget.places.asMap().entries.where((entry) {
      final p = entry.value;
      final lat = p.latitude;
      final lng = p.longitude;
      if (lat == null || lng == null) return true;
      final sameLat = (lat - exLat).abs() < _eps;
      final sameLng = (lng - exLng).abs() < _eps;
      // Exclude if both lat & lng match within tolerance
      return !(sameLat && sameLng);
    }).map((entry) => entry.value).toList();
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
    final js = 'window._setCenter(${lat.toStringAsFixed(7)}, ${lng.toStringAsFixed(7)}, $z);';
    try {
      await _web.runJavaScript(js);
    } catch (_) {}
  }

  /// Push the (filtered) places to the JS map (refresh markers)
  void _pushPlacesToWeb() {
    if (!_mapReady) return;
    final arr = _filteredPlaces().asMap().entries.map((entry) {
      final i = entry.key;
      final p = entry.value;
      final raw = (p.thumbnail ?? '').trim();
      final isHttp = raw.startsWith('http://') || raw.startsWith('https://');
      final img = isHttp ? raw : '';
      return {
        'lat': p.latitude ?? 0.0,
        'lng': p.longitude ?? 0.0,
        'name': p.name ?? 'Unknown',
        'img': img,
        'serial': widget.originalIndices[i], // NEW: Use original index
      };
    }).toList();

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
      final serial = (m['serial'] ?? 0).toString();
      return "{lat:$lat, lng:$lng, name:'$name', img:'$img', serial:$serial}";
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
      width: 23px;
      height: 56px;
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

    .popup {
      position: absolute;
      transform: translate(-50%, -65%) translateY(-70px);
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
      background: rgba(255 Ascending
      .popup {
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
      places.forEach((p) => {
        const content = buildPin(p.serial); // use provided serial number
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

        renderMarkers();
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

  String _buildHtml() {
    final apiKey = widget.googleApiKey;
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

/// Directions map with:
/// - USER (origin) as circular blue dot (Google Maps style)
/// - DESTINATION as your green pin (no labels)
/// - NEW: Popup above destination pin with name + image (on pin tap only)
class DirectionsMapWebView extends StatefulWidget {
  final String googleApiKey;
  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;
  final String travelMode; // DRIVING, WALKING, BICYCLING, TRANSIT
  final String? mapId;     // Vector Map ID enables Advanced Markers

  /// NEW (optional): data for the destination popup
  final String? destName;
  final String? destImgUrl;

  const DirectionsMapWebView({
    super.key,
    required this.googleApiKey,
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    this.travelMode = 'WALKING',
    this.mapId,
    this.destName,     // NEW
    this.destImgUrl,   // NEW
  });

  @override
  State<DirectionsMapWebView> createState() => _DirectionsMapWebViewState();
}

class _DirectionsMapWebViewState extends State<DirectionsMapWebView> {
  late final WebViewController _web;
  String _pinDataUrl = '';

  @override
  void initState() {
    super.initState();
    _web = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadAndRender();
  }

  Future<void> _loadAndRender() async {
    // Your green pin (destination) image as data URL
    _pinDataUrl = await _assetToDataUrl(
      'assets/images/home/location_pointer.png',
      mime: 'image/png',
    ).catchError((_) => '');
    _web.loadHtmlString(_buildHtml());
  }

  Future<String> _assetToDataUrl(String assetPath, {required String mime}) async {
    final bytes = await rootBundle.load(assetPath);
    final b64 = base64Encode(bytes.buffer.asUint8List());
    return 'data:$mime;base64,$b64';
  }

  String _buildHtml() {
    final apiKey = widget.googleApiKey;
    final oLat = widget.originLat.toStringAsFixed(7);
    final oLng = widget.originLng.toStringAsFixed(7);
    final dLat = widget.destLat.toStringAsFixed(7);
    final dLng = widget.destLng.toStringAsFixed(7);
    final mode = widget.travelMode;
    final mapId = (widget.mapId ?? '').trim();
    final pinImg = _pinDataUrl;

    // NEW: destination display fields for popup
    final destName = (widget.destName ?? 'Destination')
        .replaceAll("'", "\\'")
        .replaceAll('\n', ' ');
    final destImgUrl = (widget.destImgUrl ?? '').replaceAll("'", "\\'");

    // Force classic markers if there is no Map ID
    final forceClassic = mapId.isEmpty ? 'true' : 'false';

    // Blue-dot SVG for classic Marker fallback (URL-encoded colors)
    const blueDotSvg =
        'data:image/svg+xml;utf8,'
        '<svg xmlns="http://www.w3.org/2000/svg" width="35" height="35">'
        '<circle cx="20" cy="20" r="12" fill="%23006AFF"/>'
        '<circle cx="20" cy="20" r="15" fill="none" stroke="%23FFFFFF" stroke-width="2"/>'
        '</svg>';

    return """
<!doctype html>
<html>
<head>
  <meta name="viewport" content="initial-scale=1, width=device-width, height=device-height, user-scalable=no">
  <style>
    html, body, #map { margin:0; padding:0; width:100%; height:100%; overflow:hidden; }

    /* Destination green pin (no label) */
    .pin {
      position: relative;
      width: 23px;
      height: 56px;
      background: url('$pinImg') no-repeat center center / contain;
      pointer-events: auto;
      display: grid;
      place-items: center;
      transform: translateZ(0);
    }

    /* User circular blue dot (Advanced Marker content) */
    .user-dot {
      width: 16px;
      height: 16px;
      border-radius: 50%;
      background: #006AFF;                /* blue fill */
      box-shadow: 0 0 0 2px #fff;         /* white ring */
      position: relative;
    }
    .user-dot::after {
      content: '';
      position: absolute;
      left: 50%; top: 50%;
      transform: translate(-50%, -50%);
      width: 16px; height: 16px;
      border-radius: 50%;
      box-shadow: 0 0 12px rgba(0,106,255,.6);
    }

    #warn {
      position:absolute; top:8px; left:8px; right:8px; padding:8px 10px;
      background:rgba(255,230,0,.95); color:#000; font-family:sans-serif;
      font-size:12px; border-radius:8px; display:none; z-index:5;
    }

    /* NEW: popup styling (same spirit as your first map) */
    .popup {
      position: absolute;
      transform: translate(-50%, -65%) translateY(-70px); /* above the pin tip */
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
  <script>
    window.gm_authFailure = () => {
      const w = document.getElementById('warn');
      if (w) { w.textContent = "Google Maps auth failed. Check API key/billing/restrictions."; w.style.display = 'block'; }
    };
    function mapsScriptError() {
      const w = document.getElementById('warn');
      if (w) { w.textContent = "Failed to load Maps JS (network or key)."; w.style.display = 'block'; }
    }
    window.__forceClassic = $forceClassic;
  </script>
</head>
<body>
  <div id="warn"></div>
  <div id="map"></div>

  <script>
    let map, renderer, service;
    let userMarker = null, destMarker = null;

    // ===== NEW: popup overlay bits (destination only) =====
    let popupOverlay = null;
    let popupDiv = null;
    let popupLatLng = null;

    function ensurePopup() {
      if (popupOverlay) return;

      popupOverlay = new google.maps.OverlayView();
      popupOverlay.onAdd = function() {
        popupDiv = document.createElement('div');
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

      map.addListener('bounds_changed', () => popupOverlay.draw());
      window.addEventListener('resize', () => popupOverlay.draw());
    }

    function showPopup(lat, lng, name, imgUrl) {
      ensurePopup();
      popupLatLng = new google.maps.LatLng(lat, lng);

      const safeName = name && name.length ? name : 'Destination';
      const src = (imgUrl && imgUrl.length) ? imgUrl : '$pinImg'; // lightweight fallback

      popupDiv.className = 'popup';
      popupDiv.innerHTML = `
        <div class="title">\${safeName}</div>
        <img src="\${src}" onerror="this.src='${pinImg}'" />
      `;
      popupOverlay.draw();
}

    function hidePopup() {
      if (popupDiv) {
        popupDiv.innerHTML = '';
        popupDiv.className = '';
      }
      popupLatLng = null;
    }
    // =====================================================

    function buildUserDot() {
      const el = document.createElement('div');
      el.className = 'user-dot';
      return el;
    }
    function buildPin() {
      const el = document.createElement('div');
      el.className = 'pin';
      return el;
    }

    function createUserMarker(position) {
      if (window.__forceClassic) {
        return new google.maps.Marker({
          map, position,
          icon: {
            url: '$blueDotSvg',
            scaledSize: new google.maps.Size(20, 20),
            anchor: new google.maps.Point(10, 10) // center
          },
          zIndex: 200
        });
      }
      try {
        if (google.maps.marker && google.maps.marker.AdvancedMarkerElement) {
          return new google.maps.marker.AdvancedMarkerElement({
            map, position, content: buildUserDot(), gmpClickable: false, zIndex: 200
          });
        }
      } catch (_) {}
      return new google.maps.Marker({
        map, position,
        icon: {
          url: '$blueDotSvg',
          scaledSize: new google.maps.Size(20, 20),
          anchor: new google.maps.Point(10, 10)
        },
        zIndex: 200
      });
    }

    function createDestinationMarker(position) {
  const name = '$destName';
  const img  = '$destImgUrl';

  // helper for click handler (optional if you still want to reopen it)
  function attachClickHandlersForClassic(marker) {
    google.maps.event.addListener(marker, 'click', () => {
      showPopup(position.lat(), position.lng(), name, img);
    });
  }
  function attachClickHandlersForAdvanced(marker) {
    marker.addListener('gmp-click', () => {
      showPopup(position.lat(), position.lng(), name, img);
    });
  }

  let m;
  if (window.__forceClassic) {
    m = new google.maps.Marker({
      map, position,
      icon: {
        url: '${pinImg}',
        scaledSize: new google.maps.Size(23, 56),
        anchor: new google.maps.Point(11, 56) // bottom-center
      },
      zIndex: 201
    });
    attachClickHandlersForClassic(m);
  } else {
    try {
      if (google.maps.marker && google.maps.marker.AdvancedMarkerElement) {
        m = new google.maps.marker.AdvancedMarkerElement({
          map, position, content: buildPin(), gmpClickable: true, zIndex: 201
        });
        attachClickHandlersForAdvanced(m);
      }
    } catch (_) {}
    if (!m) {
      m = new google.maps.Marker({
        map, position,
        icon: {
          url: '${pinImg}',
          scaledSize: new google.maps.Size(23, 56),
          anchor: new google.maps.Point(11, 56)
        },
        zIndex: 201
      });
      attachClickHandlersForClassic(m);
    }
  }

  // ✅ NEW: show popup immediately (always visible)
  // showPopup(position.lat(), position.lng(), name, img);

  return m;
}

    function placeMarkers(startLatLng, endLatLng) {
      if (userMarker) userMarker.map = null;
      if (destMarker) destMarker.map = null;
      userMarker = createUserMarker(startLatLng);
      destMarker = createDestinationMarker(endLatLng);
    }

    function init() {
      const mapOpts = {
        center: {lat: $oLat, lng: $oLng},
        zoom: 14,
        disableDefaultUI: true,
        gestureHandling: 'greedy',
      };
      ${mapId.isNotEmpty ? "mapOpts.mapId = '${mapId}';" : ""}

      map = new google.maps.Map(document.getElementById('map'), mapOpts);

      // hide popup when tapping the map (only pin opens it)
      map.addListener('click', hidePopup);

      renderer = new google.maps.DirectionsRenderer({
        map,
        suppressMarkers: true
      });
      service = new google.maps.DirectionsService();

      const req = {
        origin: {lat: $oLat, lng: $oLng},
        destination: {lat: $dLat, lng: $dLng},
        travelMode: google.maps.TravelMode['$mode']
      };

      service.route(req).then(res => {
        renderer.setDirections(res);
        const route = res.routes && res.routes[0];
        if (route && route.legs && route.legs.length) {
          const leg = route.legs[0];
          placeMarkers(leg.start_location, leg.end_location);
          if (route.bounds) map.fitBounds(route.bounds);
        }
      }).catch(err => {
        const url = 'https://www.google.com/maps/dir/?api=1'
          + '&origin=$oLat,$oLng'
          + '&destination=$dLat,$dLng'
          + '&travelmode=${mode.toLowerCase()}';
        window.location.href = url;
      });
    }
    window.init = init;
  </script>

  <!-- marker lib + callback -->
  <script async
          src="https://maps.googleapis.com/maps/api/js?key=$apiKey&v=beta&libraries=marker&callback=init&loading=async"
          onerror="mapsScriptError()"></script>
</body>
</html>
""";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Directions')),
      body: WebViewWidget(controller: _web),
    );
  }
}

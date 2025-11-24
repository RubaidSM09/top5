// lib/app/modules/home/views/google_map_webview.dart
import 'dart:convert';
import 'dart:math' as math;
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
  final List<int> originalIndices; // Original indices of places in the source list
  // Optionally exclude one marker (the current place) by its lat/lng
  final double? excludeLat;
  final double? excludeLng;

  const GoogleMapWebView({
    required this.googleApiKey,
    required this.originLat,
    required this.originLng,
    required this.places,
    required this.originalIndices,
    this.excludeLat,
    this.excludeLng,
    super.key,
  });

  @override
  State<GoogleMapWebView> createState() => _GoogleMapWebViewState();
}

class _GoogleMapWebViewState extends State<GoogleMapWebView> {
  late String _staticMapUrl;

  static const double _eps = 1e-6; // equality tolerance for lat/lng

  @override
  void initState() {
    super.initState();
    _staticMapUrl = _buildStaticMapUrl();
  }

  @override
  void didUpdateWidget(covariant GoogleMapWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.originLat != oldWidget.originLat ||
        widget.originLng != oldWidget.originLng ||
        widget.places != oldWidget.places ||
        widget.originalIndices != oldWidget.originalIndices ||
        widget.excludeLat != oldWidget.excludeLat ||
        widget.excludeLng != oldWidget.excludeLng) {
      _staticMapUrl = _buildStaticMapUrl();
    }
  }

  /// Filter out the excluded place (for Details screen use-case)
  List<Places> _filteredPlaces() {
    final exLat = widget.excludeLat;
    final exLng = widget.excludeLng;
    if (exLat == null || exLng == null) {
      return widget.places;
    }
    return widget.places.where((p) {
      final lat = p.latitude;
      final lng = p.longitude;
      if (lat == null || lng == null) return true;
      final sameLat = (lat - exLat).abs() < _eps;
      final sameLng = (lng - exLng).abs() < _eps;
      // Exclude if both lat & lng match within tolerance
      return !(sameLat && sameLng);
    }).toList();
  }

  /// Build a Google Static Maps URL with numbered markers.
  String _buildStaticMapUrl() {
    const size = '600x360'; // width x height in px
    const scale = 2; // higher scale = sharper on high DPI

    final places = _filteredPlaces();

    // 🔹 compute maximum distance (km) from center to any place
    double maxDistanceKm = 0;
    for (final p in places) {
      final lat = p.latitude;
      final lng = p.longitude;
      if (lat == null || lng == null) continue;
      final d = _haversineKm(widget.originLat, widget.originLng, lat, lng);
      if (d > maxDistanceKm) maxDistanceKm = d;
    }

    // 🔹 choose zoom based on that max distance
    final int zoom = places.isEmpty ? 14 : _zoomFromMaxDistanceKm(maxDistanceKm);

    final buffer = StringBuffer('https://maps.googleapis.com/maps/api/staticmap');

    buffer.write('?key=${widget.googleApiKey}');
    buffer.write('&center=${widget.originLat},${widget.originLng}');
    buffer.write('&zoom=$zoom');
    buffer.write('&size=$size');
    buffer.write('&scale=$scale');
    buffer.write('&maptype=roadmap');

    // Add markers with numeric labels 1..5 (from originalIndices)
    for (int i = 0; i < places.length && i < widget.originalIndices.length; i++) {
      final p = places[i];
      final lat = p.latitude;
      final lng = p.longitude;
      if (lat == null || lng == null) continue;

      // Static Maps label must be a single alphanumeric character.
      // Since your list is Top 5, serials 1-5 are fine.
      final labelInt = widget.originalIndices[i];
      final label = labelInt.toString(); // "1".."5"

      buffer.write(
        '&markers=color:0x00A896FF|label:$label|${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}',
      );
    }

    return buffer.toString();
  }

  /// Haversine distance in km
  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * math.pi / 180.0;

  /// Rough mapping distance (km) → zoom so all markers are on-screen
  int _zoomFromMaxDistanceKm(double d) {
    // small buffer so markers are not at the very edge
    d = d * 3;

    if (d <= 0.3) return 17; // very close — street level
    if (d <= 0.6) return 16;
    if (d <= 1.2) return 15;
    if (d <= 2.5) return 14;
    if (d <= 5) return 13;
    if (d <= 10) return 12;
    if (d <= 20) return 11;
    if (d <= 40) return 10;
    if (d <= 80) return 9;
    return 8; // very spread out — city/region level
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8), // optional, to look nicer
      child: Image.network(
        _staticMapUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const Text(
              'Map failed to load',
              style: TextStyle(color: Colors.black54),
            ),
          );
        },
      ),
    );
  }
}

class GoogleMapPickerWebView extends StatefulWidget {
  final String googleApiKey;
  final double initialLat;
  final double initialLng;

  /// Fired on map idle/center change with latest center.
  final ValueChanged<LatLng> onCenterChanged;

  /// NEW: Fired along with center changes when a human-readable address is available.
  final ValueChanged<String>? onAddressResolved;

  /// NEW: When this value changes (non-null), the webview geocodes the address
  /// and recenters the map there. You can keep passing null when not searching.
  final String? searchAddress;

  const GoogleMapPickerWebView({
    super.key,
    required this.googleApiKey,
    required this.initialLat,
    required this.initialLng,
    required this.onCenterChanged,
    this.onAddressResolved,
    this.searchAddress,
  });

  @override
  State<GoogleMapPickerWebView> createState() => _GoogleMapPickerWebViewState();
}

class _GoogleMapPickerWebViewState extends State<GoogleMapPickerWebView> {
  late final WebViewController _web;

  String _buildHtml() {
    final apiKey = widget.googleApiKey;
    // Load the JS API with Geocoding support (core maps is enough; Geocoder is included)
    // For Places Autocomplete you would add &libraries=places, but here we geocode free-text.
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
    let geocoder;

    function postToFlutter(payload) {
      try {
        if (window.FlutterChannel && window.FlutterChannel.postMessage) {
          window.FlutterChannel.postMessage(JSON.stringify(payload));
        }
      } catch (_) {}
    }

    function init() {
      geocoder = new google.maps.Geocoder();
      map = new google.maps.Map(document.getElementById('map'), {
        center: {lat: initLat, lng: initLng},
        zoom: 15,
        disableDefaultUI: true,
        clickableIcons: false,
        gestureHandling: 'greedy',
      });

      // Reverse geocode on idle (when user stops panning/zooming)
      map.addListener('idle', () => {
        const c = map.getCenter();
        const lat = c.lat(), lng = c.lng();
        // Reverse geocode center and send address + coords back to Flutter
        geocoder.geocode({ location: { lat, lng } }, (results, status) => {
          let addr = '';
          if (status === 'OK' && results && results.length) {
            addr = results[0].formatted_address || '';
          }
          postToFlutter({ lat, lng, address: addr });
        });
      });
    }

    // Called by Flutter when user submits a search string
    window._geocodeAddress = function(q) {
      if (!q || !q.length) return;
      try {
        geocoder.geocode({ address: q }, (results, status) => {
          if (status === 'OK' && results && results.length) {
            const r = results[0];
            const loc = r.geometry.location;
            const lat = loc.lat(), lng = loc.lng();
            const addr = r.formatted_address || q;
            map.setCenter({ lat, lng });
            // push resolved address to Flutter too
            postToFlutter({ lat, lng, address: addr });
          } else {
            // still notify with empty address but same center (no jump)
            const c = map.getCenter();
            postToFlutter({ lat: c.lat(), lng: c.lng(), address: '' });
          }
        });
      } catch (e) {
        const c = map.getCenter();
        postToFlutter({ lat: c.lat(), lng: c.lng(), address: '' });
      }
    };

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
            final addr = (m['address'] ?? '').toString();
            widget.onCenterChanged(LatLng(lat, lng));
            if (widget.onAddressResolved != null) {
              widget.onAddressResolved!(addr);
            }
          } catch (_) {}
        },
      )
      ..loadHtmlString(_buildHtml());
  }

  /// When parent provides a new searchAddress, forward-geocode inside the webview.
  @override
  void didUpdateWidget(covariant GoogleMapPickerWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.searchAddress ?? '') != (oldWidget.searchAddress ?? '') &&
        (widget.searchAddress ?? '').isNotEmpty) {
      final q = jsonEncode(widget.searchAddress);
      _web.runJavaScript("window._geocodeAddress($q);");
    }
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

import 'dart:html';
import 'dart:async';
import 'dart:js' as js;
import '../infrastructure/apps_script_service.dart';
import '../core/location_manager.dart';

class GeoVerificationRenderer {
  static final GeoVerificationRenderer _instance = GeoVerificationRenderer._internal();
  dynamic map;
  dynamic targetMarker;
  Timer? debounceTimer;
  final appsScriptService = AppsScriptService();
  double currentDeviceLat = 28.52785;
  double currentDeviceLng = 76.08361;
  bool isAddressModified = false;

  GeoVerificationRenderer._internal() {
    final loc = LocationManager().data;
    if (loc.lat != null) currentDeviceLat = loc.lat!;
    if (loc.lon != null) currentDeviceLng = loc.lon!;
  }

  factory GeoVerificationRenderer() {
    return _instance;
  }

  void renderPopup() {
    var modal = document.getElementById('antinna-geo-modal');
    if (modal == null) {
      modal = DivElement()
        ..id = 'antinna-geo-modal'
        ..className = 'antinna-geo-backdrop';

      modal.setInnerHtml('''
        <div class="antinna-geo-content">
          <div class="antinna-geo-header">
            <h3>Destination Verification</h3>
            <button class="antinna-geo-close" id="antinna-geo-modal-close">&times;</button>
          </div>
          <p class="antinna-geo-subtitle">
            Type to search, choose from suggestions, <b>OR click directly on the map</b> to drop a custom pinpoint marker.
          </p>

          <div class="antinna-geo-search-container">
            <input id="antinna-geo-search" type="text" placeholder="Start typing address..." autocomplete="off">
            <div id="antinna-geo-dropdown" class="antinna-geo-dropdown" style="display:none; position:absolute; background:#fff; border:1px solid #ccc; z-index:1000; width:100%; max-height:200px; overflow-y:auto;"></div>
          </div>

          <div id="antinna-geo-status" class="antinna-geo-status">Detecting position...</div>

          <div id="antinna-geo-map-canvas" style="height:250px; margin-top:15px; border-radius:10px;"></div>

          <div id="antinna-geo-metrics" class="antinna-geo-metrics" style="display: none; margin-top:15px; padding:10px; background:#f9f9f9; border-radius:8px;">
            <strong>Target Location Context:</strong><br>
            <span id="antinna-geo-clean-address" style="font-weight: 600;"></span><br>

            <div style="margin-top:10px; display:grid; grid-template-columns: 1fr 1fr; gap:10px;">
              <div>📍 Target: <span class="antinna-geo-tag" id="antinna-geo-tag-target">0.0, 0.0</span></div>
              <div>📱 Current: <span class="antinna-geo-tag" id="antinna-geo-tag-current">0.0, 0.0</span></div>
            </div>
            <div style="margin-top:8px; font-weight:700; color:var(--accent);">
              Distance: <span id="antinna-geo-dist">--</span> | Duration: <span id="antinna-geo-dur">--</span>
            </div>
          </div>

          <div id="antinna-geo-address-form" style="display:none; margin-top:15px; border-top: 1px solid #eee; padding-top:15px;">
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:10px;">
              <div class="v-group">
                <span class="v-label">Flat/Plot/Building</span>
                <input id="geo-extendedAddress" class="antinna-geo-input" placeholder="e.g. 3rd Floor, Plot 42"/>
              </div>
              <div class="v-group">
                <span class="v-label">Street/Sector</span>
                <input id="geo-streetAddress" class="antinna-geo-input" placeholder="e.g. Sector 14"/>
              </div>
            </div>
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap:10px; margin-top:10px;">
              <div class="v-group">
                <span class="v-label">City</span>
                <input id="geo-locality" class="antinna-geo-input" readonly style="background:#f8f9fa;"/>
              </div>
              <div class="v-group">
                <span class="v-label">Postal Code</span>
                <input id="geo-postalCode" class="antinna-geo-input" placeholder="6-digit PIN"/>
              </div>
            </div>
          </div>

          <button id="antinna-geo-finalize-btn" class="v-btn active" style="width:100%; margin-top:20px; display:none; align-items:center; justify-content:center; gap:10px;">
            <span class="btn-text">Finalize Order</span>
          </button>
        </div>
      ''', treeSanitizer: NodeTreeSanitizer.trusted);

      document.body?.append(modal);
      setupListeners();
    }

    modal.classes.add('active');
    initMap();
  }

  void setupListeners() {
    final input = document.getElementById('antinna-geo-search') as InputElement?;
    input?.onInput.listen((e) {
      handleTypeAhead(input.value ?? '');
    });

    final closeBtn = document.getElementById('antinna-geo-modal-close');
    closeBtn?.onClick.listen((_) {
      document.getElementById('antinna-geo-modal')?.classes.remove('active');
    });

    final formInputs = ['geo-extendedAddress', 'geo-streetAddress', 'geo-postalCode'];
    for (var id in formInputs) {
      final el = document.getElementById(id);
      el?.onInput.listen((_) {
        if (id != 'geo-postalCode') isAddressModified = true;
        validateAddressForm();
      });
    }

    document.onClick.listen((e) {
      final dropdown = document.getElementById('antinna-geo-dropdown');
      if (dropdown != null && e.target != input) {
        dropdown.style.display = 'none';
      }
    });

    final finalizeBtn = document.getElementById('antinna-geo-finalize-btn');
    finalizeBtn?.onClick.listen((_) async {
      final btnText = finalizeBtn.querySelector('.btn-text');
      if (btnText != null) btnText.text = 'Processing...';

      await Future.delayed(const Duration(milliseconds: 800));

      final deliveryData = collectDeliveryData();
      if (js.context['AntinnaEngine'] != null) {
        js.context['AntinnaEngine'].callMethod('setOrderDelivery', [js.JsObject.jsify(deliveryData)]);
        js.context['AntinnaEngine'].callMethod('showOrderSummary');
      }

      if (btnText != null) btnText.text = 'Finalize Order';
    });
  }

  void validateAddressForm() {
    final extended = (document.getElementById('geo-extendedAddress') as InputElement?)?.value?.trim() ?? '';
    final street = (document.getElementById('geo-streetAddress') as InputElement?)?.value?.trim() ?? '';
    final pin = (document.getElementById('geo-postalCode') as InputElement?)?.value?.trim() ?? '';

    final finalizeBtn = document.getElementById('antinna-geo-finalize-btn');
    if (finalizeBtn != null) {
      final isValid = extended.isNotEmpty && street.isNotEmpty && pin.isNotEmpty && pin.length >= 6;
      finalizeBtn.style.display = isValid ? 'flex' : 'none';
    }
  }

  Map<String, dynamic> collectDeliveryData() {
    var lat = currentDeviceLat;
    var lng = currentDeviceLng;

    if (targetMarker != null) {
      final pos = (targetMarker as js.JsObject).callMethod('getLatLng');
      lat = double.tryParse(pos['lat'].toString()) ?? lat;
      lng = double.tryParse(pos['lng'].toString()) ?? lng;
    }

    final response = js.context['lastGeoResponse'] as js.JsObject?;
    final addressDetails = response != null ? response['addressDetails'] : null;
    final region = addressDetails != null ? addressDetails['addressRegion']?.toString() : 'HR';

    return {
      '@type': 'ParcelDelivery',
      'deliveryName': 'Standard Handheld Delivery',
      'deliveryAddress': {
        '@type': 'PostalAddress',
        'extendedAddress': (document.getElementById('geo-extendedAddress') as InputElement?)?.value ?? '',
        'streetAddress': (document.getElementById('geo-streetAddress') as InputElement?)?.value ?? '',
        'addressLocality': (document.getElementById('geo-locality') as InputElement?)?.value ?? '',
        'addressRegion': region ?? 'HR',
        'postalCode': (document.getElementById('geo-postalCode') as InputElement?)?.value ?? '',
        'addressCountry': 'IN'
      },
      'deliveryStatus': {
        '@type': 'DeliveryEvent',
        'name': 'Final Destination Drop-off',
        'location': {
          '@type': 'Place',
          'name': 'Exact Delivery Coordinates',
          'geo': {
            '@type': 'GeoCoordinates',
            'latitude': lat.toString(),
            'longitude': lng.toString()
          }
        }
      }
    };
  }

  Future<void> _injectLeaflet() async {
    if (js.context['L'] != null) return;

    final link = LinkElement()
      ..rel = 'stylesheet'
      ..href = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css';
    document.head?.append(link);

    final script = ScriptElement()
      ..src = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js';
    document.head?.append(script);

    await script.onLoad.first;
  }

  Future<void> initMap() async {
    await _injectLeaflet();
    final L = js.context['L'] as js.JsObject?;
    if (L == null) return;

    final center = js.JsObject.jsify([currentDeviceLat, currentDeviceLng]);

    if (map == null) {
      final satellite = L.callMethod('tileLayer', [
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        js.JsObject.jsify({'attribution': 'Tiles &copy; Esri'})
      ]);
      final labels = L.callMethod('tileLayer', [
        'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}'
      ]);
      final streets = L.callMethod('tileLayer', [
        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        js.JsObject.jsify({'attribution': '© OpenStreetMap contributors'})
      ]);

      final options = js.JsObject.jsify({
        'layers': [satellite, labels]
      });

      final canvas = document.getElementById('antinna-geo-map-canvas');
      map = L.callMethod('map', [canvas, options]);
      map.callMethod('setView', [center, 13]);

      final baseMaps = js.JsObject.jsify({
        'Satellite Hybrid': L.callMethod('layerGroup', [js.JsObject.jsify([satellite, labels])]),
        'Streets': streets
      });
      L.callMethod('control', [js.JsObject.jsify({'layers': baseMaps})]).callMethod('addTo', [map]);

      targetMarker = L.callMethod('marker', [
        center,
        js.JsObject.jsify({
          'draggable': true,
          'title': 'Delivery Location'
        })
      ]).callMethod('addTo', [map]);

      map.callMethod('on', ['click', js.allowInterop((e) {
        final latlng = e['latlng'];
        if (latlng != null) {
          handleManualPinPosition(double.parse(latlng['lat'].toString()), double.parse(latlng['lng'].toString()));
        }
      })]);

      targetMarker.callMethod('on', ['dragend', js.allowInterop((e) {
        final pos = e['target'].callMethod('getLatLng');
        handleManualPinPosition(double.parse(pos['lat'].toString()), double.parse(pos['lng'].toString()));
      })]);
    } else {
      map.callMethod('setView', [center, 13]);
      targetMarker.callMethod('setLatLng', [center]);
    }

    if (window.navigator.geolocation != null) {
      window.navigator.geolocation.getCurrentPosition().then((pos) {
        final coords = pos.coords;
        if (coords != null && coords.latitude != null && coords.longitude != null) {
          currentDeviceLat = coords.latitude!.toDouble();
          currentDeviceLng = coords.longitude!.toDouble();
          final loc = js.JsObject.jsify([currentDeviceLat, currentDeviceLng]);
          map.callMethod('setView', [loc, 13]);
          targetMarker.callMethod('setLatLng', [loc]);
          document.getElementById('antinna-geo-status')?.text = 'Position synchronized.';
        }
      });
    }
  }

  Future<void> handleManualPinPosition(double lat, double lng) async {
    if (targetMarker != null) {
      targetMarker.callMethod('setLatLng', [js.JsObject.jsify([lat, lng])]);
    }
    document.getElementById('antinna-geo-status')?.text = 'Pin dropped. Computing metrics...';

    try {
      final response = await appsScriptService.processPinDropMetrics(currentDeviceLat, currentDeviceLng, lat, lng);
      updateTelemetryUI(response);
    } catch (_) {
      document.getElementById('antinna-geo-status')?.text = 'Error computing metrics.';
    }
  }

  void handleTypeAhead(String value) {
    debounceTimer?.cancel();
    final dropdown = document.getElementById('antinna-geo-dropdown');
    if (dropdown == null) return;

    if (value.length < 3) {
      dropdown.text = '';
      dropdown.style.display = 'none';
      return;
    }

    debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      try {
        final suggestions = await appsScriptService.getPlaceSuggestions(value);
        populateDropdown(suggestions);
      } catch (_) {}
    });
  }

  void populateDropdown(List<String> suggestions) {
    final dropdown = document.getElementById('antinna-geo-dropdown');
    if (dropdown == null) return;
    dropdown.text = '';

    if (suggestions.isEmpty) {
      dropdown.style.display = 'none';
      return;
    }

    for (var text in suggestions) {
      final item = DivElement()
        ..className = 'antinna-geo-dropdown-item'
        ..text = text;

      item.onClick.listen((_) async {
        final input = document.getElementById('antinna-geo-search') as InputElement?;
        if (input != null) input.value = text;
        dropdown.style.display = 'none';
        document.getElementById('antinna-geo-status')?.text = 'Resolving coordinates...';

        try {
          isAddressModified = false;
          final response = await appsScriptService.processLocationAndMetrics(currentDeviceLat, currentDeviceLng, text);
          if (response['success'] == true) {
            final double lat = double.tryParse(response['lat']?.toString() ?? '') ?? currentDeviceLat;
            final double lng = double.tryParse(response['lng']?.toString() ?? '') ?? currentDeviceLng;
            final newPos = js.JsObject.jsify([lat, lng]);
            map.callMethod('setView', [newPos, 15]);
            targetMarker.callMethod('setLatLng', [newPos]);
            updateTelemetryUI(response);
          }
        } catch (_) {}
      });

      dropdown.append(item);
    }
    dropdown.style.display = 'block';
  }

  void updateTelemetryUI(Map<String, dynamic> response) {
    if (response['success'] == true) {
      js.context['lastGeoResponse'] = js.JsObject.jsify(response);
      document.getElementById('antinna-geo-status')?.text = 'Location verified.';
      document.getElementById('antinna-geo-clean-address')?.text = response['address']?.toString() ?? '';
      document.getElementById('antinna-geo-dist')?.text = response['distance']?.toString() ?? '--';
      document.getElementById('antinna-geo-dur')?.text = response['duration']?.toString() ?? '--';

      final double targetLat = double.tryParse(response['lat']?.toString() ?? '') ?? 0.0;
      final double targetLng = double.tryParse(response['lng']?.toString() ?? response['lon']?.toString() ?? '') ?? 0.0;
      document.getElementById('antinna-geo-tag-target')?.text = '${targetLat.toStringAsFixed(4)}, ${targetLng.toStringAsFixed(4)}';
      document.getElementById('antinna-geo-tag-current')?.text = '${currentDeviceLat.toStringAsFixed(4)}, ${currentDeviceLng.toStringAsFixed(4)}';

      final metrics = document.getElementById('antinna-geo-metrics');
      if (metrics != null) metrics.style.display = 'block';

      final form = document.getElementById('antinna-geo-address-form');
      if (form != null) {
        form.style.display = 'block';
        final d = response['addressDetails'] as Map<String, dynamic>? ?? {};
        final extInput = document.getElementById('geo-extendedAddress') as InputElement?;
        final streetInput = document.getElementById('geo-streetAddress') as InputElement?;

        if (!isAddressModified) {
          if (extInput != null) extInput.value = d['extendedAddress']?.toString() ?? '';
          if (streetInput != null) streetInput.value = d['streetAddress']?.toString() ?? '';
        }

        final localityInput = document.getElementById('geo-locality') as InputElement?;
        if (localityInput != null) {
          localityInput.value = d['addressLocality']?.toString() ?? response['city']?.toString() ?? response['addressLocality']?.toString() ?? '';
        }

        final pinInput = document.getElementById('geo-postalCode') as InputElement?;
        if (pinInput != null) {
          pinInput.value = d['postalCode']?.toString() ?? response['pin']?.toString() ?? response['postalCode']?.toString() ?? '';
        }
        validateAddressForm();
      }

      if (js.context['AntinnaEngine'] != null) {
        js.context['AntinnaEngine'].callMethod('setVerifiedLocation', [js.JsObject.jsify(response)]);
      }
    }
  }
}

import 'package:latlong2/latlong.dart';

class MapConstants {
  /// Default coordinates for Lahore, Pakistan
  static const LatLng defaultLocation = LatLng(31.4015, 74.2405);
  
  /// Base map tile URL
  static const String baseMapUrl = 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
  
  /// Subdomains for map tiles
  static const List<String> mapSubdomains = ['a', 'b', 'c', 'd'];
}

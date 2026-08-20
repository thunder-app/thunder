/// Normalizes a user-entered instance into an authority (`host` or `host:port`).
String? normalizeInstanceAuthority(String? input) {
  final trimmed = input?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  final value = trimmed.startsWith('http://') || trimmed.startsWith('https://') ? trimmed : 'https://$trimmed';
  final uri = Uri.tryParse(value);
  final host = uri?.host.trim().toLowerCase();
  if (host == null || host.isEmpty) return null;

  return uri!.hasPort ? '$host:${uri.port}' : host;
}

/// Returns whether [instance] points at a local development host.
bool isLocalInstanceAuthority(String instance) {
  final authority = normalizeInstanceAuthority(instance);
  if (authority == null) return false;

  final uri = Uri.tryParse('https://$authority');
  final host = uri?.host.toLowerCase();
  if (host == null || host.isEmpty) return false;

  return host == 'localhost' || host == 'host.docker.internal' || host == '10.0.2.2' || host == '0.0.0.0' || _isPrivateIpv4Address(host) || RegExp(r'^127(?:\.\d{1,3}){3}$').hasMatch(host);
}

bool _isPrivateIpv4Address(String host) {
  final parts = host.split('.');
  if (parts.length != 4) return false;

  final octets = parts.map(int.tryParse).toList();
  if (octets.any((octet) => octet == null || octet < 0 || octet > 255)) return false;

  final first = octets[0]!;
  final second = octets[1]!;

  return first == 10 || first == 192 && second == 168 || first == 172 && second >= 16 && second <= 31 || first == 169 && second == 254;
}

/// Builds an API or media URI for an instance authority.
Uri buildInstanceUri(String instance, String path, {Map<String, String>? queryParameters}) {
  final authority = normalizeInstanceAuthority(instance) ?? instance;
  final authorityUri = Uri.parse('https://$authority');
  final scheme = isLocalInstanceAuthority(authority) ? 'http' : 'https';

  return Uri(scheme: scheme, host: authorityUri.host, port: authorityUri.hasPort ? authorityUri.port : null, path: path, queryParameters: queryParameters?.isEmpty == true ? null : queryParameters);
}

/// Builds a URL string for an instance authority.
String buildInstanceUrl(String instance, String path) => buildInstanceUri(instance, path).toString();

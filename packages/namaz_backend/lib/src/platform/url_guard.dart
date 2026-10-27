import 'dart:io';

/// Dışarıdan gelen bir bağlantıya cihazdan GET atılırken (SSRF koruması)
/// hedef adresin genel internette olup olmadığını söyler.
///
/// Loopback, özel ağ (RFC 1918), bağlantı-yerel, CGNAT, çoklu yayın ve ayrılmış
/// bloklar `false` döner. IPv6 içine gömülü IPv4 (v4-mapped, NAT64, 6to4) iç
/// IPv4 kurallarıyla yeniden denetlenir.
bool isPublicAddress(InternetAddress address) {
  final b = address.rawAddress;
  switch (address.type) {
    case InternetAddressType.IPv4:
      return _isPublicV4(b);
    case InternetAddressType.IPv6:
      return _isPublicV6(b);
    default:
      return false;
  }
}

bool _isPublicV4(List<int> b) {
  if (b.length != 4) return false;
  final a = b[0];
  final c = b[1];
  if (a == 0) return false; // 0.0.0.0/8 "bu ağ"
  if (a == 10) return false; // 10.0.0.0/8
  if (a == 100 && c >= 64 && c <= 127) return false; // 100.64.0.0/10 CGNAT
  if (a == 127) return false; // loopback
  if (a == 169 && c == 254) return false; // bağlantı-yerel, bulut metadata
  if (a == 172 && c >= 16 && c <= 31) return false; // 172.16.0.0/12
  if (a == 192 && c == 0 && b[2] == 0) return false; // 192.0.0.0/24
  if (a == 192 && c == 0 && b[2] == 2) return false; // TEST-NET-1
  if (a == 192 && c == 168) return false; // 192.168.0.0/16
  if (a == 198 && (c == 18 || c == 19)) return false; // benchmark
  if (a == 198 && c == 51 && b[2] == 100) return false; // TEST-NET-2
  if (a == 203 && c == 0 && b[2] == 113) return false; // TEST-NET-3
  if (a >= 224) return false; // çoklu yayın ve ayrılmış (240/4, yayın)
  return true;
}

bool _isPublicV6(List<int> b) {
  if (b.length != 16) return false;
  final firstTenZero = b.sublist(0, 10).every((x) => x == 0);
  // ::ffff:a.b.c.d (v4-mapped)
  if (firstTenZero && b[10] == 0xff && b[11] == 0xff) {
    return _isPublicV4(b.sublist(12));
  }
  // :: ve ::1; ::a.b.c.d (kullanımdan kalkmış v4-uyumlu) da reddedilir.
  if (firstTenZero && b[10] == 0 && b[11] == 0) return false;
  // 64:ff9b::/96 (NAT64): gömülü IPv4 denetlenir.
  if (b[0] == 0x00 &&
      b[1] == 0x64 &&
      b[2] == 0xff &&
      b[3] == 0x9b &&
      b.sublist(4, 12).every((x) => x == 0)) {
    return _isPublicV4(b.sublist(12));
  }
  // 2002::/16 (6to4): gömülü IPv4 denetlenir.
  if (b[0] == 0x20 && b[1] == 0x02) return _isPublicV4(b.sublist(2, 6));
  if ((b[0] & 0xfe) == 0xfc) return false; // fc00::/7 benzersiz yerel
  if (b[0] == 0xfe && (b[1] & 0xc0) == 0x80) return false; // fe80::/10
  if (b[0] == 0xfe && (b[1] & 0xc0) == 0xc0) return false; // fec0::/10 site-yerel
  if (b[0] == 0xff) return false; // ff00::/8 çoklu yayın
  if (b[0] == 0x20 && b[1] == 0x01 && b[2] == 0x0d && b[3] == 0xb8) {
    return false; // 2001:db8::/32 belgeleme
  }
  return true;
}

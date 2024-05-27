/*
Copyright © 2023 S. O. Otajonov. Use by Licence.
 */


String cleanBaseUrl(String url) {
  if (!url.endsWith('/')) {
    return '$url/';
  } else { return url; }
}

String cleanPath(String url) {

  String cleanUrlPath = url;

  if (url.startsWith('/')) { cleanUrlPath = url.substring(1); }

  if (!url.endsWith('/')) { cleanUrlPath = '$url/'; }

  return cleanUrlPath;
}
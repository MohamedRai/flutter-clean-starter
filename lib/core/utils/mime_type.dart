/// The MIME type for a file with the given [extension] (without the dot).
///
/// Unknown extensions map to `application/octet-stream` rather than being
/// guessed, so a server can reject them as unsupported.
String mimeTypeForExtension(String? extension) =>
    switch (extension?.toLowerCase()) {
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'svg' => 'image/svg+xml',
      'json' => 'application/json',
      'txt' => 'text/plain',
      'csv' => 'text/csv',
      'mp4' => 'video/mp4',
      'mp3' => 'audio/mpeg',
      _ => 'application/octet-stream',
    };

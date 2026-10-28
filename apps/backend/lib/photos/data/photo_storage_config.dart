import 's3_signer.dart';

typedef PhotoStorageConfig = ({S3Signer signer, String bucket});

PhotoStorageConfig photoStorageConfig(Map<String, String> env) => (
  signer: S3Signer(
    endpoint: Uri.parse(env['S3_ENDPOINT'] ?? 'http://localhost:8333'),
    region: env['S3_REGION'] ?? 'us-east-1',
    accessKeyId: env['S3_ACCESS_KEY_ID'] ?? 'ambrogio',
    secretAccessKey: env['S3_SECRET_ACCESS_KEY'] ?? 'ambrogio-secret',
  ),
  bucket: env['S3_BUCKET'] ?? 'ambrogio-photos',
);

import 'package:xprizo_mobile/app/app.dart';
import 'package:xprizo_mobile/bootstrap.dart';
import 'package:xprizo_mobile/core/config/app_config.dart';
import 'package:xprizo_mobile/core/network/api_client.dart';
import 'package:xprizo_mobile/features/product/data/datasources/product_remote_data_source.dart';
import 'package:xprizo_mobile/features/product/data/repositories/product_repository_impl.dart';

Future<void> initializeApp() async {
  final client = await ApiClient.create();
  final productDataSource = ProductRemoteDataSource(
    client,
    redirectUrl: AppConfig.redirectUrl,
  );
  final repo = ProductRepositoryImpl(productDataSource);
  await bootstrap(() => App(repository: repo));
}

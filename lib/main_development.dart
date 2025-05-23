import 'package:xprizo_mobile/app/app.dart';
import 'package:xprizo_mobile/bootstrap.dart';
import 'package:xprizo_mobile/core/network/api_client.dart';
import 'package:xprizo_mobile/features/product/data/datasources/product_remote_data_source.dart';
import 'package:xprizo_mobile/features/product/data/repositories/product_repository_impl.dart';

Future<void> main() async {
  final client = await ApiClient.create();
  final dataSource = ProductRemoteDataSource(client);
  final repo = ProductRepositoryImpl(dataSource);
  await bootstrap(() => App(repository: repo));
}

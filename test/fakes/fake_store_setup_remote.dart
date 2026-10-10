import 'package:gsma/features/auth/data/datasources/remote/store_setup_remote_datasource.dart';

class FakeStoreSetupRemoteDataSource extends StoreSetupRemoteDataSource {
  @override
  Future<bool> isStoreSetupComplete() async => true;
}

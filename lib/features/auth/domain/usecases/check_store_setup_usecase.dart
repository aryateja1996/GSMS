import 'package:gsma/features/auth/data/datasources/remote/store_setup_remote_datasource.dart';

class CheckStoreSetupUseCase {
  CheckStoreSetupUseCase(this._remote);

  final StoreSetupRemoteDataSource _remote;

  Future<bool> call() => _remote.isStoreSetupComplete();
}

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  // This will be implemented with connectivity_plus package
  // For now, creating the interface

  @override
  Future<bool> get isConnected async {
   
    // final ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
    // return connectivityResult != ConnectivityResult.none;
    return true; // Placeholder
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DataController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference dataRef;

  DataController() {
    dataRef = _firestore.collection('data');
  }

  Future<List<DocumentSnapshot>> getData() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // لو مفيش نت، استخدم البيانات المخزنة محليًا
      return await dataRef.get(GetOptions(source: Source.cache)).then((snapshot) {
        return snapshot.docs;
      });
    } else {
      // لو فيه نت، جلب البيانات من السرفر وتحديث الكاش
      return await dataRef.get().then((snapshot) {
        return snapshot.docs;
      });
    }
  }
}

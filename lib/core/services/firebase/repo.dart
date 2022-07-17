class DatabaseService {
  // static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // static StreamSubscription? _snapshot;

  // static addData(Map<String, dynamic> data) async {
  //   data["time"] = DateTime.now();
  //   _firestore.collection("users").add(data.cast());
  // }

  // static setData(Map<String, dynamic> data, String id) async {
  //   data["yas"] = FieldValue.increment(1);
  //   data["time"] = FieldValue.serverTimestamp();
  //   data["array"] = FieldValue.arrayUnion(["a", "b", "c"]);
  //   _firestore.collection("users").doc(id).set(data, SetOptions(merge: true));
  // }

  // static lastIdWillBe() {
  //   return _firestore.collection("users").doc().id;
  // }

  // static updateData(Map<String, dynamic> data, String id) async {
  //   data["adres.ilce"] = "iç field";
  //   _firestore.collection("users").doc(id).update(data);
  // }

  // static deleteData(String id) async {
  //   _firestore.collection("users").doc(id).delete();
  // }

  // static deleteFieldByUpdate(String id, String field) async {
  //   _firestore.collection("users").doc(id).update({field: FieldValue.delete()});
  // }

  // static readData(String id) async {
  //   QuerySnapshot _docs = await _firestore.collection("users").get();
  //   for (var element in _docs.docs) {
  //     var data = element.data();
  //     if (data != null && element.id == "uXy6DWmmDYdQK0sUR1Vw") {
  //       print(((data as Map)["time"] as Timestamp).toDate());
  //     }
  //   }
  // }

  // static addSnapshot() {
  //   print("snapshot oluştu");
  //   _snapshot = _firestore.collection("users").snapshots().listen((event) {
  //     for (var element in event.docChanges) {
  //       print(element.doc.data());
  //     }
  //   });
  // }

  // static cancelSnapshot() {
  //   _snapshot?.cancel();
  // }

  // static batchUsage() async {
  //   WriteBatch _batch = _firestore.batch();
  //   WriteBatch _batch2 = _firestore.batch();
  //   WriteBatch _batch3 = _firestore.batch();
  //   CollectionReference _collection = _firestore.collection("users");
  //   List _docs = [];
  //   for (int i = 0; i < 5; i++) {
  //     DocumentReference _doc = _collection.doc();
  //     _docs.add(_doc);
  //     _batch.set(_doc, {
  //       "name": "name $i",
  //       "surname": "surname $i",
  //       "age": i,
  //     });
  //   }
  //   await _batch.commit();
  //   await Future.delayed(const Duration(seconds: 4));
  //   for (var element in _docs) {
  //     _batch2.update(element, {
  //       "name": "name updated",
  //     });
  //   }
  //   await _batch2.commit();
  //   await Future.delayed(const Duration(seconds: 4));
  //   for (var element in _docs) {
  //     _batch3.delete(element);
  //   }
  //   await _batch3.commit();
  // }

  // static transactionUsage() {
  //   _firestore.runTransaction((transaction) async {
  //     DocumentReference _ertu1 = _firestore.collection("users").doc("ertu1");
  //     DocumentReference _ertu2 = _firestore.collection("users").doc("ertu2");

  //     int _ertu1Para = ((await transaction.get(_ertu1)).data() as Map)["para"];
  //     if (_ertu1Para > 100) {
  //       transaction.update(_ertu2, {"para": FieldValue.increment(100)});
  //       transaction.update(_ertu1, {"para": FieldValue.increment(-100)});
  //     }
  //   });
  // }

  // static queryingData() {
  //   // _firestore
  //   //     .collection("users")
  //   //     .limit(5)
  //   //     .where("age", isGreaterThan: 20)
  //   //     .get()
  //   //     .then((value) => value.docs.forEach((element) {
  //   //           print(element.data());
  //   //         }));

  //   _firestore
  //       .collection("users")
  //       .orderBy("age", descending: true)
  //       .get()
  //       .then((value) => value.docs.forEach((element) {
  //             print(element.data());
  //           }));

  //   _firestore
  //       .collection("users")
  //       .orderBy("name")
  //       .startAt(["ertu"])
  //       .endAt(["cakici"])
  //       .get()
  //       .then((value) => value.docs.forEach((element) {
  //             print(element.data());
  //           }));
  // }

  // static uploadImage() async {
  //   final ImagePicker _picker = ImagePicker();
  //   XFile? _file = await _picker.pickImage(source: ImageSource.camera);
  //   if (_file != null) {
  //     var _profileRef = FirebaseStorage.instance.ref("users/profil_resimleri");
  //     UploadTask _task = _profileRef.putFile(File(_file.path));
  //     _task.whenComplete(() {
  //       _profileRef.getDownloadURL().then((value) => print(value));
  //     });
  //   }
  // }

  // set ile bir döküman olmasa bile oluşturuyor fakat update ile döküman olmak zorunda.
  // Update de set de de fieldleri varsa güncelliyor yoksa yenisini oluşturuyor ama set te merge etmediysek hepsini silip yeni değeri sadece yazıyor.
}

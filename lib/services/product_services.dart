part of 'services.dart';

class ProductServices {
  //setup cloud firestore
  static CollectionReference productCollection =
      FirebaseFirestore.instance.collection("products");
  static DocumentReference productDoc;

  //setup firestore storage
  static Reference ref;
  static UploadTask uploadTask;

  static String imgUrl;

  static Future<bool> addProduct(Products product, PickedFile imgFile) async {
    await Firebase.initializeApp();
    productDoc = await productCollection.add({
      'id': "",
      'name': product.name,
      'price': product.price,
      'image': "",
    });

    if (productDoc.id != null) {
      ref = FirebaseStorage.instance
          .ref()
          .child("images")
          .child(productDoc.id + ".png");
      uploadTask = ref.putFile(File(imgFile.path));

      await uploadTask.whenComplete(() => ref.getDownloadURL().then(
            (value) => imgUrl = value,
          ));

      productCollection.doc(productDoc.id).update({
        'id': productDoc.id,
        'image': imgUrl,
      });
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> editProduct(Products product) async {
    await Firebase.initializeApp();

    await productCollection.doc(product.id).update(
      {
        'name': product.name,
        'price': product.price,
      },
    );

    return true;
  }

  static Future<bool> deleteProduct(Products product) async {
    await Firebase.initializeApp();

    await productCollection.doc(product.id).delete();

    return true;
  }
}

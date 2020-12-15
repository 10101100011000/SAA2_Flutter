part of 'pages.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isLoading = false;
  User _auth = FirebaseAuth.instance.currentUser;
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  String img, name, email;

  PickedFile imageFile;
  final ImagePicker imagePicker = ImagePicker();

  Future chooseImage() async {
    final selectedImage = await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      imageFile = selectedImage;
    });
  }

  void getUserUpdate() async {
    userCollection.doc(_auth.uid).snapshots().listen((event) {
      img = event.data()['profilePicture'];
      name = event.data()['name'];
      email = event.data()['email'];
      if (img == "") {
        img = null;
      }
      setState(() {});
    });
  }

  void initState() {
    getUserUpdate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Account"),
        backgroundColor: Colors.orange,
        centerTitle: true,
        leading: Container(),
      ),
      body: Stack(children: [
        Container(
            padding: EdgeInsets.only(
              //space between bottom screen and sign out button
              bottom: 20,
            ),
            child: Align(
              //sign out confirmation pop-up
              alignment: Alignment.bottomCenter,
              child: RaisedButton(
                //confirmation screen
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Sign Out Confirmation"),
                          content: Text("Are you sure you want to Sign Out?"),
                          actions: [
                            FlatButton(
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await AuthServices.signOut().then((value) {
                                    if (value) {
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return SignInPage();
                                      }));
                                      setState(() {
                                        isLoading = false;
                                      });
                                    } else {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  });
                                },
                                child: Text("Yes")),
                            FlatButton(
                              child: Text("No"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                          ],
                        );
                      });
                },
                padding: EdgeInsets.all(12),
                textColor: Colors.white,
                color: Colors.red,
                child: Text("Sign Out"),
              ),
            )),
        Card(
          //card
          margin: new EdgeInsets.fromLTRB(30, 30, 30, 80),

          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.width * 1.0,
            child: Card(
              elevation: 15,
              color: Colors.teal,
              child: Column(
                children: <Widget>[
                  Stack(children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ]),
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(
                      img ??
                          "https://firebasestorage.googleapis.com/v0/b/flutterpractice-b670c.appspot.com/o/default%20images%2Fdefault%20user.png?alt=media&token=1e0e45f5-0be6-44c0-b70c-00c91d166cd2",
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RaisedButton.icon(
                    color: Colors.blue,
                    textColor: Colors.white,
                    padding: EdgeInsets.all(8),
                    icon: Icon(Icons.image),
                    label: Text('Edit Photo'),
                    onPressed: () async {
                      await chooseImage();
                      await UserServices.updateProfilePicture(
                              _auth.uid, imageFile)
                          .then((value) {
                        if (value) {
                          Fluttertoast.showToast(
                            msg: "Update profile picture succesful!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: "Failed",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      });
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    name ?? '',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    email ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        isLoading == true //loading animation
            ? Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
                child: SpinKitFadingCircle(
                  size: 50,
                  color: Colors.red,
                ),
              )
            : Container()
      ]),
    );
  }
}
// "https://www.toptal.com/designers/subtlepatterns/patterns/memphis-mini.png"

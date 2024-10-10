import 'dart:io'; // Import thư viện cho các thao tác với hệ thống tệp
import 'package:flutter/foundation.dart'; // Import các chức năng cơ bản của Flutter
import 'package:flutter/material.dart'; // Import thư viện Material Design của Flutter
import 'package:firebase_core/firebase_core.dart'; // Import thư viện Firebase để khởi tạo
import 'package:firebase_database/firebase_database.dart'; // Import thư viện Firebase Realtime Database
import 'home.dart'; // Import HomePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo rằng các widget được liên kết với khung

  // Khởi tạo Firebase cho Web và Android
  if (kIsWeb) { // Kiểm tra xem ứng dụng có đang chạy trên nền tảng Web không
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCu1Bd5MJjAsS_744eeqcfARFsOeAOFswY",
        appId: "1:444145783078:web:exampleappid",
        messagingSenderId: "444145783078", //
        projectId: "gkltdd-fc459", // ID dự án Firebase
        databaseURL: "https://gkltdd-fc459-default-rtdb.firebaseio.com",
      ),
    );
  } else if (Platform.isAndroid) { // Kiểm tra nếu nền tảng là Android
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCu1Bd5MJjAsS_744eeqcfARFsOeAOFswY", // Khóa API Firebase
        appId: "1:444145783078:android:b2f7a51f7e9d851dd331e7", // ID ứng dụng Android
        messagingSenderId: "444145783078", // ID người gửi tin nhắn
        projectId: "gkltdd-fc459", // ID dự án Firebase
        databaseURL: "https://gkltdd-fc459-default-rtdb.firebaseio.com", // URL Firebase cho Android
      ),
    );
  } else {
    await Firebase.initializeApp(); // Khởi tạo Firebase cho nền tảng khác
  }

  runApp(MyApp()); // Khởi chạy ứng dụng MyApp
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(), // Xác định trang đầu tiên là LoginPage
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState(); // Tạo trạng thái cho LoginPage
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // Khóa cho form để xác thực
  final TextEditingController _emailController = TextEditingController(); // Controller cho email
  final TextEditingController _passwordController = TextEditingController(); // Controller cho password
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref(); // Tham chiếu đến Firebase Realtime Database

  String? cost; // Biến lưu giá trị cost từ Firebase

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'), // Tiêu đề của AppBar
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // Padding cho nội dung
        child: Form(
          key: _formKey, // Gán khóa cho form
          child: Column(
            children: [
              TextFormField(
                controller: _emailController, // Controller cho trường nhập email
                decoration: InputDecoration(labelText: 'Email'), // Nhãn cho trường nhập email
                validator: (value) {
                  if (value == null || value.isEmpty) { // Kiểm tra nếu email không được nhập
                    return 'Please enter your email'; // Trả về thông báo lỗi
                  }
                  return null; // Nếu hợp lệ, không trả về thông báo lỗi
                },
              ),
              TextFormField(
                controller: _passwordController, // Controller cho trường nhập password
                decoration: InputDecoration(labelText: 'Password'), // Nhãn cho trường nhập password
                obscureText: true, // Ẩn văn bản để bảo mật
                validator: (value) {
                  if (value == null || value.isEmpty) { // Kiểm tra nếu password không được nhập
                    return 'Please enter your password'; // Trả về thông báo lỗi
                  }
                  return null; // Nếu hợp lệ, không trả về thông báo lỗi
                },
              ),
              SizedBox(height: 20), // Khoảng cách giữa các widget
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) { // Kiểm tra tính hợp lệ của form
                    _login(context); // Gọi hàm đăng nhập
                  }
                },
                child: Text('Login'), // Nút đăng nhập
              ),
              if (cost != null) // Kiểm tra nếu có giá trị cost
                Text('Cost: $cost'), // Hiển thị giá trị cost nếu có
            ],
          ),
        ),
      ),
    );
  }

  // Hàm đăng nhập
  void _login(BuildContext context) async {
    String enteredEmail = _emailController.text;
    String enteredPassword = _passwordController.text;

    try {
      // Truy vấn Firebase Realtime Database cho email, password và cost
      DatabaseReference emailRef = _databaseRef.child('/admin/name');
      DatabaseReference passRef = _databaseRef.child('/admin/pass');
      DatabaseReference costRef = _databaseRef.child('/admin/cost');

      // Lấy dữ liệu 3 cái từ Firebase

      DataSnapshot emailSnapshot = await emailRef.get();
      DataSnapshot passSnapshot = await passRef.get();
      DataSnapshot costSnapshot = await costRef.get();

      if (emailSnapshot.exists && passSnapshot.exists) { // Kiểm tra nếu email và password tồn tại
        String storedEmail = emailSnapshot.value.toString(); // Lấy giá trị email từ snapshot
        String storedPass = passSnapshot.value.toString(); // Lấy giá trị password từ snapshot

        if (enteredEmail == storedEmail && enteredPassword == storedPass) { // So sánh email và password nhập vào với giá trị trong database
          print('Login successful'); // In ra thông báo đăng nhập thành công
          setState(() {
            cost = costSnapshot.value?.toString() ?? 'No cost available'; // Gán giá trị cost sau khi đăng nhập
          });

          // Điều hướng đến trang HomePage sau khi đăng nhập thành công
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()), // Điều hướng tới HomePage
          );

          ScaffoldMessenger.of(context).showSnackBar( // Hiển thị thông báo đăng nhập thành công
            SnackBar(content: Text('Login successful')),
          );
        } else {
          print('Invalid email or password'); // In ra thông báo email hoặc password không hợp lệ
          ScaffoldMessenger.of(context).showSnackBar( // Hiển thị thông báo lỗi
            SnackBar(content: Text('Invalid email or password')),
          );
        }
      } else {
        print('Error: No data found in the database'); // In ra thông báo không tìm thấy dữ liệu
        ScaffoldMessenger.of(context).showSnackBar( // Hiển thị thông báo lỗi
          SnackBar(content: Text('No data found in the database')),
        );
      }
    } catch (e) {
      print('Error fetching data from Firebase: $e'); // In ra thông báo lỗi khi truy xuất dữ liệu
      ScaffoldMessenger.of(context).showSnackBar( // Hiển thị thông báo lỗi
        SnackBar(content: Text('Error fetching data from Firebase')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

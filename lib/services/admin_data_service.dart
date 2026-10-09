import '../models/user_model.dart';

class AdminDataService {
  AdminDataService._();

  static final List<String> kelas = ['RPL', 'TKJ'];

  static final List<UserModel> _users = [
    const UserModel(name: 'Admin PKL', username: 'admin', role: 'admin'),
    const UserModel(name: 'Bapak/Ibu Guru', username: 'guru', role: 'guru'),
    const UserModel(name: 'Siswa PKL', username: 'siswa', role: 'siswa'),
    const UserModel(
      name: 'Siswa RPL 1',
      username: 'siswa.rpl1',
      role: 'siswa',
      className: 'RPL',
    ),
    const UserModel(
      name: 'Siswa RPL 2',
      username: 'siswa.rpl2',
      role: 'siswa',
      className: 'RPL',
    ),
    const UserModel(
      name: 'Siswa TKJ 1',
      username: 'siswa.tkj1',
      role: 'siswa',
      className: 'TKJ',
    ),
    const UserModel(
      name: 'Siswa TKJ 2',
      username: 'siswa.tkj2',
      role: 'siswa',
      className: 'TKJ',
    ),
  ];

  static List<UserModel> get users => List.unmodifiable(_users);

  static List<UserModel> get students =>
      _users.where((user) => user.role == 'siswa').toList(growable: false);

  static void addUser(UserModel user) => _users.add(user);

  static void updateUser(int index, UserModel user) => _users[index] = user;

  static void removeUser(int index) => _users.removeAt(index);

  static void addClass(String name) => kelas.add(name);

  static void updateClass(int index, String name) => kelas[index] = name;

  static void removeClass(int index) => kelas.removeAt(index);

  static String? classForStudent(String studentName) {
    for (final user in students) {
      if (user.name == studentName) return user.className;
    }
    return null;
  }
}

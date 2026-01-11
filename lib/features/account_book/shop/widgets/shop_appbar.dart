import 'package:flutter/material.dart';
import 'package:lets_grow_wallet/utils/colors.dart';
import 'package:lets_grow_wallet/features/user/services/user_profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopAppbar extends StatefulWidget {
  const ShopAppbar({super.key});

  @override
  State<ShopAppbar> createState() => _ShopAppbarState();
}

class _ShopAppbarState extends State<ShopAppbar> {
  final _userProfileService = UserProfileService();
  late Future<int> _coinFuture;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _lastUserId = Supabase.instance.client.auth.currentUser?.id;
    _coinFuture = _loadCoin();

    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final nextUserId = event.session?.user.id;
      if (nextUserId == _lastUserId) return;
      _lastUserId = nextUserId;
      if (!mounted) return;
      setState(() {
        _coinFuture = _loadCoin();
      });
    });
  }

  Future<int> _loadCoin() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return 0;
    return _userProfileService.getUserCoin(userId);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: MainColors.mainLight, width: 1),
          ),
          child: Icon(
            Icons.workspace_premium_outlined,
            color: MainColors.mainLight,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 40,
          width: mediaQuery.size.width * 0.35,
          decoration: BoxDecoration(
            border: Border.all(color: MainColors.mainLight, width: 1),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 15),
              FutureBuilder<int>(
                future: _coinFuture,
                builder: (context, snapshot) {
                  final coin = snapshot.data ?? 0;
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.active;

                  return Text(
                    isLoading ? 'C ...' : 'C $coin',
                    style: TextStyle(fontSize: 18, color: MainColors.mainLight),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

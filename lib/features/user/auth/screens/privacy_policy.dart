import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          title: Text("개인정보 처리방침", style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "본 앱은 이용자의 개인정보를 중요하게 생각하며, 「개인정보 보호법」 등 관련 법령을 준수합니다. 본 개인정보 처리방침은 서비스 이용과 관련하여 수집되는 개인정보의 항목, 이용 목적, 보관 및 보호에 관한 사항을 안내합니다.",
                ),
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 10),
                Text(
                  "1. 수집하는 개인정보",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "① 로그인 및 사용자 정보",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('● 소셜 로그인 정보'),
                Text('  ● Google 로그인: 이메일, 닉네임, 계정 고유 ID'),
                Text('  ● Kakao 로그인: 이메일, 닉네임, 계정 고유 ID'),
                Text('● 사용자 닉네임 (앱 최초 실행 시 설정)'),
                SizedBox(height: 10),
                Text(
                  '② 서비스 이용 정보',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('● 가계부 소비 및 수입 기록'),
                Text('● 카테고리, 메모, 날짜 정보'),
                Text('● 통계 및 캘린더 데이터'),
                Text('● 캐릭터 성장, 퀘스트 진행 정보'),
                Text('● 상점 이용 기록'),
                SizedBox(height: 10),
                Text(
                  '③ 결제 및 광고 관련 정보',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '● 인앱 결제 이용 여부 (결제 자체는 Google Play를 통해 처리되며, 결제 정보는 앱 서버에 저장되지 않습니다.)',
                ),
                Text('● 광고 식별자(AD ID) 등 광고 제공을 위한 정보(광고 플랫폼에서 자동 수집될 수 있음)'),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                Text(
                  "2. 개인정보의 수집 및 이용 목적",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text("수집한 개인정보는 다음 목적을 위해 사용됩니다."),
                Text('● 사용자 식별 및 로그인 기능 제공'),
                Text('● 가계부 서비스 제공'),
                Text('● 통계, 캘린더, 캐릭터 성장 및 퀘스트 기능 제공'),
                Text('● 인앱 결제 및 상점 기능 제공'),
                Text('● 광고 노출 및 서비스 개선'),
                Text('● 데이터 저장 및 기기 간 동기화'),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                Text(
                  "3. 개인정보의 보관 처리",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('● 본 서비스는 Supabase를 이용하여 개인정보를 안전하게 저장 및 관리합니다.'),
                Text('● 개인정보는 서비스 제공 목적 범위 내에서만 처리되며, 목적 외 사용은 하지 않습니다.'),
                Text('● 서버와의 통신은 암호화된 방식으로 이루어집니다.'),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                Text(
                  '4. 개인정보 보관 기간',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '● 이용자가 회원 탈퇴를 요청할 경우, 관련 법령에 따라 보관이 필요한 정보를 제외하고 개인정보는 즉시 삭제됩니다.',
                ),
                Text('● 단, 관계 법령에 따라 일정 기간 보관이 필요한 경우 해당 기간 동안 안전하게 보관됩니다.'),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),

                Text(
                  '5. 개인정보 제3자 제공',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('● 본 앱은 법령에 의한 경우를 제외하고 개인정보를 제3자에게 제공하지 않습니다.'),
                Text(
                  '● 다만, 광고 제공을 위해 광고 플랫폼에 일부 정보가 제공될 수 있습니다. 이 경우에도 개인정보 보호법 등 관련 법령을 준수합니다.',
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                Text(
                  '6. 개인정보 처리 위탁',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('서비스 제공을 위해 아래와 같은 외부 서비스를 이용할 수 있습니다.'),
                Text('● Supabase (백엔드 및 데이터베이스)'),
                Text('● Google / Kakao (소셜 로그인)'),
                Text('● Google Play 결제 서비스 (인앱 결제)'),
                Text('● AdMob (광고 제공)'),

                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                Text(
                  '7. 이용자의 권리',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('이용자는 언제든지 본인의 개인정보 조회, 수정, 삭제(회원 탈퇴)를 요청할 수 있습니다.'),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                Text(
                  '8. 개인정보 보호 문의',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('개인정보와 관련한 문의사항은 아래 로 문의해 주세요.'),
                Row(
                  children: [
                    Text("● 이메일: "),
                    InkWell(
                      onTap: () async {
                        // 웹사이트로 보내고 싶으면 mailto: 대신 https://... 로 바꾸면 됨
                        final uri = Uri.parse(
                          'https://mail.google.com/mail/u/0/?fs=1&to=gaeunpark736@gmail.com&tf=cm',
                        );
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: const Text(
                        'gaeunpark736@gmail.com',
                        style: TextStyle(color: Color.fromARGB(255, 59, 6, 92)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

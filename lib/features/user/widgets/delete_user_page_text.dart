import 'package:flutter/material.dart';

class DeleteUserPageText extends StatelessWidget {
  const DeleteUserPageText({super.key});

  static const _bodyStyle = TextStyle(fontSize: 16);
  static const _sectionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "회원 탈퇴를 진행하시면, 현재 사용 중인 계정과 관련된 모든 정보가 삭제되며 삭제된 데이터는 어떠한 경우에도 복구할 수 없습니다.",
          style: _bodyStyle,
        ),
        SizedBox(height: 12),
        Divider(),
        SizedBox(height: 12),
        InfoSection(
          title: "삭제되는 개인정보 및 서비스 데이터",
          lines: [
            "- 소셜 로그인 정보와 연동된 계정 식별 정보",
            "- 가계부 소비 / 수입 기록 전체",
            "- 카테고리별 통계 데이터 및 캘린더 기록",
            "- 캐릭터 성장 정보, 퀘스트 진행 내역",
            "- 상점 이용 기록 및 보유한 재화",
            "- 기타 서비스 이용과 관련된 모든 활동 기록",
          ],
        ),
        SizedBox(height: 12),
        InfoSection(
          title: "결제 및 광고 관련 안내",
          lines: [
            "- 인앱 결제를 통해 구매한 상품 및 재화는 탈퇴와 함께 소멸됩니다.",
            "- 이미 사용된 결제 내역은 환불되지 않으며, 사용하지 않은 재화 역시 복구가 불가능합니다.",
            "- 광고 노출 및 리워드 관련 기록 또한 함께 삭제됩니다",
          ],
        ),
        SizedBox(height: 12),
        Divider(),
        SizedBox(height: 12),
        Text("- 탈퇴 이후에는 로그인 및 서비스 이용이 불가능합니다.", style: _bodyStyle),
        Text(
          "- 탈퇴 처리 후에는 취소가 불가능하며, 고객센터를 통한 복구 요청도 지원되지 않습니다.",
          style: _bodyStyle,
        ),

        SizedBox(height: 12),
      ],
    );
  }
}

class InfoSection extends StatelessWidget {
  final String title;
  final List<String> lines;

  const InfoSection({super.key, required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: DeleteUserPageText._sectionTitleStyle),
          const SizedBox(height: 6),
          for (final line in lines)
            Text(line, style: DeleteUserPageText._bodyStyle),
        ],
      ),
    );
  }
}
